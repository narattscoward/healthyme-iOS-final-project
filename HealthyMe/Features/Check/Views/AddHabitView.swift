import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CheckHabitsViewModel

    @State private var title: String = ""
    @State private var time: Date = Date()
    @State private var notify: Bool = true
    @State private var notes: String = ""

    private let labelWidth: CGFloat = 120

    var body: some View {
        ZStack {
            Color.App.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Grabber + Title
                VStack(spacing: 10) {
                    Capsule().fill(.secondary.opacity(0.25))
                        .frame(width: 36, height: 4)
                        .padding(.top, 8)

                    Text("Add a habit")
                        .font(.custom("SeoulHangangEB", size: 24))
                        .foregroundColor(.App.textPrimary)
                }
                .padding(.bottom, 6)

                ScrollView {
                    VStack(spacing: 18) {

                        // Card
                        VStack(spacing: 0) {
                            LabeledTextFieldRow(
                                label: "Habit",
                                text: $title,
                                placeholder: "Enter habit name",
                                labelWidth: labelWidth,
                                trailingAligned: true // like your spec
                            )

                            Divider().overlay(Color.black.opacity(0.06))

                            LabeledTimeRow(
                                date: $time,
                                labelWidth: labelWidth
                            )

                            Divider().overlay(Color.black.opacity(0.06))

                            LabeledToggleRow(
                                label: "Notification",
                                isOn: $notify,
                                labelWidth: labelWidth
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.98))
                                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
                        )

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.custom("SeoulHangangM", size: 16))
                                .foregroundColor(.App.textPrimary)
                                .padding(.horizontal, 6)

                            TextEditor(text: $notes)
                                .font(.custom("SeoulHangangM", size: 15))
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(minHeight: 150, alignment: .topLeading)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12).fill(Color.App.card)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.App.card.opacity(0.7), lineWidth: 1)
                                )
                                .padding(.horizontal, 6)
                        }

                        // Button directly under Description
                        Button {
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
                            let name = title.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !name.isEmpty else { return }
                            viewModel.add(title: name, time: comps, notify: notify, notes: notes)
                            dismiss()
                        } label: {
                            Text("Add Habit")
                                .font(.custom("SeoulHangangEB", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.App.primary)
                                .clipShape(Capsule())
                        }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
}
