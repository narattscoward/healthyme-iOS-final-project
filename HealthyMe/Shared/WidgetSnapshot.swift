// Shared/WidgetSnapshot.swift
import Foundation

public struct WidgetSnapshot: Codable {
    public let date: Date
    public let bestStreak: Int
    public let completionRate: Double   // 0…1 (use "today" rate)
    public let totalCompletions: Int
    public let pendingTitles: [String]  // NEW: up to 2 habits not done today

    public init(
        date: Date = Date(),
        bestStreak: Int,
        completionRate: Double,
        totalCompletions: Int,
        pendingTitles: [String] = []
    ) {
        self.date = date
        self.bestStreak = bestStreak
        self.completionRate = completionRate
        self.totalCompletions = totalCompletions
        self.pendingTitles = pendingTitles
    }

    // Backward-compatible decode so older snapshots without `pendingTitles` still load.
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        date = (try? c.decode(Date.self, forKey: .date)) ?? Date()
        bestStreak = try c.decode(Int.self, forKey: .bestStreak)
        completionRate = try c.decode(Double.self, forKey: .completionRate)
        totalCompletions = try c.decode(Int.self, forKey: .totalCompletions)
        pendingTitles = (try? c.decode([String].self, forKey: .pendingTitles)) ?? []
    }
}

// Simple shared store
public enum WidgetDataStore {
    public static func save(_ snapshot: WidgetSnapshot) {
        guard let ud = UserDefaults(suiteName: SharedIDs.appGroup),
              let data = try? JSONEncoder().encode(snapshot) else { return }
        ud.set(data, forKey: WidgetKeys.snapshot)
    }

    public static func load() -> WidgetSnapshot? {
        guard let ud = UserDefaults(suiteName: SharedIDs.appGroup),
              let data = ud.data(forKey: WidgetKeys.snapshot),
              let snap = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else { return nil }
        return snap
    }
}
