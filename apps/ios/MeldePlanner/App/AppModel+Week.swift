import Foundation
import MeldeCore

/// One block in the Untis-style timetable: a period, or a double period merged
/// across a short break. Built from the dated WebUntis periods where they
/// exist, otherwise from the student's own weekly lessons.
struct TimetableBlock: Identifiable, Hashable {
    enum Kind: Hashable {
        case regular, substitution, cancelled, exam, roomChange
    }

    var id: String
    var date: Date
    var startMinute: Int
    var endMinute: Int
    /// Short label for narrow columns, e.g. "MAT".
    var shortTitle: String
    var subjectName: String
    var teacher: String
    var room: String?
    var originalRoom: String?
    var kind: Kind
    var info: String?
    var subjectID: UUID?
    /// The student's own lesson, when the block comes from their timetable.
    var lessonID: UUID?
    /// Side-by-side layout when blocks overlap (e.g. a course and an event).
    var lane = 0
    var lanes = 1
}

extension AppModel {
    /// Blocks for one day, double periods merged and overlaps given lanes.
    func timetableBlocks(on date: Date) -> [TimetableBlock] {
        let day = calendar.startOfDay(for: date)
        var blocks: [TimetableBlock]
        if let untis = data.untisTimetable, untisCovers(day, untis) {
            blocks = untis.periods
                .filter { calendar.isDate($0.date, inSameDayAs: day) }
                .map(block(from:))
        } else {
            blocks = occurrences(on: day).map { o in
                let subject = subject(for: o)
                let lesson = UUID(uuidString: o.lessonId)
                return TimetableBlock(
                    id: "lesson-\(o.lessonId)-\(o.startMinute)",
                    date: day,
                    startMinute: Int(o.startMinute),
                    endMinute: Int(o.endMinute),
                    shortTitle: subject?.displayShortName ?? "?",
                    subjectName: subject?.name ?? L("Unbekanntes Fach"),
                    teacher: subject?.teacher ?? "",
                    room: o.room,
                    kind: o.cancelled ? .cancelled : (o.substituted ? .substitution : .regular),
                    subjectID: subject?.id,
                    lessonID: lesson
                )
            }
        }
        blocks.sort { ($0.startMinute, $0.endMinute) < ($1.startMinute, $1.endMinute) }
        return assignLanes(mergeDoublePeriods(blocks))
    }

    /// Whether WebUntis data covers `day` (school look-ahead limits end earlier).
    private func untisCovers(_ day: Date, _ untis: UntisTimetable) -> Bool {
        calendar.startOfDay(for: untis.firstDay) <= day && day <= calendar.startOfDay(for: untis.lastDay)
    }

    /// The last day the school lets the student see, when WebUntis is connected.
    var untisVisibleUntil: Date? {
        guard data.untis != nil, let untis = data.untisTimetable else { return nil }
        return calendar.startOfDay(for: untis.lastDay)
    }

    /// The bell schedule: from WebUntis, or the student's own lesson times.
    var bellSchedule: [BellPeriod] {
        if let bells = data.untisTimetable?.bells, !bells.isEmpty { return bells }
        var seen = Set<[Int]>()
        let slots = data.lessons
            .map { [$0.startMinute, $0.endMinute] }
            .filter { seen.insert($0).inserted }
            .sorted { ($0[0], $0[1]) < ($1[0], $1[1]) }
        return slots.enumerated().map { BellPeriod(name: "\($0.offset + 1)", startMinute: $0.element[0], endMinute: $0.element[1]) }
    }

    private func block(from p: UntisPeriodRecord) -> TimetableBlock {
        let subject = data.subjects.first { $0.untisKey == p.subjectKey }
        let kind: TimetableBlock.Kind =
            p.cancelled ? .cancelled
            : p.exam ? .exam
            : p.originalRoom != nil ? .roomChange
            : p.irregular ? .substitution
            : .regular
        return TimetableBlock(
            id: "untis-\(p.id)",
            date: p.date,
            startMinute: p.startMinute,
            endMinute: p.endMinute,
            shortTitle: p.subjectShort.isEmpty ? String(p.subjectLong.prefix(4)) : p.subjectShort,
            subjectName: subject?.name ?? (p.subjectLong.isEmpty ? p.subjectShort : p.subjectLong),
            teacher: p.teacher,
            room: p.room,
            originalRoom: p.originalRoom,
            kind: kind,
            info: p.info,
            subjectID: subject?.id
        )
    }

    /// Joins back-to-back periods of the same course (as Untis draws them).
    private func mergeDoublePeriods(_ blocks: [TimetableBlock]) -> [TimetableBlock] {
        var merged: [TimetableBlock] = []
        for block in blocks {
            if var last = merged.last,
               last.subjectName == block.subjectName, last.teacher == block.teacher,
               last.room == block.room, last.kind == block.kind, last.info == block.info,
               block.startMinute >= last.endMinute, block.startMinute - last.endMinute <= 25 {
                last.endMinute = block.endMinute
                merged[merged.count - 1] = last
            } else {
                merged.append(block)
            }
        }
        return merged
    }

    /// Overlapping blocks share the column width.
    private func assignLanes(_ blocks: [TimetableBlock]) -> [TimetableBlock] {
        var result = blocks
        var laneEnds: [Int] = []
        for i in result.indices {
            if let free = laneEnds.firstIndex(where: { $0 <= result[i].startMinute }) {
                result[i].lane = free
                laneEnds[free] = result[i].endMinute
            } else {
                result[i].lane = laneEnds.count
                laneEnds.append(result[i].endMinute)
            }
        }
        for i in result.indices {
            let overlapping = result.filter { $0.startMinute < result[i].endMinute && result[i].startMinute < $0.endMinute }
            result[i].lanes = (overlapping.map(\.lane).max() ?? 0) + 1
        }
        return result
    }
}
