import Foundation

protocol HabitsStoring {
    func load() -> [Habit]
    func save(_ habits: [Habit])
}

final class HabitsStore: HabitsStoring {
    private let key = "HealthyMe.habits.v1"

    func load() -> [Habit] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Habit].self, from: data)) ?? []
    }

    func save(_ habits: [Habit]) {
        let data = try? JSONEncoder().encode(habits)
        UserDefaults.standard.set(data, forKey: key)
    }
}
