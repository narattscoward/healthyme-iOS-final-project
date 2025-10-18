import SwiftUI

struct HabitRow: View {
    @Binding var habit: Habit
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .strokeBorder(habit.isCompletedToday ? Color.App.primary : Color.App.textSecondary, lineWidth: 2)
                    .background(Circle().fill(habit.isCompletedToday ? Color.App.primary : .clear))
                    .frame(width: 22, height: 22)

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(habit.isCompletedToday ? 1 : 0)
                    .scaleEffect(habit.isCompletedToday ? 1 : 0.5)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: habit.isCompletedToday)
            }
            .frame(width: 24, height: 24)
            .contentShape(Rectangle())
            .onTapGesture(perform: onToggle)

            Text(habit.title)
                .font(.custom("SeoulHangangM", size: 18))
                .foregroundColor(.App.textPrimary)
                .strikethrough(habit.isCompletedToday, color: Color.App.textSecondary.opacity(0.6))

            Spacer(minLength: 8)

            if let t = habit.time, let h = t.hour, let m = t.minute {
                Text(Self.timeString(h: h, m: m))
                    .font(.custom("SeoulHangangL", size: 13))
                    .foregroundColor(.App.textSecondary)
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private static func timeString(h: Int, m: Int) -> String {
        let h12 = (h == 0 || h == 12) ? 12 : (h % 12)
        return String(format: "%d:%02d %@", h12, m, h < 12 ? "AM" : "PM")
    }
}
