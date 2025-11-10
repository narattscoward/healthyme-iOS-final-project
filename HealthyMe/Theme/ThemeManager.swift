import SwiftUI

final class ThemeManager: ObservableObject {
    @Published var theme: AppTheme {
        didSet { applyAppearance() }
    }

    var colorScheme: ColorScheme? {
        switch theme {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    init(initial: AppTheme = .system) {
        self.theme = initial
        applyAppearance()
    }

    /// Re-apply navigation (and optional tab) appearance when theme flips.
    func applyAppearance() {
        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.largeTitleTextAttributes = [
            .font: UIFont(name: "SeoulHangangEB", size: 34)!,
            .foregroundColor: UIColor(Color.App.textPrimary)
        ]
        nav.titleTextAttributes = [
            .font: UIFont(name: "SeoulHangangEB", size: 20)!,
            .foregroundColor: UIColor(Color.App.textPrimary)
        ]
        UINavigationBar.appearance().standardAppearance    = nav
        UINavigationBar.appearance().scrollEdgeAppearance  = nav
        UINavigationBar.appearance().compactAppearance     = nav
        UINavigationBar.appearance().tintColor             = UIColor(Color.App.primary)

        // (Optional) Tab bar styling tied to your color set
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = UIColor(Color.App.card)
        UITabBar.appearance().standardAppearance    = tab
        UITabBar.appearance().scrollEdgeAppearance  = tab
    }
}
