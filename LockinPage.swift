//
//  LockinPage.swift
//  Final_Project
//
//  Created by Wyne Nadi on 18/10/2568 BE.
//

import SwiftUI
import LocalAuthentication


struct LockinPage: View {
    @AppStorage("isUnlocked") private var isUnlocked = false
    
    var body: some View {
        if isUnlocked {
            HomeView()
        } else {
            SplashAuthView()
        }
    }
}

// Splash Screen + Face ID
struct SplashAuthView : View {
    @State private var progress: CGFloat = 0
    @State private var authError: String?
    @AppStorage("isUnlocked") private var isUnlocked = false
    
    var body : some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 28) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 90, weight: .bold))
                    .foregroundStyle(Color.green)
                
                Text("HealthyMe")
                    .font(.system(size: 90, weight: .bold))
                    .foregroundStyle(Color.green)
                
                ProgressBar(progress : progress)
                    .frame(height: 8)
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                
                if let authError {
                    Text(authError)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.top, 6)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                authenticate()
            }
        }
    }
    
    private func authenticate() {
        let ctx = LAContext()
        var error : NSError?
        
        let policy : LAPolicy = .deviceOwnerAuthenticationWithBiometrics
        
        guard ctx.canEvaluatePolicy(policy, error: &error) else {
            fillAndEnter()
            return
        }
        
        let reason = "Unlock HealthyMe"
        ctx.evaluatePolicy(policy, localizedReason: reason) { success, evalError in
            DispatchQueue.main.async {
                if success {
                    self.fillAndEnter()
                } else {
                    self.authError = (evalError as NSError?)?.localizedDescription ?? "Authentication failed. Try again!!"
                }
            }
        }
    }
    
    private func fillAndEnter() {
        withAnimation(.easeInOut(duration: 0.8)) { progress = 1.0}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            isUnlocked = true
        }
    }
}

struct ProgressBar : View {
    var progress : CGFloat
    
    var body : some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                Capsule()
                    .fill(Color.green)
                    .frame(width: max(0, min(progress, 1)) * geo.size.width)
                    .animation(.easeInOut(duration: 0.6), value: progress)
            }
        }
        .clipShape(Capsule())
    }
}

struct HomeView : View {
    
    var body : some View {
        VStack(spacing: 20) {
            
            Text("🌿")
                .font(.system(size: 80))
                .foregroundColor(Color(hexCode : "#A8E6CF"))

            Text("Welcome to HeathyMe 🌿")
                .font(.title2).bold()
                .foregroundColor(Color(hexCode : "#A8E6CF"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    LockinPage()
}
