import SwiftUI

/// Simple bar chart for values in 0…1
struct MiniBarChart: View {
    let values: [Double] // normalized 0...1

    var body: some View {
        GeometryReader { geo in
            if geo.size.width > 0, geo.size.height > 0, !values.isEmpty {
                let w = geo.size.width
                let h = geo.size.height
                let barCount = max(1, values.count)
                let gap: CGFloat = 4
                let barWidth = max(2, (w - CGFloat(barCount - 1) * gap) / CGFloat(barCount))
                let minHeight: CGFloat = 3   // 👈 always show a tiny bar

                HStack(alignment: .bottom, spacing: gap) {
                    ForEach(0..<barCount, id: \.self) { i in
                        let v = max(0, min(1, values[i]))
                        let barHeight = max(minHeight, CGFloat(v) * h) // 👈 ensure visible even when 0

                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.App.primary.opacity(0.8))
                            .frame(width: barWidth, height: barHeight)
                    }
                }
                .frame(width: w, height: h, alignment: .bottomLeading)
            } else {
                Color.clear
            }
        }
        .frame(height: 120)
    }
}
