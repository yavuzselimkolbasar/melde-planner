# Graph Report - Mledeapp  (2026-10-21)

## Corpus Check
- 136 files · ~79,504 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 7 file(s) not represented in the graph (top: (none) 5, .xcstrings 1, .toml 1)

## Summary
- 2210 nodes · 4863 edges · 179 communities (104 shown, 75 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 469 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `fc226063`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Card
- StatisticsView.swift
- Results
- Melde Planner
- .recordParticipation
- DayGrid
- derive.rs
- String
- Date
- Codable
- MeldeError
- melde-statistics/src/lib.rs
- ValidationError
- TaskEditorView
- MeldoUITests
- View
- Date
- properties.rs
- participation.rs
- Preferences
- View
- MeldeError
- LogParticipationIntent
- Date
- grades.rs
- Context
- ExamListView
- CustomizableCardGrid
- GradeEditorView
- DashboardCard
- AppModel
- LocalStore
- AppTab
- FfiTaskGroup
- StatusView
- melde-scheduling/src/lib.rs
- AppIconChoice
- SwiftUI
- CodingKeys
- TimetableView
- timetable.rs
- UntisLoginWatcher
- MeldePlannerApp.swift
- ADR-0003: Offline-first persistence and sync model
- average.rs
- ADR-0007: Optional WebUntis import
- Weekday
- rpc.rs
- TaskEditorView
- Foundation
- .preview
- MoreWidgets.swift
- UntisClient
- rest.rs
- TimetableBlock
- LessonEditorView
- CardSize
- L
- AppDelegate
- forecast.rs
- TimetableView.swift
- .body
- .seed
- AppearanceChoice
- .dayDetails
- check_strings.py
- FfiDate
- MeldenButton
- .applyUntis
- UntisLoginView
- AppGroup
- GradeScale
- FfiRecurrence
- AbsenceRow
- ADR-0008: Microsoft Teams assignments via Microsoft Graph
- AppModel+Holidays.swift
- ADR-0006: Sync with Supabase, not iCloud
- DocumentScanner
- PreviewResult
- AppLanguage
- TaskBoard
- TaskPriority
- Melde Planner — Product & Engineering Spec
- .mutate
- TaskRecurrence
- WidgetKit
- SubjectColor
- .perform
- String
- Architecture Overview
- UntisWebView
- Surfaces.swift
- BlockStyle
- ValidationError
- Kind
- .getTimeline
- StatsEntry
- .widgetWriteIsNotLostWhenAppSaves
- TimetableMode
- ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package
- Windows 11 → macOS build workflow
- PDFKitView
- .entries
- Kind
- FfiWeekParity
- ADR-0005: The app is called Meldo
- Melde Planner
- Mascot
- Home.md
- {{date}} — {{title}}
- {{title}}
- ADR-NNNN — {{title}}
- melde-core
- Melde Planner — Project Brain
- build-rust-ios.sh
- Package.swift
- scan-skills.sh
- uniffi-bindgen

## God Nodes (most connected - your core abstractions)
1. `AppModel` - 146 edges
2. `L()` - 145 edges
3. `AppData` - 51 edges
4. `MeldeError` - 49 edges
5. `CardSize` - 33 edges
6. `TimetableBlock` - 31 edges
7. `DashboardCard` - 28 edges
8. `UntisClient` - 28 edges
9. `Calendar` - 27 edges
10. `LocalTime` - 27 edges

## Surprising Connections (you probably didn't know these)
- `Decision` --references--> `SchoolTask`  [INFERRED]
  vault/02-Decisions/ADR-0008 Teams assignments via Graph.md → apps/ios/Shared/Models.swift
- `Technology decisions` --references--> `AppModel`  [INFERRED]
  vault/03-Architecture/Architecture Overview.md → apps/ios/MeldePlanner/App/AppModel.swift
- `Rules that keep the architecture honest` --references--> `FfiDateTime`  [INFERRED]
  vault/03-Architecture/Architecture Overview.md → apps/ios/MeldeCore/Sources/MeldeCore/CalendarBridge.swift
- `Rules that keep the architecture honest` --references--> `FfiDate`  [INFERRED]
  vault/03-Architecture/Architecture Overview.md → apps/ios/MeldeCore/Sources/MeldeCore/CalendarBridge.swift
- `.menu` --calls--> `L()`  [INFERRED]
  apps/ios/MeldePlanner/Features/Timetable/TimetableView.swift → apps/ios/Shared/Localization.swift

## Import Cycles
- 2-file cycle: `crates/melde-core/src/lib.rs -> crates/melde-core/src/time.rs -> crates/melde-core/src/lib.rs`

## Communities (179 total, 75 thin omitted)

### Community 0 - "Card"
Cohesion: 0.10
Nodes (17): Badge, .body, LessonRow, .body, ProgressRing, .body, SubjectIcon, .body (+9 more)

### Community 1 - "StatisticsView.swift"
Cohesion: 0.15
Nodes (15): DayValue, .id, StatisticsView, .body, .referenceDate, SubjectBreakdownCard, .body, TrendCard (+7 more)

### Community 2 - "Results"
Cohesion: 0.13
Nodes (13): ADR-0001 — AI tooling, skills and project memory, Consequences, Context, Decision, Addendum — Ponytail, RTK and LLM Council (2026-10-21), Apple skills plugin (indie-apple-stack) — 183 targets — CRITICAL: 4, HIGH: 12, LOW: 127, MEDIUM: 40, claude-mem plugin skills — 27 targets — CRITICAL: 2, HIGH: 2, LOW: 22, MEDIUM: 1, Not installed (by choice, not for security reasons) (+5 more)

### Community 3 - "Melde Planner"
Cohesion: 0.22
Nodes (8): Command output, Commands (Windows), graphify, Hard rules, Melde Planner, Project memory (three layers), Read first, Skills

### Community 5 - "DayGrid"
Cohesion: 0.21
Nodes (12): BreakBand, .body, DayGrid, .body, .breaks, .gridLines, Gap, GridMetrics (+4 more)

### Community 6 - "derive.rs"
Cohesion: 0.14
Nodes (22): LocalTime, .MINUTES_PER_DAY, cancellations_and_substitutions_become_changes(), d(), derive_schedule(), DerivedChange, DerivedChangeKind, Cancelled (+14 more)

### Community 7 - "String"
Cohesion: 0.09
Nodes (19): Assignment, Body, Class, Failure, cancelled, denied, expired, network (+11 more)

### Community 9 - "Date"
Cohesion: 0.09
Nodes (38): Date, monday_of(), d(), Group, Completed, Later, NoDate, group_of() (+30 more)

### Community 10 - "Codable"
Cohesion: 0.22
Nodes (20): BellPeriod, ExamDocument, .kind, GradeEntry, Holiday, Lesson, ParticipationEntry, SchoolTask (+12 more)

### Community 11 - "MeldeError"
Cohesion: 0.17
Nodes (20): date(), FfiPriority, High, Low, Normal, FfiTask, FfiTaskKind, Homework (+12 more)

### Community 12 - "melde-statistics/src/lib.rs"
Cohesion: 0.17
Nodes (16): d(), daily_counts(), daily_counts_include_empty_days(), entry(), goal_progress(), goal_progress_caps_fraction(), GoalProgress, ParticipationEntry (+8 more)

### Community 13 - "ValidationError"
Cohesion: 0.19
Nodes (6): ensure_finite(), ensure_range(), ValidationError, Invalid, NotFinite, OutOfRange

### Community 14 - "TaskEditorView"
Cohesion: 0.15
Nodes (3): .tasks, Reminders, .body

### Community 15 - "MeldoUITests"
Cohesion: 0.19
Nodes (5): MeldoUITests, .device, PDFKit, UIKit, XCTest

### Community 16 - "View"
Cohesion: 0.09
Nodes (22): .body, GradeSettingsView, .body, GradesView, .body, AboutView, .body, AppIconPicker (+14 more)

### Community 18 - "properties.rs"
Cohesion: 0.36
Nodes (5): category_strategy(), config_and_assessments(), rounding_strategy(), scale_strategy(), value_for()

### Community 19 - "participation.rs"
Cohesion: 0.25
Nodes (11): entries(), FfiDayCount, FfiGoalProgress, FfiParticipationEntry, FfiSubjectCount, FfiWeekSummary, participation_daily_counts(), participation_goal_progress() (+3 more)

### Community 20 - "Preferences"
Cohesion: 0.13
Nodes (9): Preferences, AppTheme, green, .id, indigo, .localizedName, orange, .tint (+1 more)

### Community 21 - "View"
Cohesion: 0.14
Nodes (20): CircularView, .body, LessonHeader, .body, LessonInfo, MediumView, .body, MeldenButton (+12 more)

### Community 22 - "MeldeError"
Cohesion: 0.09
Nodes (37): MeldeError, InvalidInput, UntisMalformed, UntisServer, derives_schedule_across_the_boundary(), FfiTimeUnit, FfiUntisAbsence, FfiUntisAuth (+29 more)

### Community 23 - "LogParticipationIntent"
Cohesion: 0.15
Nodes (6): LessonActivityView, .body, .body, MeldenControl, .body, LogParticipationIntent

### Community 25 - "grades.rs"
Cohesion: 0.07
Nodes (37): assessments(), FfiAssessment, FfiCategory, Oral, Written, FfiForecast, FfiForecastOutcome, AlreadySecured (+29 more)

### Community 27 - "ExamListView"
Cohesion: 0.06
Nodes (25): ExamFiles, DocumentCategoryText, ExamDetailView, ExamEditorView, .body, .isNew, ExamListView, .actionButtons (+17 more)

### Community 28 - "CustomizableCardGrid"
Cohesion: 0.08
Nodes (16): CardDropDelegate, CardGridLayout, CardSpanKey, CustomizableCardGrid, .body, .columns, .hiddenCards, .shown (+8 more)

### Community 30 - "GradeEditorView"
Cohesion: 0.20
Nodes (6): GradeEditorView, .body, .usesPoints, .value, SubjectGradesView, .body

### Community 31 - "DashboardCard"
Cohesion: 0.08
Nodes (24): .groups, CardSlot, .defaultHome, .defaultStats, DashboardCard, absences, exams, grades (+16 more)

### Community 32 - "AppModel"
Cohesion: 0.08
Nodes (11): AppModel, .ffiTimetable, .isSharedWithWidgets, .participationGraceMinutes, .preferences, .exams, .gradeConfig, .overallGradeAverage (+3 more)

### Community 33 - "LocalStore"
Cohesion: 0.18
Nodes (4): LoadError, newerSchema, unreadable, LocalStore

### Community 34 - "AppTab"
Cohesion: 0.12
Nodes (17): AppTab, about, absences, calendar, exams, grades, holidays, home (+9 more)

### Community 35 - "FfiTaskGroup"
Cohesion: 0.25
Nodes (8): FfiTaskGroup, Completed, Later, NoDate, Overdue, ThisWeek, Today, Tomorrow

### Community 36 - "StatusView"
Cohesion: 0.26
Nodes (4): StatusView, .body, .groupName, .notificationText

### Community 37 - "melde-scheduling/src/lib.rs"
Cohesion: 0.11
Nodes (32): LocalDateTime, ab_weeks_alternate(), cancelled_and_substituted_lessons(), ChangeKind, Cancelled, Substituted, current_and_next_lesson(), d() (+24 more)

### Community 38 - "AppIconChoice"
Cohesion: 0.10
Nodes (19): AppIconChoice, .assetName, .id, night, orange, standard, GradeScaleChoice, .id (+11 more)

### Community 39 - "SwiftUI"
Cohesion: 0.17
Nodes (7): DS, CheckInPromptCard, DashboardView, .body, UnassignedCard, AuthenticationServices, SwiftUI

### Community 40 - "CodingKeys"
Cohesion: 0.08
Nodes (23): CodingKeys, adultStudent, appearance, appIcon, askAfterLesson, checkInPromptDismissed, className, dashboardCards (+15 more)

### Community 41 - "TimetableView"
Cohesion: 0.14
Nodes (13): GoToDateSheet, .body, HomeworkPrefill, TimetableBlockSheet, TimetableDaysPage, TimetableView, .body, .detail (+5 more)

### Community 42 - "timetable.rs"
Cohesion: 0.14
Nodes (23): current_lesson_round_trip(), FfiChangeKind, Cancelled, Substituted, FfiHoliday, FfiLesson, FfiOccurrence, FfiTimetable (+15 more)

### Community 43 - "UntisLoginWatcher"
Cohesion: 0.25
Nodes (4): UntisLoginWatcher, UntisWebLoginView, .body, WebKit

### Community 44 - "MeldePlannerApp.swift"
Cohesion: 0.29
Nodes (4): BackgroundRefresh, MeldePlannerApp, .body, BackgroundTasks

### Community 45 - "ADR-0003: Offline-first persistence and sync model"
Cohesion: 0.50
Nodes (3): ADR-0003: Offline-first persistence and sync model, Consequences, Decision

### Community 46 - "average.rs"
Cohesion: 0.21
Nodes (18): a(), Assessment, Category, category_average(), Oral, Written, empty_subject_has_no_average(), fifty_fifty_written_oral() (+10 more)

### Community 47 - "ADR-0007: Optional WebUntis import"
Cohesion: 0.33
Nodes (5): ADR-0007: Optional WebUntis import, Consequences, Context, Decision, Update 2026-10-21: school login (SSO) and search

### Community 48 - "Weekday"
Cohesion: 0.06
Nodes (22): Weekday, .ALL, Friday, Monday, Saturday, Sunday, Thursday, Tuesday (+14 more)

### Community 49 - "rpc.rs"
Cohesion: 0.10
Nodes (36): UntisError, .BAD_CREDENTIALS, Malformed, .NOT_AUTHENTICATED, Server, Auth, authenticate_request(), CLIENT (+28 more)

### Community 51 - "TaskEditorView"
Cohesion: 0.11
Nodes (7): .subjects, SubjectEditorView, .body, TaskEditorView, .defaultReminder, .dueBinding, .reminderBinding

### Community 52 - "Foundation"
Cohesion: 0.13
Nodes (7): Foundation, MeldeCore, MeldePlanner, Observation, Security, Synchronization, Testing

### Community 55 - ".preview"
Cohesion: 0.17
Nodes (6): Calendar, .body, ContentState, LessonActivityAttributes, MeldeEngine, AppData

### Community 56 - "MoreWidgets.swift"
Cohesion: 0.18
Nodes (10): DataEntry, DataProvider, HolidayCountdownView, .body, HomeworkWidgetView, .body, NotConnected, .body (+2 more)

### Community 57 - "UntisClient"
Cohesion: 0.07
Nodes (11): UntisImportSummary, Keychain, Failure, network, noAccess, noLessons, server, sessionExpired (+3 more)

### Community 58 - "rest.rs"
Cohesion: 0.13
Nodes (17): Absence, data(), day(), Exam, Homework, NewsMessage, parse_absences(), parse_exams() (+9 more)

### Community 59 - "TimetableBlock"
Cohesion: 0.20
Nodes (7): AppModel, .bellSchedule, .hasSaturdayLessons, .untisVisibleUntil, TimetableBlock, .roomChanged, .teacherChanged

### Community 61 - "CardSize"
Cohesion: 0.13
Nodes (27): AbsencesCard, DayBlocks, .id, GettingStartedCard, .body, SchoolNewsCard, StreakCard, TodayCard (+19 more)

### Community 63 - "L"
Cohesion: 0.12
Nodes (15): .title, .body, .nextLessonText, .body, .body, .options, .accessibilityText, ExcuseNote (+7 more)

### Community 68 - "forecast.rs"
Cohesion: 0.25
Nodes (16): detects_already_secured_target(), detects_unreachable_target(), Forecast, forecast(), ForecastOutcome, AlreadySecured, Reachable, Unreachable (+8 more)

### Community 79 - "TimetableView.swift"
Cohesion: 0.18
Nodes (11): BlockDetail, compact, full, medium, Color, HolidayColumn, .body, LimitNotice (+3 more)

### Community 81 - ".body"
Cohesion: 0.23
Nodes (9): LessonLiveActivity, .body, MeldoTodayWidget, .body, HolidayCountdownWidget, .body, HomeworkWidget, .body (+1 more)

### Community 85 - ".seed"
Cohesion: 0.21
Nodes (4): .currentDate, SampleData, UITestLaunch, .now

### Community 87 - "AppearanceChoice"
Cohesion: 0.18
Nodes (8): AppearanceChoice, .colorScheme, dark, .id, light, .localizedName, system, Color

### Community 88 - ".dayDetails"
Cohesion: 0.09
Nodes (17): .body, CardHeaderLabelStyle, CalendarLegend, .body, .items, CalendarView, .date, .dayDetails (+9 more)

### Community 89 - "check_strings.py"
Cohesion: 0.31
Nodes (3): main(), source_keys(), to_key()

### Community 91 - "FfiDate"
Cohesion: 0.16
Nodes (6): FfiDate, FfiDateTime, FfiWeekday, .mondayIndex, BridgeTests, Rules that keep the architecture honest

### Community 93 - "MeldenButton"
Cohesion: 0.15
Nodes (9): MeldenButton, .body, .label, .lessonCount, SubjectPickerSheet, .body, .suggestions, Suggestion (+1 more)

### Community 94 - ".applyUntis"
Cohesion: 0.23
Nodes (3): SubjectSymbols, UntisImportTests, UntisLink

### Community 95 - "UntisLoginView"
Cohesion: 0.14
Nodes (15): ExamError, storage, unreadablePDF, UntisConnectView, .body, UntisLoginView, .body, UntisMessages (+7 more)

### Community 99 - "AppGroup"
Cohesion: 0.39
Nodes (3): AppGroup, .allCandidates, .containerURL

### Community 100 - "GradeScale"
Cohesion: 0.21
Nodes (7): GradeScale, Points, Traditional, RoundingRule, HalfTowardBetter, HalfTowardWorse, traditional_value()

### Community 101 - "FfiRecurrence"
Cohesion: 0.33
Nodes (6): FfiRecurrence, Biweekly, Daily, Never, Weekdays, Weekly

### Community 104 - "AbsenceRow"
Cohesion: 0.21
Nodes (7): .body, AbsenceRow, .body, .dates, .row, AbsencesView, .body

### Community 105 - "ADR-0008: Microsoft Teams assignments via Microsoft Graph"
Cohesion: 0.22
Nodes (7): ADR-0008: Microsoft Teams assignments via Microsoft Graph, Consequences, Context, Decision, Microsoft Teams: Azure app registration, School approval, Steps (about 10 minutes)

### Community 107 - "ADR-0006: Sync with Supabase, not iCloud"
Cohesion: 0.33
Nodes (5): ADR-0006: Sync with Supabase, not iCloud, Consequences, Context, Decision, Update 2026-10-21: superseded

### Community 108 - "DocumentScanner"
Cohesion: 0.17
Nodes (3): Coordinator, DocumentScanner, .isSupported

### Community 109 - "PreviewResult"
Cohesion: 0.25
Nodes (7): LessonActivity, .isAvailable, PreviewResult, disabledInSettings, failed, noLessons, shown

### Community 110 - "AppLanguage"
Cohesion: 0.33
Nodes (6): AppLanguage, english, german, .id, .nativeName, turkish

### Community 111 - "TaskBoard"
Cohesion: 0.13
Nodes (16): Card, ThemedBackground, .body, .body, .body, .body, HomeworkCard, .body (+8 more)

### Community 112 - "TaskPriority"
Cohesion: 0.40
Nodes (5): TaskPriority, high, .id, low, normal

### Community 113 - "Melde Planner — Product & Engineering Spec"
Cohesion: 0.14
Nodes (14): 10. Begin development with, 1. Role, 2. Development environment & technical requirements, 3. Design direction — Apple-level premium (highest priority), 4. Features, 5. Additional product requirements, 6. Project structure (suggested; adjust to best practice), 7. Development phases (+6 more)

### Community 114 - ".mutate"
Cohesion: 0.13
Nodes (3): .body, .body, .body

### Community 115 - "TaskRecurrence"
Cohesion: 0.29
Nodes (7): TaskRecurrence, biweekly, daily, .id, never, weekdays, weekly

### Community 116 - "WidgetKit"
Cohesion: 0.17
Nodes (5): ActivityKit, AppIntents, MeldeWidgetsBundle, UserNotifications, WidgetKit

### Community 117 - "SubjectColor"
Cohesion: 0.12
Nodes (16): SubjectColor, blue, brown, .color, cyan, gray, green, .id (+8 more)

### Community 118 - ".perform"
Cohesion: 0.14
Nodes (4): Localization, .bundle, .locale, State

### Community 119 - "String"
Cohesion: 0.12
Nodes (10): Mood, cheer, sleep, wave, Action, once, skip, twice (+2 more)

### Community 120 - "Architecture Overview"
Cohesion: 0.40
Nodes (5): Architecture Overview, PWA path (Phase 19, later), Repository layout, System, Technology decisions

### Community 122 - "Surfaces.swift"
Cohesion: 0.40
Nodes (3): DeepLink, Notification.Name, Surfaces

### Community 123 - "BlockStyle"
Cohesion: 0.25
Nodes (5): BlockStyle, DayHeader, .body, TimetableBlockView, .body

### Community 125 - "ValidationError"
Cohesion: 0.18
Nodes (8): EPSILON, kmk_point_table_round_trips(), points_to_traditional(), Tendency, Minus, None, Plus, traditional_to_points()

### Community 126 - "Kind"
Cohesion: 0.67
Nodes (3): Kind, cancelled, substituted

### Community 130 - "StatsEntry"
Cohesion: 0.17
Nodes (7): MeldoStatsWidget, .body, StatsEntry, StatsWidgetView, .body, .chart, .summary

### Community 136 - "TimetableMode"
Cohesion: 0.22
Nodes (9): TimetableMode, day, .dayCount, .id, .symbol, threeDays, .title, twoDays (+1 more)

### Community 137 - "ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package"
Cohesion: 0.33
Nodes (5): ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package, Alternatives considered, Consequences, Context, Decision

### Community 140 - "Windows 11 → macOS build workflow"
Cohesion: 0.17
Nodes (10): ADR-0004: Windows-first development with macOS CI, Consequences, Decision, Daily loop, Interactive macOS when needed, Local toolchain (installed 2026-10-21), One-time Apple setup (needs your accounts; Claude cannot do these), Status (+2 more)

### Community 143 - "PDFKitView"
Cohesion: 0.33
Nodes (3): PDFKitView, .body, VisionKit

### Community 144 - ".entries"
Cohesion: 0.29
Nodes (4): .ffiEntries, RecordOutcome, needsSubject, recorded

### Community 145 - "Kind"
Cohesion: 0.33
Nodes (6): Kind, cancelled, exam, regular, roomChange, substitution

### Community 146 - "FfiWeekParity"
Cohesion: 0.50
Nodes (4): FfiWeekParity, A, B, Every

### Community 148 - "ADR-0005: The app is called Meldo"
Cohesion: 0.50
Nodes (3): ADR-0005: The app is called Meldo, Consequences, Decision

### Community 149 - "Melde Planner"
Cohesion: 0.67
Nodes (3): Melde Planner, Quick start (Windows 11), Status

### Community 151 - "Mascot"
Cohesion: 0.14
Nodes (11): Mascot, .body, BlockRow, .details, .body, .body, .body, HolidayBanner (+3 more)

### Community 188 - "Home.md"
Cohesion: 0.24
Nodes (5): Open Questions, Decision Log, Feature Index, Glossary, Rules that prevent misunderstandings

### Community 232 - "{{date}} — {{title}}"
Cohesion: 0.25
Nodes (6): Session Log, {{date}} — {{title}}, Done (not verified), Done (verified), Goal, Next

### Community 241 - "{{title}}"
Cohesion: 0.29
Nodes (7): Blocked on, Files, Implemented, Not yet, Scope, Tests, {{title}}

### Community 258 - "ADR-NNNN — {{title}}"
Cohesion: 0.33
Nodes (5): ADR-NNNN — {{title}}, Alternatives considered, Consequences, Context, Decision

### Community 283 - "melde-core"
Cohesion: 0.62
Nodes (7): melde-core, melde-ffi, melde-grades, melde-scheduling, melde-statistics, melde-tasks, melde-untis

### Community 312 - "Melde Planner — Project Brain"
Cohesion: 0.50
Nodes (4): Conventions, Generated (do not hand-edit), Melde Planner — Project Brain, Start here

## Knowledge Gaps
- **338 isolated node(s):** `regular`, `substitution`, `cancelled`, `exam`, `roomChange` (+333 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 763 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **75 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `L()` connect `L` to `Card`, `StatisticsView.swift`, `StatsEntry`, `DayGrid`, `TimetableMode`, `PDFKitView`, `View`, `Preferences`, `View`, `Mascot`, `LogParticipationIntent`, `ExamListView`, `CustomizableCardGrid`, `GradeEditorView`, `AppModel`, `LocalStore`, `StatusView`, `SwiftUI`, `TimetableView`, `UntisLoginWatcher`, `Foundation`, `.preview`, `MoreWidgets.swift`, `TimetableBlock`, `CardSize`, `AppDelegate`, `TimetableView.swift`, `AppearanceChoice`, `.dayDetails`, `MeldenButton`, `UntisLoginView`, `AbsenceRow`, `TaskBoard`, `.mutate`, `.perform`?**
  _High betweenness centrality (0.209) - this node is a cross-community bridge._
- **Are the 9 inferred relationships involving `AppModel` (e.g. with `.defaultReminder` and `.dueBinding`) actually correct?**
  _`AppModel` has 9 INFERRED edges - model-reasoned connections that need verification._
- **What connects `regular`, `substitution`, `cancelled` to the rest of the system?**
  _338 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Card` be split into smaller, more focused modules?**
  _Cohesion score 0.10114942528735632 - nodes in this community are weakly interconnected._
- **Why does `AppModel` connect `AppModel` to `.widgetWriteIsNotLostWhenAppSaves`, `.recordParticipation`, `String`, `Codable`, `TaskEditorView`, `MeldoUITests`, `.entries`, `Date`, `Preferences`, `Date`, `ExamListView`, `DashboardCard`, `LocalStore`, `AppIconChoice`, `TaskEditorView`, `Foundation`, `.preview`, `UntisClient`, `LessonEditorView`, `.seed`, `AppearanceChoice`, `.applyUntis`, `UntisLoginView`, `.mutate`, `.perform`, `String`, `Architecture Overview`?**
  _High betweenness centrality (0.167) - this node is a cross-community bridge._
- **Are the 143 inferred relationships involving `L()` (e.g. with `.init()` and `.mutate()`) actually correct?**
  _`L()` has 143 INFERRED edges - model-reasoned connections that need verification._
- **Should `Results` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._