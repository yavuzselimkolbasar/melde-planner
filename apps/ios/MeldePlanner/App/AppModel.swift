import Foundation
import MeldeCore
import Observation

/// Single source of truth for the UI. Business rules (current lesson, streaks,
/// targets, validation) are delegated to the Rust core; this type owns state,
/// persistence and the mapping between Swift models and FFI records.
@Observable
final class AppModel {
    private(set) var data: AppData
    /// User-facing problem with loading or saving, shown as a banner.
    var storageProblem: String?

    private let store: LocalStore?
    let calendar: Calendar
    private let now: () -> Date

    /// Minutes after the bell in which a Meldung still counts for the lesson that just ended.
    static let participationGraceMinutes: UInt16 = 5

    init(store: LocalStore?, calendar: Calendar = .current, now: @escaping () -> Date = Date.init) {
        self.store = store
        self.calendar = calendar
        self.now = now
        do {
            data = try store?.load() ?? AppData()
        } catch {
            data = AppData()
            storageProblem = L("Deine gespeicherten Daten konnten nicht gelesen werden. Eine Sicherungskopie wurde behalten.")
        }
        Localization.apply(data.preferences.language)
    }

    var currentDate: Date { now() }

    // MARK: - Persistence

    /// Applies a change and saves it. Feature extensions change data only through this.
    func mutate(_ change: (inout AppData) -> Void) {
        change(&data)
        persist()
    }

    private func persist() {
        guard let store else { return }
        do {
            try store.save(data)
            storageProblem = nil
        } catch {
            storageProblem = L("Änderungen konnten nicht gespeichert werden. Prüfe den freien Speicher.")
        }
    }

    // MARK: - Preferences

    var preferences: Preferences { data.preferences }

    func setLanguage(_ language: AppLanguage) {
        data.preferences.language = language
        Localization.apply(language)
        persist()
    }

    func setTheme(_ theme: AppTheme) {
        data.preferences.theme = theme
        persist()
    }

    func setWeeklyGoal(_ goal: Int?) {
        data.preferences.weeklyGoal = goal.map { max(1, min($0, 200)) }
        persist()
    }

    func setWeekAReference(_ date: Date?) {
        data.preferences.weekAReference = date
        persist()
    }

    /// Marks the week containing today as an A week (or B week).
    func setCurrentWeekIsA(_ isA: Bool) {
        let today = now()
        setWeekAReference(isA ? today : calendar.date(byAdding: .weekOfYear, value: -1, to: today))
    }

    func isWeekA(_ date: Date) -> Bool {
        guard let reference = data.preferences.weekAReference,
              let a = calendar.dateInterval(of: .weekOfYear, for: reference)?.start,
              let b = calendar.dateInterval(of: .weekOfYear, for: date)?.start
        else { return true }
        let weeks = calendar.dateComponents([.weekOfYear], from: a, to: b).weekOfYear ?? 0
        return weeks.isMultiple(of: 2)
    }

    // MARK: - Subjects

    var subjects: [Subject] { data.subjects }

    func subject(_ id: UUID?) -> Subject? {
        guard let id else { return nil }
        return data.subjects.first { $0.id == id }
    }

    func upsert(_ subject: Subject) {
        var subject = subject
        subject.name = subject.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !subject.name.isEmpty else { return }
        subject.updatedAt = now()
        if let i = data.subjects.firstIndex(where: { $0.id == subject.id }) {
            data.subjects[i] = subject
        } else {
            data.subjects.append(subject)
        }
        persist()
    }

    /// Deletes a subject and its lessons. Past Meldungen are kept without a subject.
    func deleteSubject(_ id: UUID) {
        let lessonIDs = Set(data.lessons.filter { $0.subjectID == id }.map(\.id))
        data.subjects.removeAll { $0.id == id }
        data.lessons.removeAll { $0.subjectID == id }
        for i in data.participation.indices where data.participation[i].subjectID == id {
            data.participation[i].subjectID = nil
        }
        for i in data.participation.indices where data.participation[i].lessonID.map(lessonIDs.contains) == true {
            data.participation[i].lessonID = nil
        }
        persist()
    }

    // MARK: - Timetable

    var lessons: [Lesson] { data.lessons }

    func lessons(onWeekday weekday: Int) -> [Lesson] {
        data.lessons.filter { $0.weekday == weekday }.sorted { $0.startMinute < $1.startMinute }
    }

    /// Validates with the Rust core and saves when there is no conflict.
    func save(_ lesson: Lesson) -> [FfiTimetableIssue] {
        var candidate = data.lessons.filter { $0.id != lesson.id }
        var updated = lesson
        updated.updatedAt = now()
        candidate.append(updated)
        let issues = validate(lessons: candidate)
        guard issues.isEmpty else { return issues }
        data.lessons = candidate
        persist()
        return []
    }

