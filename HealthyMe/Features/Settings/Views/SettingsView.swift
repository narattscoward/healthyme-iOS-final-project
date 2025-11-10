import SwiftUI

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var languageManager: LanguageManager

    // Overlay states
    @State private var showTermsOverlay = false
    @State private var showHelpOverlay  = false

    private var b: Bundle { languageManager.bundle }
    private var overlayActive: Bool { showTermsOverlay || showHelpOverlay }

    // MARK: - Helpers
    private func themeLabel(_ theme: AppTheme) -> String {
        switch theme {
        case .system: return L("theme.system", b)
        case .light:  return L("theme.light", b)
        case .dark:   return L("theme.dark", b)
        }
    }

    private var languagePillText: String {
        switch vm.settings.languageCode {
        case "my": return L("language.burmese", b)
        default:   return L("language.english", b)
        }
    }

    var body: some View {
        ZStack {
            // ===== MAIN CONTENT =====
            ScrollView {
                VStack(spacing: 16) {

                    // PROFILE
                    NavigationLink {
                        ProfileView(settings: $vm.settings, onSave: vm.save)
                    } label: {
                        Card {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle().fill(Color.App.card).frame(width: 56, height: 56)
                                    Image(systemName: "person.crop.circle")
                                        .font(.system(size: 28))
                                        .foregroundColor(.App.primary)
                                }
                                Text(vm.settings.displayName.isEmpty
                                     ? L("profile.username.fallback", b)
                                     : vm.settings.displayName)
                                    .font(.custom("SeoulHangangEB", size: 20))
                                    .foregroundColor(.App.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.App.textSecondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    // PREFERENCES (Language + Theme)
                    Card(spacing: 0) {

                        // Language
                        LabeledRow(label: L("settings.language", b)) {
                            Spacer(minLength: 12)
                            Menu {
                                Button(L("language.english", b)) { vm.setLanguage("en") }
                                Button(L("language.burmese", b)) { vm.setLanguage("my") }
                            } label: {
                                ValuePill(languagePillText)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 12)

                        Divider().overlay(Color.black.opacity(0.06))

                        // Theme
                        LabeledRow(label: L("settings.theme", b)) {
                            Spacer(minLength: 12)
                            Menu {
                                ForEach(AppTheme.allCases) { theme in
                                    Button(themeLabel(theme)) { vm.setTheme(theme) }
                                }
                            } label: {
                                ValuePill(themeLabel(vm.settings.theme))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 12)
                    }

                    // NOTIFICATIONS
                    Card {
                        LabeledToggleRow(
                            label: L("settings.notifications", b),
                            isOn: Binding(
                                get: { vm.settings.notificationsEnabled },
                                set: { vm.setNotificationsEnabled($0) }
                            ),
                            labelWidth: 150 // 140–170 works well for Burmese
                        )
                    }

                    // LINKS → alert-style overlays
                    Card(spacing: 0) {
                        Button { withAnimation(.spring(response: 0.25)) { showTermsOverlay = true } } label: {
                            ArrowRow(title: L("settings.terms", b))
                        }
                        .buttonStyle(.plain)

                        Divider().overlay(Color.black.opacity(0.06))

                        Button { withAnimation(.spring(response: 0.25)) { showHelpOverlay = true } } label: {
                            ArrowRow(title: L("settings.help", b))
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .scrollIndicators(.hidden)
            .background(Color.App.background.ignoresSafeArea())

            // ===== OVERLAYS (AlertCard) =====
            // Terms
            AlertCard(
                isPresented: $showTermsOverlay,
                title: L("settings.terms", b),
                primaryButtonTitle: L("common.ok", b),
                onPrimary: {}
            ) {
                Text(L("terms.body", b))
                    .font(.custom("SeoulHangangM", size: 15))
                    .foregroundColor(.App.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }

            // Help
            AlertCard(
                isPresented: $showHelpOverlay,
                title: L("settings.help", b),
                primaryButtonTitle: L("common.ok", b),
                onPrimary: {}
            ) {
                Text(L("help.body", b))
                    .font(.custom("SeoulHangangM", size: 15))
                    .foregroundColor(.App.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
        }
        // MARK: - View events
        .onAppear { vm.refreshNotificationToggleFromSystem() }
        .onChange(of: vm.settings.theme, initial: false) { _, newTheme in
            themeManager.theme = newTheme
        }
        .onChange(of: vm.settings.languageCode, initial: false) { _, code in
            languageManager.languageCode = code
        }
        .alert(
            L("settings.notifications.off.title", b),
            isPresented: $vm.showNotificationDeniedAlert
        ) {
            Button(L("common.ok", b), role: .cancel) { }
        } message: {
            Text(L("settings.notifications.off.message", b))
        }
        // Hide tab bar when overlay is shown
        .toolbar(overlayActive ? .hidden : .visible, for: .tabBar)
    }
}

// MARK: - Small components

private struct Card<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content
    init(spacing: CGFloat = 12, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) { content }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.App.card)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ValuePill: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.custom("SeoulHangangM", size: 16))
                .foregroundColor(.App.textSecondary)
            Image(systemName: "chevron.down")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.App.textSecondary)
        }
        .frame(height: 20)
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
    }
}

private struct ArrowRow: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("SeoulHangangM", size: 16))
                .foregroundColor(.App.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.App.textSecondary)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 12)
    }
}
