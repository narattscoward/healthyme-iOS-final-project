// Models/UserSettings.swift
import Foundation

// MARK: - App Theme
enum AppTheme: String, CaseIterable, Codable, Identifiable {
    case system = "System"
    case light  = "Light"
    case dark   = "Dark"
    var id: String { rawValue }
}

// MARK: - Gender
enum AppGender: String, CaseIterable, Codable, Identifiable {
    case preferNot = "Prefer not to say"
    case female    = "Female"
    case male      = "Male"
    case other     = "Other"
    var id: String { rawValue }
}

// MARK: - User Settings
struct UserSettings: Codable, Equatable {
    // Profile
    var displayName: String = "Username"
    var gender: AppGender = .preferNot
    var birthday: Date? = nil
    var heightCm: Double? = nil
    var weightKg: Double? = nil

    // App preferences
    var languageCode: String = "en"
    var theme: AppTheme = .light
    var notificationsEnabled: Bool = true
}
