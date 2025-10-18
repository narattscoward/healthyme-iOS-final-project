//
//  ProgressTab.swift
//  Final_Project
//
//  Created by Wyne Nadi on 18/10/2568 BE.
//

import SwiftUI
import Combine

// Progress Tab
struct ProgressTab: View {
    @StateObject private var vm = ProgressViewModel()
    
    private let mint: Color = .mint
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // KPIs
                    HStack(spacing: 0) {
                        KPIBlock(title: "Best Streak",
                                 value: "\(vm.stats.bestStreak)",
                                 color: mint)
                        Divider().frame(height: 58)
                        KPIBlock(title: "All Time",
                                 value: String(format: "%.2f%%", vm.stats.allTimePercent),
                                 color: mint)
                        Divider().frame(height: 58)
                        KPIBlock(title: "Completions",
                                 value: "\(vm.stats.completions)",
                                 color: mint)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Mini chart card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Last 30 Days")
                            .font(.subheadline)
                            .foregroundStyle(mint.opacity(0.9))
                        
                        Bars(values: vm.stats.dailyHistory, fill: mint, maxValue: vm.stats.dailyHistory.max() ?? 1)
                            .frame(height: 120)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(mint.opacity(0.12))
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // How you're doing
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How you're doing")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: vm.quote.icon)
                                .font(.title2)
                                .foregroundStyle(mint)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("“\(vm.quote.text)”")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Text(vm.quote.caption)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(mint.opacity(0.12))
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    Spacer(minLength: 24)
                }
            }
            .navigationTitle("Progress")
            .toolbarTitleDisplayMode(.large)
            .tint(mint)
        }
        .task { await vm.load() }
    }
}


// KPI Block
private struct KPIBlock: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(color)
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Bars (tiny chart)
private struct Bars: View {
    let values: [Int]
    let fill: Color
    let maxValue: Int

    var body: some View {
        GeometryReader { geo in
            let step = geo.size.width / CGFloat(max(values.count, 1))
            let barWidth = max(4.0, step * 0.6)

            HStack(alignment: .bottom, spacing: step * 0.4) {
                ForEach(values.indices, id: \.self) { i in
                    let hRatio = maxValue == 0 ? 0 : CGFloat(values[i]) / CGFloat(maxValue)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(fill.opacity(0.85))
                        .frame(width: barWidth,
                               height: max(4, geo.size.height * hRatio))
                        .accessibilityLabel(Text("Day \(i + 1)"))
                        .accessibilityValue(Text("\(values[i])"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// ViewModel + Mock API
@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var stats: ProgressStats = .placeholder
    @Published var quote: ProgressQuote = .placeholder

    private let service: ProgressService = MockProgressService()

    func load() async {
        do {
            let fetched = try await service.fetchProgress()
            stats = fetched
            quote = Self.pickQuote(for: stats.allTimePercent)
        } catch {
            stats = .placeholder
            quote = .error
        }
    }

    // Tiered quote selection by performance
    static func pickQuote(for percent: Double) -> ProgressQuote {
        switch percent {
        case 90...100:
            return ProgressQuote(
                text: "Consistency is your superpower.",
                caption: "Fantastic streak—keep riding the wave!",
                icon: "sparkles"
            )
        case 70..<90:
            return ProgressQuote(
                text: "Small steps add up to big changes.",
                caption: "You're trending up. Stay steady.",
                icon: "chart.line.uptrend.xyaxis"
            )
        case 40..<70:
            return ProgressQuote(
                text: "Progress, not perfection.",
                caption: "Try one tiny win today.",
                icon: "leaf"
            )
        default:
            return ProgressQuote(
                text: "Every restart is progress too.",
                caption: "Let’s begin again, one tap at a time.",
                icon: "arrow.clockwise"
            )
        }
    }
}

// MODELS
struct ProgressStats: Sendable {
    var bestStreak: Int
    var allTimePercent: Double  // 0...100
    var completions: Int
    var dailyHistory: [Int]

    static let placeholder = ProgressStats(
        bestStreak: 18,
        allTimePercent: 90.77,
        completions: 76,
        dailyHistory: (0..<30).map { i in
            Int(Double.random(in: 3...10) * (0.7 + 0.3 * sin(Double(i)/4.0)))
        }
    )
}

struct ProgressQuote {
    var text: String
    var caption: String
    var icon: String

    static let placeholder = ProgressQuote(
        text: "Consistency is your superpower.",
        caption: "Fantastic streak—keep riding the wave!",
        icon: "sparkles"
    )

    static let error = ProgressQuote(
        text: "We’ll load your progress soon.",
        caption: "Unable to fetch data right now.",
        icon: "exclamationmark.triangle"
    )
}

// Service protocol
protocol ProgressService {
    func fetchProgress() async throws -> ProgressStats
}

// Example mock; replace with real networking later
struct MockProgressService: ProgressService {
    func fetchProgress() async throws -> ProgressStats {
        try await Task.sleep(nanoseconds: 400_000_000) // simulate latency
        return .placeholder
    }
}


#Preview {
    ProgressTab()
}
