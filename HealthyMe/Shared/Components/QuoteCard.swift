import SwiftUI

struct QuoteCard: View {
    let text: String?
    let author: String?
    let isLoading: Bool
    let error: String?
    let onRetry: () -> Void

    @EnvironmentObject private var languageManager: LanguageManager
    private var b: Bundle { languageManager.bundle }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quote of the Day")
                .font(.custom("SeoulHangangM", size: 15))
                .foregroundColor(.App.textSecondary)

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .leading)

            } else if let err = error {
                VStack(alignment: .leading, spacing: 6) {
                    Text(err)
                        .font(.custom("SeoulHangangM", size: 15))
                        .foregroundColor(.App.textSecondary)

                    // ✅ Only this line changed — localized “Try again” button
                    Button(L("button.tryAgain", b), action: onRetry)
                        .font(.custom("SeoulHangangEB", size: 15))
                        .foregroundColor(.App.primary)
                }

            } else if let quote = text, !quote.isEmpty {
                Text("“\(quote)”")
                    .font(.custom("SeoulHangangM", size: 16))
                    .foregroundColor(.App.textPrimary)
                    .multilineTextAlignment(.leading)

                HStack {
                    Spacer()
                    Text("— \(author?.isEmpty == false ? author! : "Unknown")")
                        .font(.custom("SeoulHangangL", size: 14))
                        .foregroundColor(.App.textSecondary)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.App.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.App.card.opacity(0.7), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.vertical, 2)
    }
}

#Preview {
    QuoteCard(
        text: "Discipline is the bridge between goals and accomplishment. Make it a daily habit.",
        author: "Jim Rohn",
        isLoading: false,
        error: nil,
        onRetry: {}
    )
    .padding()
    .background(Color.App.background)
    .environmentObject(LanguageManager()) // preview needs it
}
