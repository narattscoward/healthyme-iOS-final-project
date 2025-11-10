import SwiftUI

struct ProfileView: View {
    @Binding var settings: UserSettings
    var onSave: () -> Void
    @State private var draft: UserSettings
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager

    init(settings: Binding<UserSettings>, onSave: @escaping () -> Void) {
        self._settings = settings
        self.onSave = onSave
        _draft = State(initialValue: settings.wrappedValue)
    }

    // Compare against the wrapped value
    private var isDirty: Bool { draft != settings }

    // Current language bundle shortcut
    private var b: Bundle { languageManager.bundle }

    @ViewBuilder private func hairline() -> some View {
        Divider().overlay(Color.black.opacity(0.06))
    }
    
    // ↓ helper that localizes enum cases
    private func genderLabel(_ g: AppGender) -> String {
        switch g {
        case .male:
            return L("gender.male", b)
        case .female:
            return L("gender.female", b)
        case .other:
            return L("gender.other", b)
        case .preferNot:
            return L("gender.preferNot", b)
        }
    }

    private let rowHeight: CGFloat = 36

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // (keep your header card as-is)

                // Details card
                VStack(spacing: 0) {
                    // Name
                    LabeledRow(label: L("profile.name", b)) {
                        TextField(
                            "",
                            text: Binding(
                                get: { draft.displayName },
                                set: { draft.displayName = $0 }
                            ),
                            prompt: Text(L("profile.username.fallback", b))
                                .font(.custom("SeoulHangangM", size: 16))
                        )
                        .font(.custom("SeoulHangangM", size: 16))
                        .multilineTextAlignment(.trailing)
                        .frame(height: rowHeight)
                    }

                    hairline()

                    // Gender
                    LabeledRow(label: L("profile.gender", b)) {
                        Spacer(minLength: 12)
                        Picker(selection: $draft.gender) {
                            ForEach(AppGender.allCases) { g in
                                Text(genderLabel(g)).tag(g)          // ← localized in the menu
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(genderLabel(draft.gender))       // ← localized pill text
                                    .font(.custom("SeoulHangangM", size: 16))
                                    .foregroundColor(.App.textSecondary)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.App.textSecondary)
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                        }
                        .pickerStyle(.menu)
                        .controlSize(.small)
                        .frame(height: rowHeight)
                    }

                    hairline()

                    // Birthday
                    LabeledRow(label: L("profile.birthday", b)) {
                        Spacer(minLength: 12)
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { draft.birthday ?? Date() },
                                set: { draft.birthday = $0 }
                            ),
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .tint(Color.App.primary)
                        .controlSize(.small)
                        .frame(height: rowHeight)
                    }
                    .padding(.vertical, 2)

                    hairline()

                    // Height (cm)
                    LabeledRow(label: L("profile.height", b), labelWidth: 200) {
                        TextField(
                            "",
                            value: $draft.heightCm,
                            format: .number,
                            prompt: Text(L("placeholder.height", b))
                                .font(.custom("SeoulHangangM", size: 16))
                                .foregroundColor(.App.textSecondary.opacity(0.6))
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(.custom("SeoulHangangM", size: 16))
                        .frame(height: rowHeight)
                    }

                    hairline()

                    // Weight (kg)
                    LabeledRow(label: L("profile.weight", b), labelWidth: 200) {
                        TextField(
                            "",
                            value: $draft.weightKg,
                            format: .number,
                            prompt: Text(L("placeholder.weight", b))
                                .font(.custom("SeoulHangangM", size: 16))
                                .foregroundColor(.App.textSecondary.opacity(0.6))
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(.custom("SeoulHangangM", size: 16))
                        .frame(height: rowHeight)
                    }
                }
                .cardStyle()

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .scrollIndicators(.hidden)
        .background(Color.App.background.ignoresSafeArea())
        .navigationTitle(L("navigation.profile.title", b))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isDirty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("button.save", b)) {
                        settings = draft
                        onSave()
                        dismiss()
                    }
                    .font(.custom("SeoulHangangEB", size: 16))
                    .foregroundColor(.App.primary)
                }
            }
        }
    }
}
