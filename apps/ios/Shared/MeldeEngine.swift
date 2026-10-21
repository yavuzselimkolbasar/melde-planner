import Foundation
import MeldeCore

/// Pure functions over `AppData` shared by the app, widgets, the Melden control
/// and notification actions, so every surface logs a Meldung the same way.
/// The rules themselves live in the Rust core.
nonisolated enum MeldeEngine {
    /// Minutes after the bell in which a Meldung still counts for the lesson that just ended.
    static let participationGraceMinutes: UInt16 = 5

    static func timetable(_ data: AppData, calendar: Calendar) -> FfiTimetable {
        FfiTimetable(
            lessons: data.lessons.map(ffiLesson),
            holidays: data.holidays.map {
                FfiHoliday(
                    name: $0.name,
                    firstDay: FfiDate($0.firstDay, calendar: calendar),
                    lastDay: FfiDate($0.lastDay, calendar: calendar)
                )
            },
            changes: [],
            weekAReference: data.preferences.weekAReference.map { FfiDate($0, calendar: calendar) }
        )
    }

    static func ffiLesson(_ l: Lesson) -> FfiLesson {
        let parity: FfiWeekParity = switch l.parity {
        case .every: .every
        case .a: .a
        case .b: .b
        }
        return FfiLesson(
            id: l.id.uuidString,
            subjectId: l.subjectID.uuidString,
            weekday: FfiWeekday(mondayIndex: l.weekday),
            startMinute: UInt16(clamping: l.startMinute),
            endMinute: UInt16(clamping: l.endMinute),
            parity: parity,
            room: l.room.isEmpty ? nil : l.room
        )
    }

    static func entries(_ data: AppData, calendar: Calendar) -> [FfiParticipationEntry] {
        data.participation.map {
            FfiParticipationEntry(
                id: $0.id.uuidString,
                subjectId: $0.subjectID?.uuidString,
                at: FfiDateTime($0.recordedAt, calendar: calendar)
            )
        }
    }

    static func currentLesson(_ data: AppData, at date: Date, calendar: Calendar) -> FfiOccurrence? {
        try? timetableCurrent(timetable: timetable(data, calendar: calendar), at: FfiDateTime(date, calendar: calendar))
    }

    static func nextLesson(_ data: AppData, after date: Date, calendar: Calendar) -> FfiOccurrence? {
        try? timetableNext(
            timetable: timetable(data, calendar: calendar),
            at: FfiDateTime(date, calendar: calendar), horizonDays: 14
        )
    }

    /// The lesson a Meldung at `date` belongs to (current lesson or one that just ended).
    static func participationLesson(_ data: AppData, at date: Date, calendar: Calendar) -> FfiOccurrence? {
        try? timetableParticipationLesson(
            timetable: timetable(data, calendar: calendar),
            at: FfiDateTime(date, calendar: calendar),
            graceMinutes: participationGraceMinutes
        )
    }

    /// Records a Meldung for the lesson at `date`; `nil` when no lesson matches.
    static func recordForLesson(in data: inout AppData, at date: Date, calendar: Calendar) -> ParticipationEntry? {
        guard let lesson = participationLesson(data, at: date, calendar: calendar) else { return nil }
        let entry = ParticipationEntry(
            subjectID: UUID(uuidString: lesson.subjectId),
            lessonID: UUID(uuidString: lesson.lessonId),
            recordedAt: date
        )
        data.participation.append(entry)
        return entry
    }

    static func weekSummary(_ data: AppData, containing date: Date, calendar: Calendar) -> FfiWeekSummary? {
        try? participationWeekSummary(entries: entries(data, calendar: calendar), anyDayInWeek: FfiDate(date, calendar: calendar))
    }

    /// Meldungen already recorded for one lesson on one day.
    static func count(_ data: AppData, lessonID: String, on date: Date, calendar: Calendar) -> Int {
        data.participation.filter {
            $0.lessonID?.uuidString == lessonID && calendar.isDate($0.recordedAt, inSameDayAs: date)
        }.count
    }

    static func subject(_ data: AppData, id: String?) -> Subject? {
        guard let id, let uuid = UUID(uuidString: id) else { return nil }
        return data.subjects.first { $0.id == uuid }
    }
}
