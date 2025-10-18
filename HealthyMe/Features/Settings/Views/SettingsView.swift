import SwiftUI

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .font(.custom("SeoulHangangEB", size: 24))
            .foregroundColor(.App.textPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.App.background)
    }
}
