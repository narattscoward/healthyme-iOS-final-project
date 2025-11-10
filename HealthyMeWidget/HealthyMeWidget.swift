//
//  HealthyMeWidget.swift
//  HealthyMeWidgetExtension
//

import WidgetKit
import SwiftUI
import Foundation

// MARK: - Entry + Provider

struct Entry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
    /// Pending habits to show in the medium widget (max 2), aligned id+title.
    let pending: [(id: String, title: String)]
}

struct Provider: TimelineProvider {

    private func loadSnapshot() -> WidgetSnapshot {
        WidgetDataStore.load()
        ?? WidgetSnapshot(bestStreak: 7, completionRate: 0.62, totalCompletions: 123)
    }

    /// Read the paired pending list written by the app at key "hm.widget.pendingPairs.v1"
    private func loadPending() -> [(id: String, title: String)] {
        guard let ud = UserDefaults(suiteName: SharedIDs.appGroup) else { return [] }

        // 1) Preferred: new paired format
        if let array = ud.array(forKey: "hm.widget.pendingPairs.v1") as? [[String: String]] {
            let pairs = array.compactMap { dict -> (String, String)? in
                guard let id = dict["id"], let title = dict["title"], !id.isEmpty, !title.isEmpty else { return nil }
                return (id, title)
            }
            if !pairs.isEmpty { return pairs }
        }

        // 2) Back-compat: old two arrays (if the app hasn’t written the new key yet)
        let titles = ud.stringArray(forKey: "hm.widget.pendingTitles.v1") ?? []
        let ids    = ud.stringArray(forKey: "hm.widget.pendingIDs.v1") ?? []
        if !ids.isEmpty, !titles.isEmpty {
            return zip(ids, titles).map { ($0.0, $0.1) }.prefix(2).map { ($0.0, $0.1) }
        }

        return []
    }

    func placeholder(in context: Context) -> Entry {
        Entry(
            date: .now,
            snapshot: .init(bestStreak: 7, completionRate: 0.62, totalCompletions: 123),
            pending: [
                (id: "00000000-0000-0000-0000-000000000001", title: "Drink Water"),
                (id: "00000000-0000-0000-0000-000000000002", title: "Walk 10 minutes")
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(Entry(date: .now, snapshot: loadSnapshot(), pending: loadPending()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = Entry(date: .now, snapshot: loadSnapshot(), pending: loadPending())
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - Background (fills widget)

private struct FullImageBackground: View {
    var body: some View {
        Image("WidgetBG")    // image must live in the widget extension’s Assets
            .resizable()
            .scaledToFill()
            .clipped()
    }
}

// MARK: - Metric Tile

private struct Metric: View {
    let title: String
    let value: String
    var valueSize: CGFloat = 22

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.custom("SeoulHangangM", size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(value)
                .font(.custom("SeoulHangangEB", size: valueSize))
                .foregroundStyle(Color("AppPrimaryColor"))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }
}

// MARK: - Pending List (medium widget – deep links by id)

private struct PendingList: View {
    let habits: [(id: String, title: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HealthyMe")
                .font(.custom("SeoulHangangEB", size: 13))
                .foregroundStyle(Color("AppPrimaryColor"))
                .opacity(0.95)
            
            Text("Next Task")
                .font(.custom("SeoulHangangM", size: 11))
                .foregroundStyle(.secondary)
                .padding(.bottom, 4)

            ForEach(Array(habits.enumerated()), id: \.offset) { i, item in
                HStack(spacing: 10) {
                    Circle()
                        .stroke(Color("AppPrimaryColor"), lineWidth: 2)
                        .frame(width: 18, height: 18)

                    Text(item.title)
                        .font(.custom("SeoulHangangM", size: 16))
                        .foregroundStyle(Color("AppPrimaryColor"))
                        .lineLimit(1)

                    Spacer()
                }
                .padding(.vertical, 2)
                .widgetURL(URL(string: "healthyme://check?id=\(item.id)"))

                if i != habits.indices.last {
                    Divider().opacity(0.25)
                }
            }
        }
    }
}

// MARK: - Small Widget Layout (Stats)

private struct SmallWidgetView: View {
    let entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HealthyMe")
                .font(.custom("SeoulHangangEB", size: 12))
                .foregroundStyle(Color("AppPrimaryColor"))
                .opacity(0.9)

            Spacer(minLength: 2)

            HStack(alignment: .bottom, spacing: 12) {
                Metric(title: "Streak",
                       value: "\(entry.snapshot.bestStreak)",
                       valueSize: 24)

                Spacer(minLength: 6)

                Metric(title: "Today",
                       value: "\(Int(round(entry.snapshot.completionRate * 100)))%",
                       valueSize: 24)
            }
        }
        .padding(12)
        .containerBackground(for: .widget) { FullImageBackground() }
        .contentMargins(.all, 10)
    }
}

// MARK: - Medium Widget Layout (Pending OR Stats)

private struct MediumWidgetView: View {
    let entry: Provider.Entry

    var body: some View {
        Group {
            if let first = entry.pending.first {
                PendingList(habits: [first])
                    .padding(14)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("HealthyMe")
                        .font(.custom("SeoulHangangEB", size: 13))
                        .foregroundStyle(Color("AppPrimaryColor"))
                        .opacity(0.95)

                    HStack(spacing: 16) {
                        Metric(title: "Best Streak",
                               value: "\(entry.snapshot.bestStreak)")

                        Divider().opacity(0.25)

                        Metric(title: "Today",
                               value: "\(Int(round(entry.snapshot.completionRate * 100)))%")

                        Divider().opacity(0.25)

                        Metric(title: "Completions",
                               value: "\(entry.snapshot.totalCompletions)")
                    }
                }
                .padding(14)
            }
        }
        .containerBackground(for: .widget) { FullImageBackground() }
        .contentMargins(.all, 12)
    }
}

// MARK: - Family Switcher

struct WidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:  SmallWidgetView(entry: entry)
        case .systemMedium: MediumWidgetView(entry: entry)
        default:            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Entry Point

@main
struct HealthyMeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "HealthyMeWidget", provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("HealthyMe")
        .description("See your streak or unfinished habits at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
