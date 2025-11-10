import Foundation
import WidgetKit

enum DeepLinkHandler {
    static let habitsChangedNote = Notification.Name("HabitsDidChangeExternally")

    static func handle(_ url: URL) {
        guard url.scheme?.lowercased() == "healthyme" else { return }

        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let idStr = items.first(where: { $0.name == "id" })?.value
        let titleStr = items.first(where: { $0.name == "habit" })?.value

        let store: HabitsStoring = HabitsStore() // uses App Group now
        var habits = store.load()

        // 1) Find the habit
        var index: Int?
        if let idStr, let uuid = UUID(uuidString: idStr) {
            index = habits.firstIndex(where: { $0.id == uuid })
        } else if let titleStr {
            index = habits.firstIndex { $0.title == titleStr }
        }

        guard let i = index else { return }

        // 2) Toggle today
        habits[i].toggleToday()

        // 3) Persist and refresh widgets (same as your VM.persist())
        store.save(habits)

        // --- snapshot ---
        let stats = CheckHabitsViewModel.computeStats(for: habits, lastDays: 28)
        let snap = WidgetSnapshot(
            bestStreak: stats.bestStreak,
            completionRate: stats.todayRate,
            totalCompletions: stats.total
        )
        WidgetDataStore.save(snap)

        // --- pending lists (IDs + titles, aligned) ---
        if let ud = UserDefaults(suiteName: SharedIDs.appGroup) {
            let pendingPairs = habits.filter { !$0.isCompletedToday }
                .prefix(2)
                .map { ["id": $0.id.uuidString, "title": $0.title.trimmingCharacters(in: .whitespacesAndNewlines)] }
            ud.set(pendingPairs, forKey: "hm.widget.pendingPairs.v1")
        }

        WidgetCenter.shared.reloadAllTimelines()

        // 4) Make the app UI update + jump to Check tab
        UserDefaults.standard.set(0, forKey: "hm.selectedTab") // Check tab
        NotificationCenter.default.post(name: habitsChangedNote, object: nil)
    }
}
