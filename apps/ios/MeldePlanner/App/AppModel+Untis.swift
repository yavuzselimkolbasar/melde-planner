import Foundation
import MeldeCore

/// WebUntis import (ADR-0007): fetch this week and the next, let Rust derive
/// subjects, weekly lessons and changes, then merge into the student's data.
extension AppModel {
    struct UntisImportSummary: Equatable {
        var newSubjects = 0
        var lessons = 0
        var changes = 0
        var skippedExtra = 0
    }

    private static func keychainAccount(_ link: UntisLink) -> String {
        "\(link.server)|\(link.loginName)|\(link.user)"
    }

    var untisLink: UntisLink? { data.untis }

    /// Logs in, imports, and remembers the connection (password → Keychain).
    func connectUntis(school: FfiUntisSchool, user: String, password: String) async throws(UntisClient.Failure) -> UntisImportSummary {
        let link = UntisLink(server: school.server, loginName: school.loginName, schoolName: school.displayName, user: user)
        let summary = try await importFromUntis(link: link, password: password)
        _ = Keychain.save(password, account: Self.keychainAccount(link))
        return summary
    }

    /// Re-imports with the stored password. Silent no-op when not connected.
    @discardableResult
    func refreshUntis() async throws(UntisClient.Failure) -> UntisImportSummary? {
        guard let link = data.untis, let password = Keychain.read(account: Self.keychainAccount(link)) else { return nil }
        return try await importFromUntis(link: link, password: password)
    }

    /// Refreshes at most every three hours, e.g. when the app comes to the foreground.
    func refreshUntisIfStale() async {
        guard let last = data.untis?.lastSync, currentDate.timeIntervalSince(last) > 3 * 3600 else { return }
        _ = try? await refreshUntis()
    }

    /// Forgets the connection and the password. Imported lessons stay as normal lessons.
    func disconnectUntis() {
        if let link = data.untis { Keychain.delete(account: Self.keychainAccount(link)) }
        mutate { data in
            data.untis = nil
            data.changes.removeAll { $0.fromUntis == true }
            for i in data.lessons.indices { data.lessons[i].fromUntis = nil }
        }
    }

    private func importFromUntis(link: UntisLink, password: String) async throws(UntisClient.Failure) -> UntisImportSummary {
        let client = UntisClient()
        let auth = try await client.login(server: link.server, loginName: link.loginName, user: link.user, password: password)
        let today = FfiDate(currentDate, calendar: calendar)
        guard let weekStart = try? untisWeekStart(date: today),
              let monday = weekStart.date(in: calendar),
              let lastDay = calendar.date(byAdding: .day, value: 13, to: monday) else { throw .noAccess("date") }
        let body = try await client.timetable(
            server: link.server, loginName: link.loginName, auth: auth,
            first: weekStart, last: FfiDate(lastDay, calendar: calendar)
        )
        await client.logout(server: link.server, loginName: link.loginName)
        let schedule: FfiUntisSchedule
        do {
            schedule = try untisDeriveSchedule(timetableBody: body, weekAStart: weekStart)
        } catch let MeldeError.UntisServer(code, message) {
            throw code == -8520 ? .wrongCredentials : .server(code: code, message: message)
        } catch {
            throw .noAccess("\(error)")
        }
        var syncedLink = link
        syncedLink.lastSync = currentDate
        return applyUntis(schedule, weekAStart: monday, link: syncedLink)
    }

