import SwiftUI

final class AppRouter: ObservableObject {
    // show lock first; we'll flip this to false after Face ID
    @Published var isLocked: Bool = true

    @ViewBuilder
    func currentView() -> some View {
        if isLocked {
            LockScreenView()
        } else {
            MainTabView()
        }
    }
}
