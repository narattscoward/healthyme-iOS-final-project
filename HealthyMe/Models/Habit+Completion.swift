import Foundation

extension Habit {
    /// Returns true if this habit was completed on the given calendar day.
    func isCompleted(on date: Date) -> Bool {
        completedDays.contains(Habit.dayKey(date))
    }
}
