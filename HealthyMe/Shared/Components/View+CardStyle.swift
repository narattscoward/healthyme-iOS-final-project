import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.App.card)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
