import SwiftUI
import WidgetKit

@main
struct HealthyMeApp: App {
    private let settingsStore: SettingsStoring = SettingsStore()

    @StateObject private var themeManager: ThemeManager
    @StateObject private var languageManager: LanguageManager
    @StateObject private var router = AppRouter()
    @StateObject private var habitsVM = CheckHabitsViewModel() // ← shared VM

    init() {
        let saved = settingsStore.load()
        _themeManager = StateObject(wrappedValue: ThemeManager(initial: saved.theme))
        _languageManager = StateObject(wrappedValue: LanguageManager(initialCode: saved.languageCode))
    }

    var body: some Scene {
        WindowGroup {
            router.currentView()
                .environmentObject(router)
                .environmentObject(themeManager)
                .environmentObject(languageManager)
                .environmentObject(habitsVM)
                .preferredColorScheme(themeManager.colorScheme)
                .environment(\.locale, languageManager.locale)
                .onAppear {
                    themeManager.applyAppearance()
                }
                // 👇 Handle when widget habit tapped
                .onOpenURL { url in
                    DeepLinkHandler.handle(url)   // <- just delegate to the handler
                }
        }
    }
}
