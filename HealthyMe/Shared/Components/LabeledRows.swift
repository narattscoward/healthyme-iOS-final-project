import SwiftUI

// MARK: - Generic container (label left, content right)
public struct LabeledRow<Content: View>: View {
    let label: String
    let labelWidth: CGFloat
    let content: () -> Content

    public init(label: String,
                labelWidth: CGFloat = 120,
                @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.labelWidth = labelWidth
        self.content = content
    }

    public var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.custom("SeoulHangangM", size: 16))
                .foregroundColor(.App.textPrimary)
                .frame(width: labelWidth, alignment: .leading)

            content()
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - TextField row
public struct LabeledTextFieldRow: View {
    @Binding var text: String
    let placeholder: String
    let label: String
    let labelWidth: CGFloat
    let trailingAligned: Bool

    public init(label: String,
                text: Binding<String>,
                placeholder: String = "",
                labelWidth: CGFloat = 120,
                trailingAligned: Bool = false) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.labelWidth = labelWidth
        self.trailingAligned = trailingAligned
    }

    public var body: some View {
        LabeledRow(label: label, labelWidth: labelWidth) {
            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .font(.custom("SeoulHangangM", size: 16))
                    .foregroundColor(.App.textSecondary.opacity(0.6))
            )
            .textFieldStyle(.plain)
            .font(.custom("SeoulHangangM", size: 16))
            .textInputAutocapitalization(.sentences)
            .disableAutocorrection(false)
            .frame(maxWidth: .infinity,
                   alignment: trailingAligned ? .trailing : .leading)
            .multilineTextAlignment(trailingAligned ? .trailing : .leading)
            .padding(.trailing, trailingAligned ? 2 : 0)
        }
    }
}

// MARK: - Time (DatePicker) row
public struct LabeledTimeRow: View {
    @Binding var date: Date
    let label: String
    let labelWidth: CGFloat

    public init(label: String = "Time",
                date: Binding<Date>,
                labelWidth: CGFloat = 120) {
        self.label = label
        self._date = date
        self.labelWidth = labelWidth
    }

    public var body: some View {
        LabeledRow(label: label, labelWidth: labelWidth) {
            Spacer(minLength: 12)
            DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(Color.App.primary)
        }
    }
}

// MARK: - Toggle row
public struct LabeledToggleRow: View {
    @Binding var isOn: Bool
    let label: String
    let labelWidth: CGFloat

    public init(label: String,
                isOn: Binding<Bool>,
                labelWidth: CGFloat = 120) {
        self.label = label
        self._isOn = isOn
        self.labelWidth = labelWidth
    }

    public var body: some View {
        LabeledRow(label: label, labelWidth: labelWidth) {
            Spacer(minLength: 12)
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.App.primary)
        }
    }
}
