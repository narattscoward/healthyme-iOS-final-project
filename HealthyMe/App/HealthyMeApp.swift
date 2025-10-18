import SwiftUI

@main
struct HealthyMeApp: App {
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            router.currentView()
                .environmentObject(router)
        }
    }
}
