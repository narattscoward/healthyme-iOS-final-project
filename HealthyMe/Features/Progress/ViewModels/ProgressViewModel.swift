import Foundation

final class ProgressViewModel: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    private let store: HabitsStoring

    /// How many weeks back to show; 0 = last 2 weeks ending today.
    @Published var weeksBack: Int = 0

    init(store: HabitsStoring = HabitsStore()) {
        self.store = store
        self.habits = store.load()
    }

    func reloadFromDisk() {
        self.habits = store.load()
    }

    // MARK: - Grid days (last 14 days window)
    var daysWindow: [Date] {
        // We show 14 days ending on the last day of the selected window.
        // Align the window to today minus weeksBack*7 days.
        let end = Date().addingDays(-(weeksBack * 7)).startOfDayLocal
        let start = end.addingDays(-13)
        var days: [Date] = []
        var d = start
        while d <= end {
            days.append(d)
            d = d.addingDays(1)
        }
        return days
    }

    // MARK: - Stats
    func isDone(_ habit: Habit, on date: Date) -> Bool {
        habit.isCompleted(on: date)
    }

    func completionRate(_ habit: Habit, in days: [Date]) -> Double {
        guard !days.isEmpty else { return 0 }
        let done = days.filter { isDone(habit, on: $0) }.count
        return Double(done) / Double(days.count)
    }

    func currentStreak(_ habit: Habit, upTo endDate: Date = Date()) -> Int {
        var streak = 0
        var d = endDate.startOfDayLocal
        while isDone(habit, on: d) {
            streak += 1
            d = d.addingDays(-1)
        }
        return streak
    }

    func bestStreak(_ habit: Habit, lookback daysBack: Int = 180) -> Int {
        // Quick estimate: scan the last N days and find the max consecutive run.
        var best = 0
        var cur = 0
        var d = Date().addingDays(-daysBack).startOfDayLocal
        let today = Date().startOfDayLocal
        while d <= today {
            if isDone(habit, on: d) {
                cur += 1
                best = max(best, cur)
            } else {
                cur = 0
            }
            d = d.addingDays(1)
        }
        return best
    }
}
