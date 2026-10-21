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
    /// Untis short name when imported from WebUntis; matches subjects across imports.
    var untisKey: String?

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
    /// `true` when this lesson came from WebUntis and is updated by later imports.
    var fromUntis: Bool?
}

/// A change to one lesson on one date (Ausfall or Vertretung), e.g. from WebUntis.
nonisolated struct TimetableChangeRecord: Identifiable, Codable, Hashable {
    enum Kind: String, Codable { case cancelled, substituted }

    var id = UUID()
    var lessonID: UUID
    /// The day (local midnight).
    var date: Date
    var kind: Kind
    var substituteSubjectID: UUID?
    var room: String?
    var fromUntis: Bool?
}

/// The student's WebUntis connection. The password is kept in the Keychain, never here.
nonisolated struct UntisLink: Codable, Hashable {
    var server: String
    var loginName: String
    var schoolName: String
    var user: String
    var lastSync: Date?
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

nonisolated enum TaskKind: String, Codable, CaseIterable, Identifiable {
    case homework, todo
    var id: String { rawValue }
}

nonisolated enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case low, normal, high
    var id: String { rawValue }
}

nonisolated enum TaskRecurrence: String, Codable, CaseIterable, Identifiable {
    case never, daily, weekdays, weekly, biweekly
    var id: String { rawValue }
}

/// A Hausaufgabe or to-do. Named `SchoolTask` to stay clear of Swift's `Task`.
nonisolated struct SchoolTask: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var notes: String = ""
    var kind: TaskKind = .homework
    var subjectID: UUID?
    /// Due day (local midnight); `nil` for undated to-dos.
    var dueDate: Date?
    var completedAt: Date?
    var priority: TaskPriority = .normal
    var recurrence: TaskRecurrence = .never
    var reminderAt: Date?
    var updatedAt = Date()

    var isDone: Bool { completedAt != nil }
}

/// A scanned or imported exam (Klassenarbeit, Klausur, Test) stored as a PDF.
nonisolated struct ExamDocument: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var subjectID: UUID?
    var date: Date
    /// File name inside the app's exam folder.
    var fileName: String
    var pageCount: Int
    /// The grade as written by the teacher (e.g. "2-" or "11 P."), shown as-is.
    var grade: String = ""
    var notes: String = ""
    var updatedAt = Date()
}

/// Cards on the home screen; order and visibility are customizable.
nonisolated enum DashboardCard: String, Codable, CaseIterable, Identifiable {
    case today, participation, homework
    var id: String { rawValue }
}

/// Alternate app icons (work with free signing).
nonisolated enum AppIconChoice: String, Codable, CaseIterable, Identifiable {
    case standard, orange, night
    var id: String { rawValue }
    /// Asset catalog name for `setAlternateIconName`; `nil` is the default icon.
    var assetName: String? {
        switch self {
        case .standard: nil
        case .orange: "AppIcon-Orange"
        case .night: "AppIcon-Night"
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
    /// Ask "Hast du dich gemeldet?" after each lesson (local notification).
    var askAfterLesson = false
    /// Show a Live Activity during lessons.
    var liveActivities = true
    var showMascot = true
    var haptics = true
    /// Visible cards in display order; cards not listed are hidden.
    var dashboardCards: [DashboardCard] = DashboardCard.allCases
    var appIcon: AppIconChoice = .standard

    init() {}

    // Every field is optional when decoding, so files from older versions keep loading.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        language = try c.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .german
        theme = try c.decodeIfPresent(AppTheme.self, forKey: .theme) ?? .system
        weeklyGoal = try c.decodeIfPresent(Int.self, forKey: .weeklyGoal)
        weekAReference = try c.decodeIfPresent(Date.self, forKey: .weekAReference)
        askAfterLesson = try c.decodeIfPresent(Bool.self, forKey: .askAfterLesson) ?? false
        liveActivities = try c.decodeIfPresent(Bool.self, forKey: .liveActivities) ?? true
        showMascot = try c.decodeIfPresent(Bool.self, forKey: .showMascot) ?? true
        haptics = try c.decodeIfPresent(Bool.self, forKey: .haptics) ?? true
        dashboardCards = try c.decodeIfPresent([DashboardCard].self, forKey: .dashboardCards) ?? DashboardCard.allCases
        appIcon = try c.decodeIfPresent(AppIconChoice.self, forKey: .appIcon) ?? .standard
    }
}

/// Everything persisted on device. Versioned so later migrations
/// (Rust-owned SQLite + Supabase sync) can import it.
nonisolated struct AppData: Codable {
    /// 2: adds tasks and exams.
    static let currentSchemaVersion = 2

    var schemaVersion = AppData.currentSchemaVersion
    var subjects: [Subject] = []
    var lessons: [Lesson] = []
    var holidays: [Holiday] = []
    var participation: [ParticipationEntry] = []
    var tasks: [SchoolTask] = []
    var exams: [ExamDocument] = []
    var changes: [TimetableChangeRecord] = []
    var untis: UntisLink?
    var preferences = Preferences()

    init() {}

    // Missing collections decode as empty, so version-1 files load unchanged.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try c.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 1
        subjects = try c.decodeIfPresent([Subject].self, forKey: .subjects) ?? []
        lessons = try c.decodeIfPresent([Lesson].self, forKey: .lessons) ?? []
        holidays = try c.decodeIfPresent([Holiday].self, forKey: .holidays) ?? []
        participation = try c.decodeIfPresent([ParticipationEntry].self, forKey: .participation) ?? []
        tasks = try c.decodeIfPresent([SchoolTask].self, forKey: .tasks) ?? []
        exams = try c.decodeIfPresent([ExamDocument].self, forKey: .exams) ?? []
        changes = try c.decodeIfPresent([TimetableChangeRecord].self, forKey: .changes) ?? []
        untis = try c.decodeIfPresent(UntisLink.self, forKey: .untis)
        preferences = try c.decodeIfPresent(Preferences.self, forKey: .preferences) ?? Preferences()
    }
}
