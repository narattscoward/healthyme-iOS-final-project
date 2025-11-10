import SwiftUI

struct ProgressViewPage: View {
    @EnvironmentObject private var vm: CheckHabitsViewModel
    @EnvironmentObject private var languageManager: LanguageManager

    private var b: Bundle { languageManager.bundle }

    var body: some View {
        let stats = vm.progressStats(lastDays: 28)

        ScrollView {
            VStack(spacing: 20) {

                // --- Header stats ---
                HStack(spacing: 24) {
                    StatTile(
                        title: L("progress.bestStreak", b),
                        value: String(
                            format: "%lld",
                            locale: languageManager.locale,
                            Int64(stats.bestStreak)
                        )
                    )
                    StatTile(
                        title: L("progress.allTime", b),
                        value: String(
                            format: "%.2f%%",
                            locale: languageManager.locale, // show Burmese digits when language is Burmese
                            stats.rate28 * 100
                        )
                    )
                    StatTile(
                        title: L("progress.completions", b),
                        value: String(
                            format: "%lld",
                            locale: languageManager.locale,
                            Int64(stats.total)
                        )
                    )
                }
                .padding(.horizontal)

                // --- Mini bar chart ---
                VStack(alignment: .leading, spacing: 8) {
                    Text(L("progress.last28days", b))
                        .font(.custom("SeoulHangangM", size: 14))
                        .foregroundColor(.App.textSecondary)

                    MiniBarChart(values: stats.bars)
                        .frame(height: 120)
                }
                .cardStyle()
                .padding(.horizontal)

                // --- Hot streaks (≥ 10 days) ---
                hotStreaksSection
                    .padding(.horizontal)

                Spacer(minLength: 40)
            }
            .padding(.top, 12)
        }
        .background(Color.App.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.large)
        // Make SwiftUI formatters respect the selected app locale
        .environment(\.locale, languageManager.locale)
    }

    // MARK: - Hot Streaks Section
    private var hotStreaksSection: some View {
        let hotStreaks = vm.habits
            .map { ($0, currentStreak(for: $0)) }
            .filter { $0.1 >= 10 }
            .sorted { $0.1 > $1.1 }

        return VStack(alignment: .leading, spacing: 10) {
            Text(L("progress.hotStreaks", b))
                .font(.custom("SeoulHangangM", size: 14))
                .foregroundColor(.App.textSecondary)

            if hotStreaks.isEmpty {
                Text(L("progress.noHotStreaks", b))
                    .font(.custom("SeoulHangangM", size: 15))
                    .foregroundColor(.App.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ForEach(hotStreaks, id: \.0.id) { habit, streak in
                    HStack(spacing: 12) {
                        Text(habit.title)
                            .font(.custom("SeoulHangangM", size: 16))
                            .foregroundColor(.App.textPrimary)
                            .lineLimit(1)

                        Spacer(minLength: 12)

                        // "NN days" using formatted key + suffix with selected locale
                        let formatString = L("progress.days.format", b)
                        let suffix       = L("progress.days.suffix", b)

                        let daysText = String(
                            format: formatString,
                            locale: languageManager.locale,
                            Int64(streak), suffix
                        )

                        Text(daysText)
                            .font(.custom("SeoulHangangEB", size: 13))
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                            .background(Capsule().fill(Color.App.primary))
                    }
                    .padding(.vertical, 6)

                    if habit.id != hotStreaks.last?.0.id {
                        Divider().overlay(Color.black.opacity(0.06))
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Streak helper
    private func currentStreak(for habit: Habit, upTo endDate: Date = Date()) -> Int {
        var streak = 0
        var d = endDate.startOfDayLocal
        while habit.completedDays.contains(Habit.dayKey(d)) {
            streak += 1
            d = d.addingDays(-1)
        }
        return streak
    }
}

// Small stat tile
private struct StatTile: View {
    let title: String
    let value: String
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.custom("SeoulHangangEB", size: 22))
                .foregroundColor(.App.primary)
            Text(title)
                .font(.custom("SeoulHangangM", size: 13))
                .foregroundColor(.App.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
