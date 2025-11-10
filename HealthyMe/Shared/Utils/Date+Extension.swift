import Foundation

extension Date {
    /// Start of day in current calendar.
    var startOfDayLocal: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Add days (+/-).
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Weekday short symbol (Sun, Mon, ...)
    var weekdayShort: String {
        let idx = Calendar.current.component(.weekday, from: self) - 1 // 1..7 -> 0..6
        return Calendar.current.shortWeekdaySymbols[idx]
    }
}
