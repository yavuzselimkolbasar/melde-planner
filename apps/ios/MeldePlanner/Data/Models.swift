import Foundation

/// A school subject (Fach). Colors are palette keys, never raw values, so
/// every theme and appearance can render them accessibly.
nonisolated struct Subject: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var shortName: String = ""
    var color: SubjectColor = .blue
    var symbolName: String = "book.closed"
    var teacher: String = ""
    var updatedAt = Date()

    var displayShortName: String {
        shortName.isEmpty ? String(name.prefix(3)) : shortName
    }
}

nonisolated enum WeekParity: String, Codable, CaseIterable, Identifiable {
    case every, a, b
    var id: String { rawValue }
}

/// A recurring timetable slot. `weekday` is Monday-first (0 = Montag).
nonisolated struct Lesson: Identifiable, Codable, Hashable {
    var id = UUID()
    var subjectID: UUID
    var weekday: Int
    var startMinute: Int
    var endMinute: Int
    var parity: WeekParity = .every
    var room: String = ""
    var updatedAt = Date()
}

nonisolated struct Holiday: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var firstDay: Date
    var lastDay: Date
}

/// One recorded Meldung. An activity count, never a grade.
nonisolated struct ParticipationEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var subjectID: UUID?
    var lessonID: UUID?
    var recordedAt: Date
}

nonisolated enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case german = "de"
    case turkish = "tr"
    case english = "en"

    var id: String { rawValue }

    /// Shown in its own language so users can always find theirs.
    var nativeName: String {
        switch self {
        case .german: "Deutsch"
        case .turkish: "Türkçe"
        case .english: "English"
        }
    }
}

nonisolated struct Preferences: Codable, Hashable {
    var language: AppLanguage = .german
    var theme: AppTheme = .system
    /// Weekly Melde target; `nil` until the student sets or accepts one.
    var weeklyGoal: Int?
    /// Any date in an A week; enables A/B-week lessons.
    var weekAReference: Date?
}

/// Everything persisted on device. Versioned so later migrations
/// (Phase 2: Rust-owned SQLite + Supabase sync) can import it.
nonisolated struct AppData: Codable {
    static let currentSchemaVersion = 1

    var schemaVersion = AppData.currentSchemaVersion
    var subjects: [Subject] = []
    var lessons: [Lesson] = []
    var holidays: [Holiday] = []
    var participation: [ParticipationEntry] = []
    var preferences = Preferences()
}
