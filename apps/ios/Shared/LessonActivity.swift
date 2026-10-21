import ActivityKit
import Foundation
import MeldeCore

/// Live Activity shown on the Lock Screen (and Dynamic Island) during a lesson:
/// subject, time left and how often you raised your hand, with a Melden button.
nonisolated struct LessonActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// Meldungen in this lesson so far.
        var count: Int
        var weekTotal: Int
    }

    var lessonID: String
    var subjectName: String
    var colorKey: String
    var symbolName: String
    var start: Date
    var end: Date
}

/// Starting is only possible while the app (or one of its intents) runs: remote
/// "push to start" would need the paid developer program.
nonisolated enum LessonActivity {
    static var isAvailable: Bool { ActivityAuthorizationInfo().areActivitiesEnabled }

    /// Shows the current lesson's activity, starting it if needed, and ends
    /// activities of lessons that are over.
    static func refresh(_ data: AppData, at now: Date = Date(), calendar: Calendar = .current) async {
        let current = MeldeEngine.currentLesson(data, at: now, calendar: calendar)
        for activity in Activity<LessonActivityAttributes>.activities
        where activity.attributes.lessonID != current?.lessonId || activity.attributes.end <= now {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        guard data.preferences.liveActivities, isAvailable, let current else { return }
        let state = LessonActivityAttributes.ContentState(
            count: MeldeEngine.count(data, lessonID: current.lessonId, on: now, calendar: calendar),
            weekTotal: Int(MeldeEngine.weekSummary(data, containing: now, calendar: calendar)?.total ?? 0)
        )
        let day = calendar.startOfDay(for: now)
        guard let start = calendar.date(byAdding: .minute, value: Int(current.startMinute), to: day),
              let end = calendar.date(byAdding: .minute, value: Int(current.endMinute), to: day) else { return }
        let content = ActivityContent(state: state, staleDate: end)
        if let running = Activity<LessonActivityAttributes>.activities.first(where: { $0.attributes.lessonID == current.lessonId }) {
            await running.update(content)
            return
        }
        let subject = MeldeEngine.subject(data, id: current.subjectId)
        let attributes = LessonActivityAttributes(
            lessonID: current.lessonId,
            subjectName: subject?.name ?? L("Unterricht"),
            colorKey: subject?.color.rawValue ?? SubjectColor.blue.rawValue,
            symbolName: subject?.symbolName ?? "book.closed",
            start: start,
            end: end
        )
        _ = try? Activity<LessonActivityAttributes>.request(attributes: attributes, content: content, pushType: nil)
    }
}
