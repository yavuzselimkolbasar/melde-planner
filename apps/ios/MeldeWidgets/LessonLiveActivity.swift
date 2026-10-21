import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

/// Lock Screen / Dynamic Island view of the running lesson.
struct LessonLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LessonActivityAttributes.self) { context in
            LessonActivityView(context: context)
                .padding(16)
                .activityBackgroundTint(Color(.secondarySystemBackground))
                .activitySystemActionForegroundColor(.primary)
        } dynamicIsland: { context in
            let color = SubjectColor(rawValue: context.attributes.colorKey)?.color ?? .meldoOrange
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.subjectName, systemImage: context.attributes.symbolName)
                        .font(.headline)
                        .foregroundStyle(color)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(L("\(context.state.count)×"))
                        .font(.title2.weight(.bold))
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(timerInterval: context.attributes.start...context.attributes.end, countsDown: true)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button(intent: LogParticipationIntent()) {
                            Label(L("Melden"), systemImage: "hand.raised.fill")
                        }
                        .tint(Color.meldoOrange)
                    }
                }
            } compactLeading: {
                Image(systemName: "hand.raised.fill").foregroundStyle(color)
            } compactTrailing: {
                Text(context.state.count, format: .number).monospacedDigit()
            } minimal: {
                Text(context.state.count, format: .number).monospacedDigit()
            }
        }
    }
}

private struct LessonActivityView: View {
    let context: ActivityViewContext<LessonActivityAttributes>

    var body: some View {
        let color = SubjectColor(rawValue: context.attributes.colorKey)?.color ?? .meldoOrange
        HStack(spacing: 14) {
            Image(systemName: context.attributes.symbolName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.16), in: .circle)
            VStack(alignment: .leading, spacing: 2) {
                Text(context.attributes.subjectName).font(.headline)
                if context.isStale {
                    Text(L("Stunde vorbei")).font(.subheadline).foregroundStyle(.secondary)
                } else if Date() < context.attributes.start {
                    // Next lesson: count down to its start.
                    HStack(spacing: 4) {
                        Text(L("Beginnt in"))
                        Text(timerInterval: Date()...context.attributes.start, countsDown: true)
                            .monospacedDigit()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                } else {
                    Text(timerInterval: context.attributes.start...context.attributes.end, countsDown: true)
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                Text(L("\(context.state.count)× gemeldet · \(context.state.weekTotal) diese Woche"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Button(intent: LogParticipationIntent()) {
                Image(systemName: "hand.raised.fill")
                    .font(.title2)
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color.meldoOrange)
            .accessibilityLabel(L("Meldung erfassen"))
        }
    }
}
