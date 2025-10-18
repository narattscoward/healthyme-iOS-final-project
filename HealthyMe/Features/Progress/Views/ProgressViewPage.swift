import SwiftUI

struct ProgressViewPage: View {
    var body: some View {
        Text("Progress")
            .font(.custom("SeoulHangangEB", size: 24))
            .foregroundColor(.App.textPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.App.background)
    }
}
