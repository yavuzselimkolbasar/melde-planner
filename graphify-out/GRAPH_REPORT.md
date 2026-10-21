# Graph Report - Mledeapp  (2026-10-21)

## Corpus Check
- 83 files · ~34,719 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 7 file(s) not represented in the graph (top: (none) 5, .xcstrings 1, .toml 1)

## Summary
- 1050 nodes · 2149 edges · 79 communities (63 shown, 16 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 227 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b1a5130d`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- String
- Card
- Results
- Melde Planner
- .recordParticipation
- DayColumn
- ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package
- DocumentScanner
- TaskEditorView
- Date
- SchoolTask
- MeldeError
- melde-statistics/src/lib.rs
- LocalTime
- AppModel
- View
- SubjectColor
- .toggleDone
- SubjectIcon
- participation.rs
- AppTheme
- ExamListView
- melde-ffi/src/lib.rs
- Timetable
- Date
- grades.rs
- FfiDate
- .subject
- Identifiable
- check_strings.py
- TaskPriority
- Weekday
- .persist
- .body
- ValidationError
- FfiTaskGroup
- Group
- melde-scheduling/src/lib.rs
- TaskRecurrence
- .entries
- AppLanguage
- FfiRecurrence
- timetable.rs
- Recurrence
- FfiTimetableIssue
- ADR-0006: Sync with Supabase, not iCloud
- average.rs
- ADR-0007: Optional WebUntis import
- FfiPriority
- FfiWeekParity
- .body
- forecast.rs
- .status
- GradeScale
- Melde Planner — Product & Engineering Spec
- AppTab
- ValidationError
- LessonEditorView
- Decision Log.md
- Windows 11 → macOS build workflow
- FfiWeekday
- properties.rs
- Home.md
- {{date}} — {{title}}
- {{title}}
- Decision Log.md
- melde-core
- Melde Planner — Project Brain
- Melde Planner
- build-rust-ios.sh
- Package.swift
- scan-skills.sh
- uniffi-bindgen

## God Nodes (most connected - your core abstractions)
1. `AppModel` - 90 edges
2. `L()` - 48 edges
3. `SchoolTask` - 29 edges
4. `MeldeError` - 29 edges
5. `AppData` - 26 edges
6. `SubjectColor` - 22 edges
7. `ValidationError` - 22 edges
8. `Subject` - 21 edges
9. `AppTheme` - 21 edges
10. `GradeScale` - 19 edges

## Surprising Connections (you probably didn't know these)
- `Technology decisions` --references--> `AppModel`  [INFERRED]
  vault/03-Architecture/Architecture Overview.md → apps/ios/MeldePlanner/App/AppModel.swift
- `Glossary` --references--> `Subject`  [INFERRED]
  vault/05-Glossary/Glossary.md → apps/ios/MeldePlanner/Data/Models.swift
- `Glossary` --references--> `Lesson`  [INFERRED]
  vault/05-Glossary/Glossary.md → apps/ios/MeldePlanner/Data/Models.swift
- `Glossary` --references--> `Holiday`  [INFERRED]
  vault/05-Glossary/Glossary.md → apps/ios/MeldePlanner/Data/Models.swift
- `Glossary` --references--> `ParticipationEntry`  [INFERRED]
  vault/05-Glossary/Glossary.md → apps/ios/MeldePlanner/Data/Models.swift

## Import Cycles
- 2-file cycle: `crates/melde-core/src/lib.rs -> crates/melde-core/src/time.rs -> crates/melde-core/src/lib.rs`

## Communities (79 total, 16 thin omitted)

### Community 0 - "String"
Cohesion: 0.30
Nodes (4): TimeText, WeekdayText, .calendar, .body

### Community 1 - "Card"
Cohesion: 0.13
Nodes (17): ThemedBackground, .body, DayValue, .id, StatisticsView, .body, .referenceDate, SubjectBreakdownCard (+9 more)

### Community 2 - "Results"
Cohesion: 0.13
Nodes (13): ADR-0001 — AI tooling, skills and project memory, Consequences, Context, Decision, Addendum — Ponytail, RTK and LLM Council (2026-10-21), Apple skills plugin (indie-apple-stack) — 183 targets — CRITICAL: 4, HIGH: 12, LOW: 127, MEDIUM: 40, claude-mem plugin skills — 27 targets — CRITICAL: 2, HIGH: 2, LOW: 22, MEDIUM: 1, Not installed (by choice, not for security reasons) (+5 more)

### Community 3 - "Melde Planner"
Cohesion: 0.22
Nodes (8): Command output, Commands (Windows), graphify, Hard rules, Melde Planner, Project memory (three layers), Read first, Skills

### Community 5 - "DayColumn"
Cohesion: 0.23
Nodes (8): DayColumn, HomeworkPrefill, LessonCard, .body, TimetableView, .body, .days, WeekdayBar

### Community 6 - "ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package"
Cohesion: 0.33
Nodes (5): ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package, Alternatives considered, Consequences, Context, Decision

### Community 7 - "DocumentScanner"
Cohesion: 0.05
Nodes (16): ExamFiles, Coordinator, DocumentScanner, .isSupported, PDFKitView, ExamDetailView, .body, ExamEditorView (+8 more)

### Community 8 - "TaskEditorView"
Cohesion: 0.08
Nodes (11): .body, TaskEditorView, .body, .defaultReminder, .dueBinding, .reminderBinding, DueText, TaskListView (+3 more)

### Community 9 - "Date"
Cohesion: 0.15
Nodes (23): Date, d(), group_of(), grouped(), grouped_sorts_by_due_then_priority(), groups_by_due_date(), homework_streak(), homework_streak_rules() (+15 more)

### Community 10 - "SchoolTask"
Cohesion: 0.24
Nodes (12): AppData, ExamDocument, Holiday, Lesson, ParticipationEntry, Preferences, SchoolTask, .isDone (+4 more)

### Community 11 - "MeldeError"
Cohesion: 0.22
Nodes (18): MeldeError, InvalidInput, date(), FfiTask, FfiTaskKind, Homework, Todo, FfiTaskSection (+10 more)

### Community 12 - "melde-statistics/src/lib.rs"
Cohesion: 0.17
Nodes (16): d(), daily_counts(), daily_counts_include_empty_days(), entry(), goal_progress(), goal_progress_caps_fraction(), GoalProgress, ParticipationEntry (+8 more)

### Community 13 - "LocalTime"
Cohesion: 0.13
Nodes (3): LocalDateTime, LocalTime, .MINUTES_PER_DAY

### Community 14 - "AppModel"
Cohesion: 0.15
Nodes (7): AppModel, .currentDate, .ffiTimetable, .lessons, .preferences, .exams, .body

### Community 15 - "View"
Cohesion: 0.13
Nodes (14): L(), CalendarView, AboutView, .body, MoreView, .body, SettingsView, SubjectEditorView (+6 more)

### Community 16 - "SubjectColor"
Cohesion: 0.11
Nodes (17): DS, SubjectColor, blue, brown, .color, cyan, gray, green (+9 more)

### Community 17 - ".toggleDone"
Cohesion: 0.16
Nodes (3): .tasks, Reminders, UserNotifications

### Community 18 - "SubjectIcon"
Cohesion: 0.15
Nodes (8): Badge, .body, Card, .body, CardHeaderLabelStyle, ProgressRing, .body, .body

### Community 19 - "participation.rs"
Cohesion: 0.25
Nodes (11): entries(), FfiDayCount, FfiGoalProgress, FfiParticipationEntry, FfiSubjectCount, FfiWeekSummary, participation_daily_counts(), participation_goal_progress() (+3 more)

### Community 20 - "AppTheme"
Cohesion: 0.12
Nodes (13): AppTheme, blue, .colorScheme, dark, green, .id, light, .localizedName (+5 more)

### Community 21 - "ExamListView"
Cohesion: 0.17
Nodes (7): ExamListView, .actionButtons, .groups, Mode, existing, new, PendingExam

### Community 22 - "melde-ffi/src/lib.rs"
Cohesion: 0.19
Nodes (4): FfiDate, FfiDateTime, invalid(), LocalDateTime

### Community 23 - "Timetable"
Cohesion: 0.35
Nodes (5): Holiday, Lesson, monday_of(), Occurrence, Timetable

### Community 25 - "grades.rs"
Cohesion: 0.07
Nodes (37): assessments(), FfiAssessment, FfiCategory, Oral, Written, FfiForecast, FfiForecastOutcome, AlreadySecured (+29 more)

### Community 26 - "FfiDate"
Cohesion: 0.07
Nodes (20): FfiDate, FfiDateTime, FfiWeekday, .mondayIndex, BridgeTests, .ffiEntries, Localization, Calendar (+12 more)

### Community 27 - ".subject"
Cohesion: 0.31
Nodes (4): LessonRow, .body, .body, .body

### Community 28 - "Identifiable"
Cohesion: 0.20
Nodes (7): TaskSection, .id, WeekParity, a, b, every, .id

### Community 29 - "check_strings.py"
Cohesion: 0.31
Nodes (3): main(), source_keys(), to_key()

### Community 30 - "TaskPriority"
Cohesion: 0.20
Nodes (9): TaskKind, homework, .id, todo, TaskPriority, high, .id, low (+1 more)

### Community 31 - "Weekday"
Cohesion: 0.20
Nodes (9): Weekday, .ALL, Friday, Monday, Saturday, Sunday, Thursday, Tuesday (+1 more)

### Community 34 - "ValidationError"
Cohesion: 0.32
Nodes (6): ensure_finite(), ensure_range(), ValidationError, Invalid, NotFinite, OutOfRange

### Community 35 - "FfiTaskGroup"
Cohesion: 0.25
Nodes (8): FfiTaskGroup, Completed, Later, NoDate, Overdue, ThisWeek, Today, Tomorrow

### Community 36 - "Group"
Cohesion: 0.25
Nodes (8): Group, Completed, Later, NoDate, Overdue, ThisWeek, Today, Tomorrow

### Community 37 - "melde-scheduling/src/lib.rs"
Cohesion: 0.13
Nodes (27): ab_weeks_alternate(), cancelled_and_substituted_lessons(), ChangeKind, Cancelled, Substituted, current_and_next_lesson(), d(), holidays_remove_lessons() (+19 more)

### Community 38 - "TaskRecurrence"
Cohesion: 0.29
Nodes (7): TaskRecurrence, biweekly, daily, .id, never, weekdays, weekly

### Community 39 - ".entries"
Cohesion: 0.33
Nodes (3): RecordOutcome, needsSubject, recorded

### Community 40 - "AppLanguage"
Cohesion: 0.33
Nodes (6): AppLanguage, english, german, .id, .nativeName, turkish

### Community 41 - "FfiRecurrence"
Cohesion: 0.33
Nodes (6): FfiRecurrence, Biweekly, Daily, Never, Weekdays, Weekly

### Community 42 - "timetable.rs"
Cohesion: 0.17
Nodes (18): current_lesson_round_trip(), FfiChangeKind, Cancelled, Substituted, FfiHoliday, FfiLesson, FfiOccurrence, FfiTimetable (+10 more)

### Community 43 - "Recurrence"
Cohesion: 0.33
Nodes (6): Recurrence, Biweekly, Daily, None, Weekdays, Weekly

### Community 44 - "FfiTimetableIssue"
Cohesion: 0.40
Nodes (5): FfiTimetableIssue, EmptyLesson, InvertedHoliday, Overlap, UnknownLesson

### Community 45 - "ADR-0006: Sync with Supabase, not iCloud"
Cohesion: 0.40
Nodes (4): ADR-0006: Sync with Supabase, not iCloud, Consequences, Context, Decision

### Community 46 - "average.rs"
Cohesion: 0.22
Nodes (18): a(), Assessment, Category, category_average(), Oral, Written, empty_subject_has_no_average(), fifty_fifty_written_oral() (+10 more)

### Community 47 - "ADR-0007: Optional WebUntis import"
Cohesion: 0.40
Nodes (4): ADR-0007: Optional WebUntis import, Consequences, Context, Decision

### Community 48 - "FfiPriority"
Cohesion: 0.50
Nodes (4): FfiPriority, High, Low, Normal

### Community 49 - "FfiWeekParity"
Cohesion: 0.50
Nodes (4): FfiWeekParity, A, B, Every

### Community 61 - ".body"
Cohesion: 0.17
Nodes (7): DashboardView, .body, GettingStartedCard, TodayCard, WeeklyGoalSheet, WeekParticipationCard, HomeworkCard

### Community 68 - "forecast.rs"
Cohesion: 0.25
Nodes (16): detects_already_secured_target(), detects_unreachable_target(), Forecast, forecast(), ForecastOutcome, AlreadySecured, Reachable, Unreachable (+8 more)

### Community 88 - ".status"
Cohesion: 0.16
Nodes (6): SubjectIcon, .body, MeldeAccessory, .body, SubjectPickerSheet, .body

### Community 100 - "GradeScale"
Cohesion: 0.21
Nodes (7): GradeScale, Points, Traditional, RoundingRule, HalfTowardBetter, HalfTowardWorse, traditional_value()

### Community 113 - "Melde Planner — Product & Engineering Spec"
Cohesion: 0.14
Nodes (14): 10. Begin development with, 1. Role, 2. Development environment & technical requirements, 3. Design direction — Apple-level premium (highest priority), 4. Features, 5. Additional product requirements, 6. Project structure (suggested; adjust to best practice), 7. Development phases (+6 more)

### Community 114 - "AppTab"
Cohesion: 0.07
Nodes (18): ExamError, storage, unreadablePDF, MeldePlannerApp, .body, LoadError, newerSchema, unreadable (+10 more)

### Community 125 - "ValidationError"
Cohesion: 0.18
Nodes (8): EPSILON, kmk_point_table_round_trips(), points_to_traditional(), Tendency, Minus, None, Plus, traditional_to_points()

### Community 139 - "Decision Log.md"
Cohesion: 0.50
Nodes (3): ADR-0003: Offline-first persistence and sync model, Consequences, Decision

### Community 140 - "Windows 11 → macOS build workflow"
Cohesion: 0.17
Nodes (10): ADR-0004: Windows-first development with macOS CI, Consequences, Decision, Daily loop, Interactive macOS when needed, Local toolchain (installed 2026-10-21), One-time Apple setup (needs your accounts; Claude cannot do these), Status (+2 more)

### Community 152 - "FfiWeekday"
Cohesion: 0.20
Nodes (9): FfiWeekday, Friday, Monday, Saturday, Sunday, Thursday, Tuesday, Wednesday (+1 more)

### Community 153 - "properties.rs"
Cohesion: 0.50
Nodes (5): category_strategy(), config_and_assessments(), rounding_strategy(), scale_strategy(), value_for()

### Community 232 - "{{date}} — {{title}}"
Cohesion: 0.25
Nodes (6): Session Log, {{date}} — {{title}}, Done (not verified), Done (verified), Goal, Next

### Community 241 - "{{title}}"
Cohesion: 0.29
Nodes (7): Blocked on, Files, Implemented, Not yet, Scope, Tests, {{title}}

### Community 258 - "Decision Log.md"
Cohesion: 0.17
Nodes (9): ADR-0005: The app is called Meldo, Consequences, Decision, Decision Log, ADR-NNNN — {{title}}, Alternatives considered, Consequences, Context (+1 more)

### Community 283 - "melde-core"
Cohesion: 0.67
Nodes (6): melde-core, melde-ffi, melde-grades, melde-scheduling, melde-statistics, melde-tasks

### Community 312 - "Melde Planner — Project Brain"
Cohesion: 0.50
Nodes (4): Conventions, Generated (do not hand-edit), Melde Planner — Project Brain, Start here

### Community 328 - "Melde Planner"
Cohesion: 0.67
Nodes (3): Melde Planner, Quick start (Windows 11), Status

## Knowledge Gaps
- **180 isolated node(s):** `unreadablePDF`, `storage`, `.id`, `Observation`, `.currentDate` (+175 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 393 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppModel` connect `AppModel` to `Card`, `.recordParticipation`, `DayColumn`, `DocumentScanner`, `TaskEditorView`, `SchoolTask`, `View`, `.toggleDone`, `ExamListView`, `Date`, `FfiDate`, `.subject`, `Identifiable`, `.persist`, `.body`, `.entries`, `.body`, `AppTab`, `LessonEditorView`?**
  _High betweenness centrality (0.144) - this node is a cross-community bridge._
- **Are the 17 inferred relationships involving `AppModel` (e.g. with `.greeting()` and `.isOver()`) actually correct?**
  _`AppModel` has 17 INFERRED edges - model-reasoned connections that need verification._
- **What connects `unreadablePDF`, `storage`, `.id` to the rest of the system?**
  _180 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Card` be split into smaller, more focused modules?**
  _Cohesion score 0.1341991341991342 - nodes in this community are weakly interconnected._
- **Why does `Subject` connect `SchoolTask` to `.persist`, `.recordParticipation`, `AppModel`, `View`, `SubjectColor`, `ExamListView`, `.status`, `FfiDate`, `.subject`, `Identifiable`?**
  _High betweenness centrality (0.056) - this node is a cross-community bridge._
- **Are the 46 inferred relationships involving `L()` (e.g. with `.init()` and `.persist()`) actually correct?**
  _`L()` has 46 INFERRED edges - model-reasoned connections that need verification._
- **Should `Results` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._