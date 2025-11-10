// HabitsStore.swift
import Foundation

protocol HabitsStoring {
    func load() -> [Habit]
    func save(_ habits: [Habit])
}

final class HabitsStore: HabitsStoring {
    // Old key (was using .standard)
    private let oldKey = "HealthyMe.habits.v1"
    // New key inside App Group
    private let newKey = "hm.habits.v2"

    // App Group user defaults (shared with the widget)
    private let ud: UserDefaults

    init() {
        // ⚠️ Requires your SharedIDs.appGroup to be correct and the capability added.
        guard let sharedUD = UserDefaults(suiteName: SharedIDs.appGroup) else {
            // Absolute fallback; avoids crash if misconfigured, but won’t sync with widget.
            self.ud = .standard
            return
        }
        self.ud = sharedUD
        migrateIfNeeded()
    }

    func load() -> [Habit] {
        guard let data = ud.data(forKey: newKey) else { return [] }
        return (try? JSONDecoder().decode([Habit].self, from: data)) ?? []
    }

    func save(_ habits: [Habit]) {
        guard let data = try? JSONEncoder().encode(habits) else { return }
        ud.set(data, forKey: newKey)
    }

    // MARK: - One-time migration from .standard → App Group
    private func migrateIfNeeded() {
        // If we already have data in the app group, nothing to do.
        if ud.data(forKey: newKey) != nil { return }

        // Pull any legacy payload from .standard with the old key.
        if let legacyData = UserDefaults.standard.data(forKey: oldKey) {
            // Copy to the shared container
            ud.set(legacyData, forKey: newKey)
            // (Optional) clear the legacy copy
            // UserDefaults.standard.removeObject(forKey: oldKey)
        }
    }
}
