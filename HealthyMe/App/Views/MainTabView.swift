import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            CheckView()
                .tabItem { Label("Check", systemImage: "checklist") }

            ProgressViewPage()
                .tabItem { Label("Progress", systemImage: "chart.bar") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(Color.App.primary)
    }
}
