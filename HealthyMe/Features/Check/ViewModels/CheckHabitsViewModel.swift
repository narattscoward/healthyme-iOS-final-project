import Foundation
import SwiftUI
import WidgetKit   // ⟵ for WidgetCenter.reloadAllTimelines()

// MARK: - Quote cache (unchanged)
private let QUOTE_CACHE_KEY = "hm.quote.cache.v2"

// Keys used by the widget to read pending items from the App Group
private let PENDING_TITLES_KEY = "hm.widget.pendingTitles.v1"
private let PENDING_IDS_KEY    = "hm.widget.pendingIDs.v1"

private struct QuoteCache: Codable {
    let dateKey: String
    let habitsKey: String
    let text: String
    let author: String
}

private func makeHabitsKey(from habits: [Habit]) -> String {
    habits
        .map { $0.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        .sorted()
        .joined(separator: "|")
}

private func todayKey(_ date: Date = Date()) -> String {
    let df = DateFormatter()
    df.calendar = .init(identifier: .gregorian)
    df.locale = .init(identifier: "en_US_POSIX")
    df.dateFormat = "yyyy-MM-dd"
    return df.string(from: date)
}

// MARK: - ViewModel

final class CheckHabitsViewModel: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    private let store: HabitsStoring
    private let notifier = NotificationService.shared

    // Quote state
    @Published var quoteText: String?
    @Published var quoteAuthor: String?
    @Published var isLoadingQuote: Bool = false
    @Published var quoteError: String?

    // Throttle & coalescing
    private var lastFetchAt: Date?
    private var inFlightTask: Task<Void, Never>?
    private let minFetchInterval: TimeInterval = 90

    init(store: HabitsStoring = HabitsStore()) {
        self.store = store
        self.habits = store.load()

        // ----- Migration: lastCompletedOn -> completedDays -----
        var changed = false
        for i in habits.indices {
            if let d = habits[i].lastCompletedOn {
                let key = Habit.dayKey(d)
                if !habits[i].completedDays.contains(key) {
                    habits[i].completedDays.insert(key)
                    changed = true
                }
            }
        }
        if changed { persist() }

        // Restore cached quote
        if let cached = Self.loadCachedQuote() {
            self.quoteText = cached.text
            self.quoteAuthor = cached.author
        }
        
        // 👇 Add this here
        NotificationCenter.default.addObserver(
            forName: DeepLinkHandler.habitsChangedNote,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.habits = self.store.load() // reload from shared App Group
        }
    }

    // MARK: - Intents

    func add(title: String, time: DateComponents?, notify: Bool, notes: String) {
        let new = Habit(title: title, time: time, notify: notify, notes: notes)
        habits.append(new)
        persist()
        notifier.sync(for: new)
    }

    func toggle(_ habit: Habit) {
        guard let idx = habits.firstIndex(of: habit) else { return }
        habits[idx].toggleToday()
        persist()
    }

    func delete(at offsets: IndexSet) {
        let ids: [UUID] = offsets.compactMap { index in
            guard habits.indices.contains(index) else { return nil }
            return habits[index].id
        }
        habits.remove(atOffsets: offsets)
        persist()
        notifier.cancel(ids: ids)
    }

    func delete(id: UUID) {
        if let idx = habits.firstIndex(where: { $0.id == id }) {
            habits.remove(at: idx)
            persist()
            notifier.cancel(for: id)
        }
    }

    /// Save to app storage **and** update the widget snapshot + pending habits list.
    private func persist() {
        // 1) Save app data
        store.save(habits)

        // 2) Snapshot for widgets
        let stats = progressStats(lastDays: 28)
        let snap = WidgetSnapshot(
            bestStreak: stats.bestStreak,
            completionRate: stats.todayRate,   // today’s rate
            totalCompletions: stats.total
        )
        WidgetDataStore.save(snap)

        // 3) Pending (unchecked) habits → paired array [[id,title]] for the widget
        let unchecked = habits.filter { !$0.isCompletedToday }
        let pendingPairs: [[String: String]] = unchecked.prefix(1).compactMap { h in
            let title = h.title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { return nil }
            return ["id": h.id.uuidString, "title": title]
        }

        if let ud = UserDefaults(suiteName: SharedIDs.appGroup) {
            // new single payload the widget reads
            ud.set(pendingPairs, forKey: "hm.widget.pendingPairs.v1")

            // optional: clean up old keys so we don’t confuse ourselves later
            ud.removeObject(forKey: "hm.widget.pendingTitles.v1")
            ud.removeObject(forKey: "hm.widget.pendingIDs.v1")
        }
        // 4) Refresh widgets
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // Binding for details screen
    func binding(for id: UUID, fallback: Habit? = nil) -> Binding<Habit> {
        Binding<Habit>(
            get: {
                if let idx = self.habits.firstIndex(where: { $0.id == id }) {
                    return self.habits[idx]
                } else {
                    return fallback ?? Habit(id: id, title: "")
                }
            },
            set: { newValue in
                if let idx = self.habits.firstIndex(where: { $0.id == id }) {
                    self.habits[idx] = newValue
                    self.persist()
                    self.notifier.sync(for: newValue)
                }
            }
        )
    }

    // MARK: - Quote loader (throttled + cached)

    @MainActor
    func refreshQuote(force: Bool = false) async {
        if inFlightTask != nil { return }

        let unchecked = habits.filter { !$0.isCompletedToday }
        let newHabitsKey = makeHabitsKey(from: unchecked)
        let dKey = todayKey()

        if !force, let cached = Self.loadCachedQuote(),
           cached.dateKey == dKey, cached.habitsKey == newHabitsKey {
            self.quoteText = cached.text
            self.quoteAuthor = cached.author
            self.quoteError = nil
            return
        }

        if !force, let last = lastFetchAt, Date().timeIntervalSince(last) < minFetchInterval {
            return
        }

        inFlightTask = Task { [weak self] in
            guard let self = self else { return }
            await MainActor.run {
                self.isLoadingQuote = true
                self.quoteError = nil
            }

            defer {
                Task { @MainActor in
                    self.isLoadingQuote = false
                    self.inFlightTask = nil
                }
            }

            do {
                let result = try await QuoteAIService.shared.fetchQuote(forUnchecked: unchecked)
                await MainActor.run {
                    self.quoteText = result.text
                    self.quoteAuthor = result.author
                    self.lastFetchAt = Date()
                    Self.saveCachedQuote(.init(dateKey: dKey,
                                               habitsKey: newHabitsKey,
                                               text: result.text,
                                               author: result.author))
                }
            } catch {
                let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                await MainActor.run {
                    self.quoteError = msg
                    self.lastFetchAt = Date()
                }
            }
        }

        await inFlightTask?.value
    }

    private static func loadCachedQuote() -> QuoteCache? {
        guard let data = UserDefaults.standard.data(forKey: QUOTE_CACHE_KEY) else { return nil }
        return try? JSONDecoder().decode(QuoteCache.self, from: data)
    }

    private static func saveCachedQuote(_ cache: QuoteCache) {
        if let data = try? JSONEncoder().encode(cache) {
            UserDefaults.standard.set(data, forKey: QUOTE_CACHE_KEY)
        }
    }
    
    // MARK: - Static helper for external use (like DeepLinkHandler)
    static func computeStats(for habits: [Habit], lastDays: Int = 30)
    -> (bestStreak: Int, rate28: Double, todayRate: Double, total: Int) {

        let cal = Calendar(identifier: .gregorian)
        let df = DateFormatter()
        df.calendar = cal
        df.locale = .init(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"

        // Build last N day keys oldest -> newest
        let days: [String] = (0..<lastDays).reversed().compactMap { offset in
            cal.date(byAdding: .day, value: -offset, to: Date()).map(df.string(from:))
        }

        let totalCompletions = habits.reduce(0) { $0 + $1.completedDays.count }

        // last-N-days rate
        let completedLastN = days.reduce(0) { sum, key in
            sum + habits.filter { $0.completedDays.contains(key) }.count
        }
        let rate28 = Double(completedLastN) / Double(max(1, habits.count * lastDays))

        // today's rate
        let completedToday = habits.filter { $0.isCompletedToday }.count
        let todayRate = Double(completedToday) / Double(max(1, habits.count))

        // best streak per habit
        func bestStreak(for habit: Habit) -> Int {
            var best = 0, cur = 0
            var date = Date()
            for _ in 0..<365 {
                let k = df.string(from: date)
                if habit.completedDays.contains(k) {
                    cur += 1
                    best = max(best, cur)
                } else {
                    cur = 0
                }
                guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
                date = prev
            }
            return best
        }
        let best = habits.map(bestStreak(for:)).max() ?? 0

        return (best, rate28, todayRate, totalCompletions)
    }

    // MARK: - Stats for Progress

    /// - Returns:
    ///   - bestStreak: best single-habit streak (days)
    ///   - rate28: completion rate over the last N days (0...1)
    ///   - todayRate: today's completion rate (0...1)
    ///   - total: total number of completions all time
    ///   - bars: last-N-days normalized bars
    func progressStats(lastDays: Int = 30)
    -> (bestStreak: Int, rate28: Double, todayRate: Double, total: Int, bars: [Double]) {

        let cal = Calendar(identifier: .gregorian)
        let df = DateFormatter()
        df.calendar = cal
        df.locale = .init(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"

        // Build last N day keys oldest->newest
        let days: [String] = (0..<lastDays).reversed().compactMap { offset in
            cal.date(byAdding: .day, value: -offset, to: Date()).map(df.string(from:))
        }

        let totalCompletions = habits.reduce(0) { $0 + $1.completedDays.count }

        // bars: how many habits completed each day / max habits
        let maxH = max(1, habits.count)
        let bars: [Double] = days.map { key in
            let count = habits.filter { $0.completedDays.contains(key) }.count
            return Double(count) / Double(maxH)
        }

        // last-N-days rate
        let completedLastN = days.reduce(0) { sum, key in
            sum + habits.filter { $0.completedDays.contains(key) }.count
        }
        let rate28 = Double(completedLastN) / Double(max(1, habits.count * lastDays))

        // today's rate
        let completedToday = habits.filter { $0.isCompletedToday }.count
        let todayRate = Double(completedToday) / Double(max(1, habits.count))

        // best streak per habit
        func bestStreak(for habit: Habit) -> Int {
            var best = 0, cur = 0
            var date = Date()
            for _ in 0..<365 {
                let k = df.string(from: date)
                if habit.completedDays.contains(k) { cur += 1; best = max(best, cur) }
                else { cur = 0 }
                guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
                date = prev
            }
            return best
        }
        let best = habits.map(bestStreak(for:)).max() ?? 0

        return (bestStreak: best, rate28: rate28, todayRate: todayRate, total: totalCompletions, bars: bars)
    }
}


