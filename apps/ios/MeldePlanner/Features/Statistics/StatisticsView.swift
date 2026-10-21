import Charts
import MeldeCore
import SwiftUI

/// Participation statistics from real entries only; empty data shows an empty state, never a sample chart.
struct StatisticsView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var weekOffset = 0

    private var referenceDate: Date {
        model.calendar.date(byAdding: .weekOfYear, value: weekOffset, to: model.currentDate) ?? model.currentDate
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DS.spacingL) {
                if model.data.participation.isEmpty {
                    ContentUnavailableView {
                        Label(L("Noch keine Meldungen"), systemImage: "chart.bar")
                    } description: {
                        Text(L("Tippe im Unterricht auf „Melden“. Hier siehst du dann deine Entwicklung."))
                    }
                    .padding(.top, DS.spacingXL)
                } else if let summary = model.weekSummary(containing: referenceDate) {
                    // Two columns on iPad: the week next to its subject breakdown.
                    LazyVGrid(
                        columns: sizeClass == .regular
                            ? [GridItem(.flexible(), spacing: DS.spacingL, alignment: .top), GridItem(.flexible(), alignment: .top)]
                            : [GridItem(.flexible())],
                        spacing: DS.spacingL
                    ) {
                        WeekChartCard(summary: summary, weekOffset: $weekOffset)
                        SubjectBreakdownCard(summary: summary)
                    }
                    TrendCard(endingAt: referenceDate)
                }
            }
            .frame(maxWidth: 1100)
            .padding(DS.spacingL)
            .frame(maxWidth: .infinity)
        }
        .background(ThemedBackground())
        .navigationTitle(L("Statistik"))
    }
}

private struct DayValue: Identifiable {
    let index: Int
    let count: Int
    var id: Int { index }
}

private struct WeekChartCard: View {
    let summary: FfiWeekSummary
    @Binding var weekOffset: Int

    var body: some View {
        let days = summary.perDay.enumerated().map { DayValue(index: $0.offset, count: Int($0.element)) }
        Card(title: L("Meldungen pro Tag"), systemImage: "chart.bar") {
            HStack {
                Button(L("Vorherige Woche"), systemImage: "chevron.left") { weekOffset -= 1 }
                    .labelStyle(.iconOnly)
                Spacer()
                VStack(spacing: 0) {
                    Text(summary.total, format: .number).font(.title2.weight(.bold)).monospacedDigit()
                    Text(weekTitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button(L("Nächste Woche"), systemImage: "chevron.right") { weekOffset += 1 }
                    .labelStyle(.iconOnly)
                    .disabled(weekOffset >= 0)
            }
            .buttonStyle(.glass)
            Chart(days) { day in
                BarMark(
                    x: .value(L("Tag"), WeekdayText.short(day.index)),
                    y: .value(L("Meldungen"), day.count)
                )
                .foregroundStyle(.tint)
                .cornerRadius(6)
            }
            .chartXScale(domain: (0..<7).map(WeekdayText.short))
            .frame(height: 180)
        }
    }

    private var weekTitle: String {
        switch weekOffset {
        case 0: L("Diese Woche")
        case -1: L("Letzte Woche")
        default: L("Vor \(-weekOffset) Wochen")
        }
    }
}

private struct SubjectBreakdownCard: View {
    @Environment(AppModel.self) private var model
    let summary: FfiWeekSummary

    var body: some View {
        Card(title: L("Nach Fach"), systemImage: "books.vertical") {
            if summary.perSubject.isEmpty {
                Text(L("Keine Meldungen in dieser Woche.")).foregroundStyle(.secondary)
            }
            ForEach(summary.perSubject, id: \.subjectId) { item in
                let subject = model.subject(item.subjectId.flatMap(UUID.init(uuidString:)))
                HStack(spacing: DS.spacingM) {
                    SubjectIcon(subject: subject, size: 28)
                    Text(subject?.name ?? L("Ohne Fach"))
                    Spacer()
                    Text(item.count, format: .number).monospacedDigit().foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct WeekTotal: Identifiable {
    let weekStart: Date
    let total: Int
    var id: Date { weekStart }
}

private struct TrendCard: View {
    @Environment(AppModel.self) private var model
    let endingAt: Date

    var body: some View {
        let weeks: [WeekTotal] = (0..<8).reversed().compactMap { offset in
            guard let day = model.calendar.date(byAdding: .weekOfYear, value: -offset, to: endingAt),
                  let summary = model.weekSummary(containing: day),
                  let start = summary.weekStart.date(in: model.calendar) else { return nil }
            return WeekTotal(weekStart: start, total: Int(summary.total))
        }
        Card(title: L("Letzte 8 Wochen"), systemImage: "chart.line.uptrend.xyaxis") {
            Chart(weeks) { week in
                LineMark(x: .value(L("Woche"), week.weekStart, unit: .weekOfYear), y: .value(L("Meldungen"), week.total))
                    .interpolationMethod(.monotone)
                PointMark(x: .value(L("Woche"), week.weekStart, unit: .weekOfYear), y: .value(L("Meldungen"), week.total))
            }
            .foregroundStyle(.tint)
            .frame(height: 160)
            if let goal = model.preferences.weeklyGoal {
                Text(L("Wochenziel: \(goal)")).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}
