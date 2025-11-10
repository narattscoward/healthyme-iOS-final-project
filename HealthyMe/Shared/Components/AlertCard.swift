import SwiftUI

/// A reusable, center-screen alert-style card with a dimmed backdrop.
/// - Blocks outside taps (only dismisses via the primary button)
/// - No "X" close icon
/// - Scrolls if content is long
public struct AlertCard<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    let primaryButtonTitle: String
    let onPrimary: () -> Void
    let content: Content

    public init(
        isPresented: Binding<Bool>,
        title: String,
        primaryButtonTitle: String,
        onPrimary: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.title = title
        self.primaryButtonTitle = primaryButtonTitle
        self.onPrimary = onPrimary
        self.content = content()
    }

    public var body: some View {
        ZStack {
            if isPresented {
                // Dim backdrop
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { /* block background taps */ }

                // Card content
                VStack(spacing: 16) {
                    Text(title)
                        .font(.custom("SeoulHangangEB", size: 18))
                        .foregroundColor(.App.primary)
                        .multilineTextAlignment(.center)

                    ScrollView {
                        content
                            .font(.custom("SeoulHangangM", size: 15))
                            .foregroundColor(.App.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(6) // ✅ Added: better vertical spacing for Burmese
                            .padding(.top,8)
                    }
                    .frame(minHeight: 60, maxHeight: 220)

                    Button {
                        onPrimary()
                        isPresented = false
                    } label: {
                        Text(primaryButtonTitle)
                            .font(.custom("SeoulHangangEB", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.App.primary)
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
                .frame(maxWidth: 340)
                .background(Color.App.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: isPresented)
    }
}
