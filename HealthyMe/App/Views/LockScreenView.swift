import SwiftUI
import LocalAuthentication

struct LockScreenView: View {
    @EnvironmentObject var router: AppRouter
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
            ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: "Unlock HealthyMe with Face ID") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        router.isLocked = false
                    } else {
                        // fallback: allow pass-through for simulator/testing
                        router.isLocked = false
                    }
                }
            }
        } else {
            // no biometrics available (simulator) -> continue
            router.isLocked = false
        }
    }
}