    func deleteLesson(_ id: UUID) {
        data.lessons.removeAll { $0.id == id }
        for i in data.participation.indices where data.participation[i].lessonID == id {
            data.participation[i].lessonID = nil
        }
        persist()
    }

    func validate(lessons: [Lesson]) -> [FfiTimetableIssue] {
        var timetable = ffiTimetable
        timetable.lessons = lessons.map(Self.ffiLesson)
        return (try? timetableValidate(timetable: timetable)) ?? []
    }

    var ffiTimetable: FfiTimetable {
        FfiTimetable(
            lessons: data.lessons.map(Self.ffiLesson),
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

    private static func ffiLesson(_ l: Lesson) -> FfiLesson {
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

    func occurrences(on date: Date) -> [FfiOccurrence] {
        (try? timetableOccurrencesOn(timetable: ffiTimetable, date: FfiDate(date, calendar: calendar))) ?? []
    }

    func currentLesson(at date: Date) -> FfiOccurrence? {
        try? timetableCurrent(timetable: ffiTimetable, at: FfiDateTime(date, calendar: calendar))
    }

    func nextLesson(after date: Date) -> FfiOccurrence? {
        try? timetableNext(timetable: ffiTimetable, at: FfiDateTime(date, calendar: calendar), horizonDays: 14)
    }

    func subject(for occurrence: FfiOccurrence) -> Subject? {
        subject(UUID(uuidString: occurrence.subjectId))
    }

    // MARK: - Melde Tracker

    enum RecordOutcome: Equatable {
        case recorded(ParticipationEntry)
        /// No lesson right now: the UI asks for the subject (second tap).
        case needsSubject
    }

    /// One-tap recording, auto-assigned to the current lesson when possible.
    func recordParticipation(at date: Date? = nil) -> RecordOutcome {
        let at = date ?? now()
        let lesson = try? timetableParticipationLesson(
            timetable: ffiTimetable,
            at: FfiDateTime(at, calendar: calendar),
            graceMinutes: Self.participationGraceMinutes
        )
        guard let lesson else { return .needsSubject }
        let entry = ParticipationEntry(
            subjectID: UUID(uuidString: lesson.subjectId),
            lessonID: UUID(uuidString: lesson.lessonId),
            recordedAt: at
        )
        data.participation.append(entry)
        persist()
        return .recorded(entry)
    }

    @discardableResult
    func recordParticipation(subjectID: UUID?, at date: Date? = nil) -> ParticipationEntry {
        let entry = ParticipationEntry(subjectID: subjectID, lessonID: nil, recordedAt: date ?? now())
        data.participation.append(entry)
        persist()
        return entry
    }

    func deleteParticipation(_ id: UUID) {
        data.participation.removeAll { $0.id == id }
        persist()
    }

    func reassignParticipation(_ id: UUID, to subjectID: UUID?) {
        guard let i = data.participation.firstIndex(where: { $0.id == id }) else { return }
        data.participation[i].subjectID = subjectID
        data.participation[i].lessonID = nil
        persist()
    }

    private var ffiEntries: [FfiParticipationEntry] {
        data.participation.map {
            FfiParticipationEntry(
                id: $0.id.uuidString,
                subjectId: $0.subjectID?.uuidString,
                at: FfiDateTime($0.recordedAt, calendar: calendar)
            )
        }
    }

    func weekSummary(containing date: Date) -> FfiWeekSummary? {
        try? participationWeekSummary(entries: ffiEntries, anyDayInWeek: FfiDate(date, calendar: calendar))
    }

    func streak(asOf date: Date) -> Int {
        Int((try? participationStreak(entries: ffiEntries, timetable: ffiTimetable, today: FfiDate(date, calendar: calendar))) ?? 0)
    }

    /// Totals of the `count` weeks before the week containing `date`, oldest first.
    func previousWeekTotals(before date: Date, count: Int) -> [UInt32] {
        (1...max(count, 1)).reversed().compactMap { offset in
            calendar.date(byAdding: .weekOfYear, value: -offset, to: date).flatMap { weekSummary(containing: $0)?.total }
        }
    }

    func suggestedWeeklyGoal(asOf date: Date) -> Int? {
        // Leading empty weeks are from before the student started using the app.
        let history = previousWeekTotals(before: date, count: 4).drop(while: { $0 == 0 })
        return participationSuggestWeeklyTarget(recentWeekTotals: Array(history)).map(Int.init)
    }

    func entries(on date: Date) -> [ParticipationEntry] {
        data.participation
            .filter { calendar.isDate($0.recordedAt, inSameDayAs: date) }
            .sorted { $0.recordedAt > $1.recordedAt }
    }
}
