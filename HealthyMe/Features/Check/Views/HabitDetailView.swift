import SwiftUI

struct HabitDetailView: View {
    @Binding var habit: Habit
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager

    // Working copies
    @State private var draft: Habit
    @State private var original: Habit
    @State private var timeDate: Date

    private var b: Bundle { languageManager.bundle }

    init(habit: Binding<Habit>, onDelete: @escaping () -> Void) {
        _habit = habit
        self.onDelete = onDelete

        let current = habit.wrappedValue
        _draft    = State(initialValue: current)
        _original = State(initialValue: current)

        if let comps = current.time, let d = Calendar.current.date(from: comps) {
            _timeDate = State(initialValue: d)
        } else {
            _timeDate = State(initialValue: Date())
        }
    }

    // Only fields edited here determine “dirty”: title, notes, time (hour/minute)
    private var isDirty: Bool {
        !equalsForDetails(lhs: draft, rhs: original)
    }

    private func equalsForDetails(lhs: Habit, rhs: Habit) -> Bool {
        let lhsTitle = lhs.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let rhsTitle = rhs.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let lhsNotes = lhs.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let rhsNotes = rhs.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        guard lhsTitle == rhsTitle, lhsNotes == rhsNotes else { return false }

        switch (lhs.time, rhs.time) {
        case (nil, nil): return true
        case let (a?, b?): return a.hour == b.hour && a.minute == b.minute
        default: return false
        }
    }

    private let labelWidth: CGFloat = 120
    private let rowHeight: CGFloat  = 36

    @ViewBuilder private func hairline() -> some View {
        Divider().overlay(Color.black.opacity(0.06))
    }

    var body: some View {
        ZStack {
            Color.App.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {

                    // Card
                    VStack(spacing: 0) {
                        // Name
                        LabeledRow(label: L("form.habit", b), labelWidth: labelWidth) {
                            TextField(
                                "",
                                text: $draft.title,
                                prompt: Text(L("placeholder.habitName", b))
                                    .font(.custom("SeoulHangangM", size: 16))
                            )
                            .font(.custom("SeoulHangangM", size: 16))
                            .multilineTextAlignment(.trailing)
                            .frame(height: rowHeight)
                        }

                        hairline()

                        // Time (writes to draft only after user moves the picker)
                        LabeledRow(label: L("form.time", b), labelWidth: labelWidth) {
                            Spacer(minLength: 12)
                            DatePicker(
                                "",
                                selection: $timeDate,
                                displayedComponents: [.hourAndMinute]
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .controlSize(.small)
                            .tint(Color.App.primary)
                            .font(.custom("SeoulHangangM", size: 16))
                            .frame(height: rowHeight)
                            .onChange(of: timeDate, initial: false) { _, newValue in
                                draft.time = Calendar.current
                                    .dateComponents([.hour, .minute], from: newValue)
                            }
                        }
                        .padding(.vertical, 2)

                        hairline()

                        // Notification toggle (live change; not part of Save)
                        LabeledRow(label: L("form.notification", b), labelWidth: labelWidth) {
                            Spacer(minLength: 12)
                            Toggle("", isOn: $habit.notify)
                                .labelsHidden()
                                .tint(Color.App.primary)
                                .frame(height: rowHeight)
                        }
                    }
                    .cardStyle()

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L("details.description", b))
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
                        DispatchQueue.main.async { performDelete() }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                            Text(L("action.delete", b))
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
        .navigationTitle(L("navigation.details.title", b))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isDirty {                      // ← match ProfileView: only show when dirty
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("common.save", b)) {
                        habit.title = draft.title
                        habit.notes = draft.notes
                        habit.time  = draft.time
                        dismiss()
                    }
                    .font(.custom("SeoulHangangEB", size: 16))
                    .foregroundColor(.App.primary)
                }
            }
        }
        .environment(\.locale, languageManager.locale)
    }
}
