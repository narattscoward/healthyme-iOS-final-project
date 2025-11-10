// Services/NotificationService.swift
import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let center = UNUserNotificationCenter.current()
    private let requestKey = "hasRequestedNotificationAuth"

    // MARK: - Auth
    /// Ask once, then remember. If already determined, this is a no-op.
    func requestAuthorizationIfNeeded(completion: ((Bool) -> Void)? = nil) {
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    UserDefaults.standard.set(true, forKey: self.requestKey)
                    DispatchQueue.main.async { completion?(granted) }
                }
            default:
                let granted = (settings.authorizationStatus == .authorized ||
                               settings.authorizationStatus == .provisional ||
                               settings.authorizationStatus == .ephemeral)
                DispatchQueue.main.async { completion?(granted) }
            }
        }
    }

    // MARK: - Public API
    func sync(for habit: Habit) {
        // no time or notify = false → cancel
        guard habit.notify,
              let comps = habit.time,
              let hour = comps.hour,
              let minute = comps.minute else {
            cancel(for: habit.id)
            return
        }

        requestAuthorizationIfNeeded { _ in
            self.scheduleDaily(id: habit.id, title: habit.title, hour: hour, minute: minute)
        }
    }

    func syncAll(_ habits: [Habit]) {
        for h in habits { sync(for: h) }
    }

    func cancel(for id: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier(for: id)])
    }

    func cancel(ids: [UUID]) {
        let identifiers = ids.map(Self.identifier(for:))
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    // MARK: - Internals
    private func scheduleDaily(id: UUID, title: String, hour: Int, minute: Int) {
        cancel(for: id)

        let content = UNMutableNotificationContent()
        content.title = "HealthyMe"
        content.body  = title
        content.sound = .default

        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        let request = UNNotificationRequest(
            identifier: Self.identifier(for: id),
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error { print("🔔 schedule error:", error.localizedDescription) }
        }
    }

    private static func identifier(for id: UUID) -> String {
        "habit.\(id.uuidString)"
    }
}
