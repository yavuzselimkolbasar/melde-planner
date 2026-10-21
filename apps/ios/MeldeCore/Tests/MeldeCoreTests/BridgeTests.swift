import Foundation
import Testing
@testable import MeldeCore

// These run against the real Rust library through the generated bindings,
// so they prove the FFI boundary, not just Swift code.

@Suite("Rust core through UniFFI")
struct BridgeTests {
    let berlin: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Europe/Berlin")!
        return c
    }()

    @Test func dateConversionUsesLocalWallClock() throws {
        // 2026-10-19 07:30 UTC is 09:30 in Berlin (CEST).
        let instant = try #require(ISO8601DateFormatter().date(from: "2026-10-19T07:30:00Z"))
        let local = FfiDateTime(instant, calendar: berlin)
        #expect(local.date == FfiDate(year: 2026, month: 10, day: 19))
        #expect(local.minuteOfDay == 9 * 60 + 30)
    }

    @Test func forecastIsComputedInRust() throws {
        let config = FfiGradingConfig(scale: .points, writtenWeight: 1, oralWeight: 1, rounding: .halfTowardBetter)
        let existing = [
            FfiAssessment(value: 9, weight: 1, category: .written),
            FfiAssessment(value: 10, weight: 1, category: .written),
        ]
        let result = try gradeForecast(
            config: config,
            existing: existing,
            planned: [FfiPlannedAssessment(weight: 1, category: .written)],
            targetGrade: 11
        )
        #expect(result.outcome == .reachable(required: 13))
    }

    @Test func invalidInputThrows() {
        let config = FfiGradingConfig(scale: .traditional, writtenWeight: 1, oralWeight: 1, rounding: .halfTowardBetter)
        #expect(throws: MeldeError.self) {
            try gradeSubjectSummary(config: config, assessments: [FfiAssessment(value: 7, weight: 1, category: .oral)])
        }
    }

    @Test func currentLessonAcrossTheBoundary() throws {
        let lesson = FfiLesson(
            id: "l1", subjectId: "mathe", weekday: .monday,
            startMinute: 480, endMinute: 525, parity: .every, room: nil
        )
        let timetable = FfiTimetable(lessons: [lesson], holidays: [], changes: [], weekAReference: nil)
        let at = FfiDateTime(date: FfiDate(year: 2026, month: 10, day: 19), minuteOfDay: 500)
        let current = try timetableCurrent(timetable: timetable, at: at)
        #expect(current?.subjectId == "mathe")
        #expect(!coreVersion().isEmpty)
    }
}
