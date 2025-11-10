import SwiftUI
import LocalAuthentication

struct LockScreenView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject private var languageManager: LanguageManager
    private var b: Bundle { languageManager.bundle }

    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            Color.App.background.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                Image(systemName: "leaf.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.App.primary)
                    .symbolEffect(.bounce, value: progress > 0)

                // Brand name — keep not localized
                Text("HealthyMe")
                    .font(.custom("SeoulHangangEB", size: 34))
                    .foregroundColor(.App.primary)

                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(.App.primary)
                    .frame(width: 260)

                Spacer()
            }
            .padding()
        }
        // Make formatters respect chosen locale (future-proof)
        .environment(\.locale, languageManager.locale)
        // Ensure view updates if language changes while it’s shown
        .id(languageManager.languageCode)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8)) { progress = 1.0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                authenticate()
            }
        }
    }

    private func authenticate() {
        let ctx = LAContext()
        var err: NSError?

        if ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) {
            ctx.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: L("auth.reason", b)
            ) { success, _ in
                DispatchQueue.main.async {
                    // For now, allow pass-through either way (simulator/dev flow)
                    router.isLocked = false
                }
            }
        } else {
            // No biometrics (e.g. simulator)
            router.isLocked = false
        }
    }
}
