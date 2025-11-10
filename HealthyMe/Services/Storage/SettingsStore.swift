import Foundation

protocol SettingsStoring {
    func load() -> UserSettings
    func save(_ settings: UserSettings)
}

final class SettingsStore: SettingsStoring {
    private let key = "HealthyMe.settings.v1"

    func load() -> UserSettings {
        guard let data = UserDefaults.standard.data(forKey: key),
              let s = try? JSONDecoder().decode(UserSettings.self, from: data) else {
            return UserSettings()
        }
        return s
    }

    func save(_ settings: UserSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
