import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    private var b: Bundle { languageManager.bundle }

    // Shared habits VM for all tabs
    @StateObject private var habitsVM = CheckHabitsViewModel()

    @AppStorage("hm.selectedTab") private var selectedTab: Int = 0

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .font: UIFont(name: "SeoulHangangEB", size: 34)!,
            .foregroundColor: UIColor(Color.App.primary)
        ]
        appearance.titleTextAttributes = [
            .font: UIFont(name: "SeoulHangangEB", size: 20)!,
            .foregroundColor: UIColor(Color.App.primary)
        ]
        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance    = appearance
        UINavigationBar.appearance().tintColor            = UIColor(Color.App.primary)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CheckView()
                    .navigationTitle(Text(L("nav.dailyHabits", b)))
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem { Label { Text(L("tab.check", b)) } icon: { Image(systemName: "checklist") } }
            .tag(0)

            NavigationStack {
                ProgressViewPage()
                    .navigationTitle(Text(L("nav.progress", b)))
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem { Label { Text(L("tab.progress", b)) } icon: { Image(systemName: "chart.bar") } }
            .tag(1)

            NavigationStack {
                SettingsView()
                    .navigationTitle(Text(L("nav.settings", b)))
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem { Label { Text(L("tab.settings", b)) } icon: { Image(systemName: "gearshape") } }
            .tag(2)
        }
        .environmentObject(habitsVM)                  // ← inject once
        .environment(\.locale, languageManager.locale)
        .tint(Color.App.primary)
    }
}
