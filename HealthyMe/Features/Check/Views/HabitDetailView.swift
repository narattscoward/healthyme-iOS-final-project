import SwiftUI

struct HabitDetailView: View {
    @Binding var habit: Habit
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss

    // Draft for explicit Save flow (title, time, notes only)
    @State private var draft: Habit
    @State private var timeDate: Date

    init(habit: Binding<Habit>, onDelete: @escaping () -> Void) {
        _habit = habit
        self.onDelete = onDelete

        let current = habit.wrappedValue
        _draft = State(initialValue: current)

        if let comps = current.time, let d = Calendar.current.date(from: comps) {
            _timeDate = State(initialValue: d)
        } else {
            _timeDate = State(initialValue: Date())
        }
    }

    // Only consider title/time/notes diffs (notify toggles save instantly)
    private var hasChanges: Bool {
        let titleChanged = draft.title != habit.title
        let notesChanged = draft.notes != habit.notes
        let timeChanged: Bool = {
            let current = habit.time
            let draftTime = draft.time
            return current?.hour != draftTime?.hour || current?.minute != draftTime?.minute
        }()
        return titleChanged || notesChanged || timeChanged
    }

    private let labelWidth: CGFloat = 120

    var body: some View {
        ZStack {
            Color.App.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {

                    // Card
                    VStack(spacing: 0) {
                        // Title (draft)
                        LabeledTextFieldRow(
                            label: "Habit",
                            text: $draft.title,
                            placeholder: "Habit name",
                            labelWidth: labelWidth,
                            trailingAligned: true // match Add screen if you like
                        )

                        Divider().overlay(Color.black.opacity(0.06))

                        // Time (draft) -> mirrors into draft.time
                        LabeledTimeRow(date: $timeDate, labelWidth: labelWidth)
                            .onChange(of: timeDate) { _, newValue in
                                draft.time = Calendar.current
                                    .dateComponents([.hour, .minute], from: newValue)
                            }

                        Divider().overlay(Color.black.opacity(0.06))

                        // Notification (LIVE) -> binds directly to habit.notify
                        LabeledToggleRow(
                            label: "Notification",
                            isOn: $habit.notify,          // <- immediate persist via VM binding
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

                    // Description (draft)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.custom("SeoulHangangM", size: 16))
                            .foregroundColor(.App.textPrimary)
                            .padding(.horizontal, 6)

                        TextEditor(text: $draft.notes)
                            .font(.custom("SeoulHangangM", size: 15))
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 160, alignment: .topLeading)
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

                    // Delete
                    Button(role: .destructive) {
                        let performDelete = onDelete
                        dismiss()
                        DispatchQueue.main.async { performDelete() } // after dismissal
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                        .font(.custom("SeoulHangangM", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.red.opacity(0.14)))
                    }
                    .tint(.red)
                    .padding(.horizontal, 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    // Write back only the fields we draft-edit.
                    habit.title = draft.title
                    habit.time  = draft.time
                    habit.notes = draft.notes
                    dismiss()
                }
                .font(.custom("SeoulHangangEB", size: 16))
                .disabled(!hasChanges)  // visible but disabled when no changes, or switch to conditional if you prefer
            }
        }
        .onAppear {
            // Ensure draft has a time once; mirror from habit on first appear
            if draft.time == nil {
                draft.time = Calendar.current.dateComponents([.hour, .minute], from: timeDate)
            }
        }
    }
}
