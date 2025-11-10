import Foundation

struct Habit: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var time: DateComponents?
    var notify: Bool
    var notes: String

    /// Multi-day completion history. Keys are "yyyy-MM-dd".
    var completedDays: Set<String>

    /// Legacy field you already had; kept for migration/back-compat.
    var lastCompletedOn: Date?

    init(id: UUID = UUID(),
         title: String,
         time: DateComponents? = nil,
         notify: Bool = false,
         notes: String = "",
         completedDays: Set<String> = [],
         lastCompletedOn: Date? = nil) {
        self.id = id
        self.title = title
        self.time = time
        self.notify = notify
        self.notes = notes
        self.completedDays = completedDays
        self.lastCompletedOn = lastCompletedOn
    }

    // MARK: - Keys & helpers

    static func dayKey(_ date: Date = Date()) -> String {
        Self.df.string(from: date)
    }

    var isCompletedToday: Bool {
        completedDays.contains(Self.dayKey())
    }

    mutating func toggleToday() {
        let k = Self.dayKey()
        if completedDays.contains(k) {
            completedDays.remove(k)
            lastCompletedOn = nil
        } else {
            completedDays.insert(k)
            lastCompletedOn = Date()
        }
    }

    mutating func mark(_ date: Date) {
        completedDays.insert(Self.dayKey(date))
    }

    mutating func unmark(_ date: Date) {
        completedDays.remove(Self.dayKey(date))
        if Calendar.current.isDateInToday(date) { lastCompletedOn = nil }
    }

    // Shared date formatter (POSIX)
    private static let df: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}
