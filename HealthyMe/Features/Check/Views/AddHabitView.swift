import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CheckHabitsViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    @State private var title: String = ""
    @State private var time: Date = Date()
    @State private var notify: Bool = true
    @State private var notes: String = ""

    private let labelWidth: CGFloat = 120
    private let rowHeight: CGFloat  = 36

    private var b: Bundle { languageManager.bundle }

    @ViewBuilder private func hairline() -> some View {
        Divider().overlay(Color.black.opacity(0.06))
    }

    var body: some View {
        ZStack {
            Color.App.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Grabber + Title
                VStack(spacing: 10) {
                    Capsule().fill(.secondary.opacity(0.25))
                        .frame(width: 36, height: 4)
                        .padding(.top, 8)

                    Text(L("addHabit.title", b))  // "Add a habit"
                        .font(.custom("SeoulHangangEB", size: 24))
                        .foregroundColor(.App.textPrimary)
                }
                .padding(.bottom, 6)

                ScrollView {
                    VStack(spacing: 18) {

                        // ── Card (uniform 36pt rows) ──────────────────────────
                        VStack(spacing: 0) {
                            // Habit name
                            LabeledRow(label: L("form.habit", b),
                                       labelWidth: labelWidth) {
                                TextField(
                                    L("placeholder.habitName", b),
                                    text: $title
                                )
                                .font(.custom("SeoulHangangM", size: 16))
                                .multilineTextAlignment(.trailing)
                                .frame(height: rowHeight)
                            }

                            hairline()

                            // Time (compact, small)
                            LabeledRow(label: L("form.time", b),
                                       labelWidth: labelWidth) {
                                Spacer(minLength: 12)
                                DatePicker(
                                    "",
                                    selection: $time,
                                    displayedComponents: [.hourAndMinute]
                                )
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .controlSize(.small)
                                .tint(Color.App.primary)
                                .font(.custom("SeoulHangangM", size: 16))
                                .frame(height: rowHeight)
                            }
                            .padding(.vertical, 2)

                            hairline()

                            // Notification toggle
                            LabeledRow(label: L("form.notification", b),
                                       labelWidth: labelWidth) {
                                Spacer(minLength: 12)
                                Toggle("", isOn: $notify)
                                    .labelsHidden()
                                    .tint(Color.App.primary)
                                    .frame(height: rowHeight)
                            }
                        }
                        .cardStyle()

                        // ── Description (separate from the card) ─────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L("details.description", b))
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

                        // ── Add button ───────────────────────────────────────
                        Button {
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
                            let name = title.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !name.isEmpty else { return }
                            viewModel.add(title: name, time: comps, notify: notify, notes: notes)
                            dismiss()
                        } label: {
                            Text(L("button.addHabit", b))
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
        // Make pickers/text date formats follow the selected app locale, too:
        .environment(\.locale, languageManager.locale)
        .presentationDragIndicator(.visible)
    }
}
