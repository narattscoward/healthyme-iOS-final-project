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
                    completion?(granted)
                }
            default:
                completion?(settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
            }
        }
    }

    // MARK: - Public API

    /// Bring a single habit’s notification into the correct state
    func sync(for habit: Habit) {
        // no time or notify = false → cancel
        guard habit.notify, let comps = habit.time, let hour = comps.hour, let minute = comps.minute else {
            cancel(for: habit.id)
            return
        }

        // ensure permission first, then schedule
        requestAuthorizationIfNeeded { _ in
            self.scheduleDaily(id: habit.id, title: habit.title, hour: hour, minute: minute)
        }
    }

    /// Reschedule everything (useful on app launch if you want)
    func syncAll(_ habits: [Habit]) {
        for h in habits { sync(for: h) }
    }

    /// Cancel a single habit’s notification
    func cancel(for id: UUID) {
        let identifier = Self.identifier(for: id)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Cancel many by ids
    func cancel(ids: [UUID]) {
        let identifiers = ids.map(Self.identifier(for:))
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Internals

    private func scheduleDaily(id: UUID, title: String, hour: Int, minute: Int) {
        // 1) Remove any previous request for this habit
        cancel(for: id)

        // 2) Content
        let content = UNMutableNotificationContent()
        content.title = "HealthyMe"
        content.body  = title    // keep it simple; can customize later
        content.sound = .default

        // 3) Trigger (repeats daily at selected time)
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        // 4) Request
        let request = UNNotificationRequest(
            identifier: Self.identifier(for: id),
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("🔔 schedule error:", error.localizedDescription)
            } else {
                // Debug pending
                // self.center.getPendingNotificationRequests { print("Pending:", $0.count) }
            }
        }
    }

    private static func identifier(for id: UUID) -> String {
        "habit.\(id.uuidString)"
    }
}
