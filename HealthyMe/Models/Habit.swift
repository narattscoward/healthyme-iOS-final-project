import Foundation

struct Habit: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var time: DateComponents?
    var notify: Bool
    var notes: String
    var lastCompletedOn: Date?

    init(id: UUID = UUID(),
         title: String,
         time: DateComponents? = nil,
         notify: Bool = false,
         notes: String = "",
         lastCompletedOn: Date? = nil) {
        self.id = id
        self.title = title
        self.time = time
        self.notify = notify
        self.notes = notes
        self.lastCompletedOn = lastCompletedOn
    }

    var isCompletedToday: Bool {
        guard let d = lastCompletedOn else { return false }
        return Calendar.current.isDateInToday(d)
    }
}
