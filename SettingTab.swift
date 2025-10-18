//
//  SettingTab.swift
//  Final_Project
//
//  Created by Wyne Nadi on 18/10/2568 BE.
//

import SwiftUI
import Combine 

// Setting Tab
struct SettingTab: View {
    @StateObject private var vm = SettingsVM()
    private let mint = Color(hexCode: "#A8E6CF")
    
    var body: some View {
        NavigationStack {
                    List {
                        // Header: avatar + username
                        Section {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(mint.opacity(0.18))
                                        .frame(width: 56, height: 56)
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 34))
                                        .foregroundStyle(mint)
                                }
                                Text(vm.profile.name.isEmpty ? "Username" : vm.profile.name)
                                    .font(.title2.bold())
                                    .foregroundStyle(mint)
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }

                        // Main rows
                        Section {
                            // Profile
                            NavigationLink {
                                ProfileEditView(
                                    profile: vm.profile,
                                    mint: mint,
                                    onSave: { vm.profile = $0 }
                                )
                            } label: {
                                HStack {
                                    Text("Profile")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.tertiary)
                                }
                            }

                            // Language picker
                            HStack {
                                Text("Language")
                                Spacer()
                                Picker("", selection: $vm.language) {
                                    ForEach(AppLanguage.allCases) { lang in
                                        Text(lang.title).tag(lang)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(mint)
                            }

                            // Theme picker
                            HStack {
                                Text("Theme")
                                Spacer()
                                Picker("", selection: $vm.theme) {
                                    ForEach(AppTheme.allCases) { theme in
                                        Text(theme.title).tag(theme)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(mint)
                            }

                            // Notifications toggle
                            Toggle("Notifications", isOn: $vm.notificationsOn)
                                .tint(mint)
                        }

                        // Links / buttons
                        Section {
                            Button("Terms and Policy") { /* open terms screen / URL */ }
                            Button("Get Help") { /* help / support */ }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("Settings")
                    .toolbarTitleDisplayMode(.large)
                }
                .tint(mint)
    }
}

// Profile Edit
struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State var profile: UserProfile
    let mint: Color
    var onSave: (UserProfile) -> Void

    var body: some View {
        Form {
            // Avatar + action
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(mint.opacity(0.18))
                            .frame(width: 56, height: 56)
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 28))
                            .foregroundStyle(mint)
                    }
                    Button("Change your profile") {
                        // Add ImagePicker later
                    }
                    .foregroundStyle(mint)
                }
            }

            // Fields
            Section {
                TextField("Username", text: $profile.name)
                    .textInputAutocapitalization(.words)

                Picker("Gender", selection: $profile.gender) {
                    ForEach(Gender.allCases) { g in
                        Text(g.title).tag(g)
                    }
                }

                // Birthday pill
                HStack {
                    Text("Birthday")
                    Spacer()
                    DatePicker("", selection: $profile.birthday, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(mint.opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                TextField("Enter your height", text: $profile.height)
                    .keyboardType(.numbersAndPunctuation)

                TextField("Enter your weight", text: $profile.weight)
                    .keyboardType(.numbersAndPunctuation)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Settings") { dismiss() }
                    .foregroundStyle(mint)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    onSave(profile)
                    dismiss()
                }
                .foregroundStyle(mint)
            }
        }
    }
}

// View Model and Models
@MainActor
final class SettingsVM: ObservableObject {
    @Published var profile = UserProfile()
    @Published var language: AppLanguage = .english
    @Published var theme: AppTheme = .light
    @Published var notificationsOn: Bool = true
}

struct UserProfile: Hashable {
    var name: String = ""
    var gender: Gender = .preferNot
    var birthday: Date = Date()
    var height: String = ""
    var weight: String = ""
}

enum Gender: String, CaseIterable, Identifiable {
    case female, male, nonBinary, preferNot
    var id: String { rawValue }
    var title: String {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        case .nonBinary: return "Non-binary"
        case .preferNot: return "Prefer not to Say"
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english, thai, chinese, burmese
    var id: String { rawValue }
    var title: String {
        switch self {
        case .english: return "English"
        case .thai:    return "ไทย"
        case .chinese: return "中文"
        case .burmese: return "မြန်မာ"
        }
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case light, dark, system
    var id: String { rawValue }
    var title: String {
        switch self {
        case .light:  return "Light Theme"
        case .dark:   return "Dark Theme"
        case .system: return "System"
        }
    }
}

#Preview {
    SettingTab()
}
