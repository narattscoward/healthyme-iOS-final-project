import Foundation
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: UserSettings
    @Published var showNotificationDeniedAlert = false

    private let store: SettingsStoring
    private let habitsStore: HabitsStoring

    init(store: SettingsStoring = SettingsStore(),
         habitsStore: HabitsStoring = HabitsStore()) {
        self.store = store
        self.habitsStore = habitsStore
        self.settings = store.load()
        refreshNotificationToggleFromSystem()
    }

    func save() { store.save(settings) }

    // MARK: - Language / Theme
    func setLanguage(_ code: String) {
        settings.languageCode = code
        save()
    }

    func setTheme(_ theme: AppTheme) {
        settings.theme = theme
        save()                           // ← persist choice
        // ThemeManager is updated from SettingsView (see below).
    }

    // MARK: - Notifications
    func refreshNotificationToggleFromSystem() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] s in
            Task { @MainActor in
                guard let self else { return }
                let on = (s.authorizationStatus == .authorized ||
                          s.authorizationStatus == .provisional ||
                          s.authorizationStatus == .ephemeral)
                self.settings.notificationsEnabled = on
            }
        }
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        if enabled {
            NotificationService.shared.requestAuthorizationIfNeeded { [weak self] granted in
                Task { @MainActor in
                    guard let self else { return }
                    if granted {
                        self.settings.notificationsEnabled = true
                        self.save()
                        let habits = self.habitsStore.load()
                        NotificationService.shared.syncAll(habits)
                    } else {
                        self.settings.notificationsEnabled = false
                        self.save()
                        self.showNotificationDeniedAlert = true
                    }
                }
            }
        } else {
            settings.notificationsEnabled = false
            save()
            NotificationService.shared.cancelAll()
        }
    }

    // MARK: - Helpers
    var languageDisplay: String {
        switch settings.languageCode {
        case "en":
            return String(localized: "language.english")
        case "my":
            return String(localized: "language.burmese")
        default:
            return settings.languageCode.uppercased()
        }
    }
}
