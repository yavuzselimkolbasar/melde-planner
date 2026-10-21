import Foundation
import Testing
@testable import MeldePlanner

@Suite("AppModel")
struct AppModelTests {
    let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Europe/Berlin")!
        return c
    }()

    /// Monday 2026-10-19 at the given local time.
    func monday(_ hour: Int, _ minute: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: 19, hour: hour, minute: minute))!
    }

    func makeModel(at date: Date, store: LocalStore? = nil) -> AppModel {
        AppModel(store: store, calendar: calendar, now: { date })
    }

    func addMathMonday(_ model: AppModel) -> (Subject, Lesson) {
        let math = Subject(name: "Mathe")
        model.upsert(math)
        let lesson = Lesson(subjectID: math.id, weekday: 0, startMinute: 8 * 60, endMinute: 8 * 60 + 45)
        #expect(model.save(lesson).isEmpty)
        return (math, lesson)
    }

    @Test func oneTapRecordsForCurrentLesson() {
        let model = makeModel(at: monday(8, 10))
        let (math, lesson) = addMathMonday(model)
        guard case .recorded(let entry) = model.recordParticipation() else {
            Issue.record("expected an automatic assignment")
            return
        }
        #expect(entry.subjectID == math.id)
        #expect(entry.lessonID == lesson.id)
        #expect(model.weekSummary(containing: monday(12, 0))?.total == 1)
    }

    @Test func graceWindowAfterTheBell() {
        let model = makeModel(at: monday(8, 48))
        _ = addMathMonday(model)
        #expect(model.recordParticipation() != .needsSubject)
    }

    @Test func outsideLessonsAsksForSubject() {
        let model = makeModel(at: monday(13, 0))
        let (math, _) = addMathMonday(model)
        #expect(model.recordParticipation() == .needsSubject)
        let entry = model.recordParticipation(subjectID: math.id)
        #expect(model.entries(on: monday(13, 0)).map(\.id) == [entry.id])
    }

    @Test func overlappingLessonIsRejectedByRustCore() {
        let model = makeModel(at: monday(7, 0))
        let (math, _) = addMathMonday(model)
        let clash = Lesson(subjectID: math.id, weekday: 0, startMinute: 8 * 60 + 30, endMinute: 9 * 60 + 15)
        #expect(!model.save(clash).isEmpty)
        #expect(model.lessons.count == 1)
    }

    @Test func deletingSubjectKeepsMeldungenWithoutSubject() {
        let model = makeModel(at: monday(8, 10))
        let (math, _) = addMathMonday(model)
        _ = model.recordParticipation()
        model.deleteSubject(math.id)
        #expect(model.lessons.isEmpty)
        #expect(model.data.participation.count == 1)
        #expect(model.data.participation[0].subjectID == nil)
        #expect(model.data.participation[0].lessonID == nil)
    }

    @Test func persistsAcrossLaunches() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "melde-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = LocalStore(url: url)

        let first = makeModel(at: monday(8, 10), store: store)
        _ = addMathMonday(first)
        _ = first.recordParticipation()
        first.setWeeklyGoal(12)

        let second = makeModel(at: monday(9, 0), store: store)
        #expect(second.subjects.map(\.name) == ["Mathe"])
        #expect(second.data.participation.count == 1)
        #expect(second.preferences.weeklyGoal == 12)
    }

    @Test func corruptFileIsBackedUpNotOverwritten() throws {
        let folder = FileManager.default.temporaryDirectory.appending(path: "melde-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appending(path: "data.json")
        try Data("not json".utf8).write(to: url)

        let model = makeModel(at: monday(8, 0), store: LocalStore(url: url))
        #expect(model.storageProblem != nil)
        let files = try FileManager.default.contentsOfDirectory(atPath: folder.path(percentEncoded: false))
        #expect(files.contains { $0.hasPrefix("data-unreadable-") })
    }

    @Test func weekParityFollowsReference() {
        let model = makeModel(at: monday(8, 0))
        model.setCurrentWeekIsA(true)
        #expect(model.isWeekA(monday(8, 0)))
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: monday(8, 0))!
        #expect(!model.isWeekA(nextWeek))
        model.setCurrentWeekIsA(false)
        #expect(!model.isWeekA(monday(8, 0)))
    }
}
