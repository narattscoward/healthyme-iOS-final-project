import Foundation
import SwiftUI   // for Binding

final class CheckHabitsViewModel: ObservableObject {
    @Published private(set) var habits: [Habit] = []
    private let store: HabitsStoring
    private let notifier = NotificationService.shared

    init(store: HabitsStoring = HabitsStore()) {
        self.store = store
        self.habits = store.load()
        // Optionally resync all on launch (uncomment if you want)
        // notifier.syncAll(habits)
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
        habits[idx].lastCompletedOn = habits[idx].isCompletedToday ? nil : Date()
        persist()
        // no notification change needed on completion toggle
    }

    func delete(at offsets: IndexSet) {
        // Explicitly tell Swift what type we're mapping to
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

    // MARK: - Persistence
    private func persist() { store.save(habits) }

    // MARK: - Safe id-based binding
    /// Returns a safe binding looked up by id.
    /// Setter persists and syncs notification for that habit.
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
                    self.notifier.sync(for: newValue)  // <- sync on every edit (time/title/notify)
                }
            }
        )
    }
}