    /// Merges an Untis schedule. Existing subjects are matched by Untis key or
    /// name; existing lessons in the same slot keep their id (and Meldungen).
    func applyUntis(_ schedule: FfiUntisSchedule, weekAStart: Date, link: UntisLink) -> UntisImportSummary {
        var summary = UntisImportSummary(changes: schedule.changes.count, skippedExtra: Int(schedule.skippedExtra))
        let now = currentDate
        let calendar = calendar
        mutate { data in
            // Subjects.
            var subjectByKey: [String: UUID] = [:]
            for (index, s) in schedule.subjects.enumerated() {
                if let i = data.subjects.firstIndex(where: { $0.untisKey == s.key })
                    ?? data.subjects.firstIndex(where: {
                        $0.name.compare(s.name, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
                            || (!s.shortName.isEmpty && $0.shortName.caseInsensitiveCompare(s.shortName) == .orderedSame)
                    }) {
                    data.subjects[i].untisKey = s.key
                    subjectByKey[s.key] = data.subjects[i].id
                } else {
                    let subject = Subject(
                        name: s.name, shortName: s.shortName,
                        color: SubjectColor.allCases[(data.subjects.count + index) % SubjectColor.allCases.count],
                        symbolName: SubjectSymbols.guess(for: s.name),
                        updatedAt: now, untisKey: s.key
                    )
                    data.subjects.append(subject)
                    subjectByKey[s.key] = subject.id
                    summary.newSubjects += 1
                }
            }

            // Lessons: reuse ids of lessons in the same slot, replace earlier Untis lessons.
            var kept: Set<UUID> = []
            var lessonByKeySlot: [String: UUID] = [:]
            for l in schedule.lessons {
                guard let subjectID = subjectByKey[l.subjectKey] else { continue }
                let weekday = l.weekday.mondayIndex
                let parity: WeekParity = switch l.parity {
                case .every: .every
                case .a: .a
                case .b: .b
                }
                let existing = data.lessons.firstIndex {
                    $0.weekday == weekday && $0.startMinute == Int(l.startMinute) && $0.subjectID == subjectID
                }
                let id = existing.map { data.lessons[$0].id } ?? UUID()
                let lesson = Lesson(
                    id: id, subjectID: subjectID, weekday: weekday,
                    startMinute: Int(l.startMinute), endMinute: Int(l.endMinute),
                    parity: parity, room: l.room ?? "", updatedAt: now, fromUntis: true
                )
                if let existing { data.lessons[existing] = lesson } else { data.lessons.append(lesson) }
                kept.insert(id)
                lessonByKeySlot["\(l.subjectKey)|\(weekday)|\(l.startMinute)"] = id
            }
            let removed = Set(data.lessons.filter { $0.fromUntis == true && !kept.contains($0.id) }.map(\.id))
            data.lessons.removeAll { removed.contains($0.id) }
            for i in data.participation.indices where data.participation[i].lessonID.map(removed.contains) == true {
                data.participation[i].lessonID = nil
            }
            summary.lessons = kept.count

            // Changes: replace earlier Untis changes.
            data.changes.removeAll { $0.fromUntis == true || removed.contains($0.lessonID) }
            for c in schedule.changes {
                guard let day = c.date.date(in: calendar) else { continue }
                let weekday = calendar.mondayIndex(of: day)
                guard let lessonID = lessonByKeySlot["\(c.subjectKey)|\(weekday)|\(c.startMinute)"] else { continue }
                switch c.kind {
                case .cancelled:
                    data.changes.append(TimetableChangeRecord(lessonID: lessonID, date: day, kind: .cancelled, fromUntis: true))
                case .substituted(let subjectKey, let room):
                    data.changes.append(TimetableChangeRecord(
                        lessonID: lessonID, date: day, kind: .substituted,
                        substituteSubjectID: subjectKey.flatMap { subjectByKey[$0] }, room: room, fromUntis: true
                    ))
                }
            }

            // A/B weeks: the first imported week is week A when lessons alternate.
            if schedule.lessons.contains(where: { $0.parity != .every }) {
                data.preferences.weekAReference = weekAStart
            }
            data.untis = link
        }
        return summary
    }
}

/// SF Symbol guesses for common German subject names.
enum SubjectSymbols {
    static func guess(for name: String) -> String {
        let n = name.lowercased()
        let table: [(String, String)] = [
            ("mathe", "function"), ("deutsch", "text.book.closed"), ("englisch", "character.book.closed"),
            ("franz", "character.book.closed"), ("latein", "building.columns"), ("spanisch", "character.book.closed"),
            ("physik", "atom"), ("chemie", "flask"), ("bio", "leaf"), ("geschicht", "building.columns"),
            ("erdkunde", "globe.europe.africa"), ("geograph", "globe.europe.africa"), ("politik", "scalemass"),
            ("sozial", "scalemass"), ("wirtschaft", "chart.line.uptrend.xyaxis"), ("kunst", "paintpalette"),
            ("musik", "music.note"), ("sport", "figure.run"), ("religion", "hands.and.sparkles"),
            ("ethik", "hands.and.sparkles"), ("philosoph", "theatermasks"), ("informatik", "laptopcomputer"),
            ("theater", "theatermasks"),
        ]
        return table.first { n.contains($0.0) }?.1 ?? "book.closed"
    }
}
