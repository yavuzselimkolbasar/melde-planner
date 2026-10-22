# Graph Report - Mledeapp  (2026-10-23)

## Corpus Check
- 232 files · ~162,637 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 73 file(s) not represented in the graph (top: .xml 59, (none) 7, .properties 2)

## Summary
- 4407 nodes · 11605 edges · 208 communities (141 shown, 67 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 638 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8bcaf437`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- StatsEntry
- StatisticsView.swift
- Results
- Melde Planner
- .recordParticipation
- L
- derive.rs
- sfSymbol
- Date
- Codable
- MeldeError
- melde-statistics/src/lib.rs
- Reminders
- MeldoUITests
- UntisConnectScreen.kt
- .toggleDone
- properties.rs
- participation.rs
- Preferences
- MeldoTodayWidget.swift
- MeldeError
- String
- TimetableStyle.kt
- grades.rs
- TaskListScreen.kt
- ExamListView
- CustomizableCardGrid
- MeldeCore
- DashboardCard
- LocalStore
- AppTab
- TodayEntry
- Frosted.kt
- melde-scheduling/src/lib.rs
- CaseIterable
- L
- CodingKeys
- TimetableView
- timetable.rs
- UntisLoginWatcher
- SubjectIcon
- .addExam
- average.rs
- ADR-0007: Optional WebUntis import
- Weekday
- rpc.rs
- DayGrid
- RootScreen.kt
- Foundation
- FormParts.kt
- CalendarScreen.kt
- .preview
- MoreWidgets.swift
- UntisClient
- rest.rs
- TimetableBlock
- State
- View
- scale.rs
- .body
- Charts.kt
- AppModelUntis.kt
- AppModel
- AbsencesScreen
- forecast.rs
- AppModel.kt
- ExcuseNoteScreen.kt
- AppModelExams.kt
- SubjectColor
- WidgetKit.kt
- AppModelSchool.kt
- MeldoCalendar
- MeldeEngine
- LessonCheckIns.kt
- AppData
- AppModelTasks.kt
- TeamsClient
- AppTab
- .preview
- UntisMergeTest.kt
- BackgroundRefresh.kt
- AppearanceChoice
- WidgetStyle
- L
- .dayDetails
- Localization.kt
- AppModelWeek.kt
- PrintDocumentAdapter
- .content
- MeldenButton
- SubjectIcon
- UntisLoginView
- .body
- StatusScreen
- .key
- AppGroup
- GradeScale
- UntisClient.kt
- LessonEditorView
- TeamsClient.kt
- Decision Log.md
- TimetableMode
- ADR-0006: Sync with Supabase, not iCloud
- .onAction
- LogParticipationIntent
- FfiDate
- TaskEditorView
- WidgetKit
- Melde Planner — Product & Engineering Spec
- Kind
- TaskRecurrence
- SubjectColor
- Recurrence
- String
- MoreWidgets.kt
- SymbolLabel
- FfiWeekday
- ValidationError
- MeldeEngine.kt
- UntisLoginWatcher
- MainActivity.kt
- MeldoTheme.kt
- .of
- WeekParity
- .importTeams
- .build
- .ffiLesson
- TeamsAuthActivity.kt
- ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package
- TaskAndExamTests
- melde-ffi/src/lib.rs
- Windows 11 → macOS build workflow
- LocalStore
- Models.kt
- .onCreate
- DocumentScanner
- Reminders.kt
- setup-mac.sh
- ADR-0005: The app is called Meldo
- .gradeNeeded
- AppModel
- AppModelTeams.kt
- String
- TeamsClient.swift
- .onReceive
- LogParticipation.kt
- AppModel+Holidays.swift
- FfiTaskGroup
- .importFromUntis
- Composable
- Architecture Overview
- .recordParticipation
- ADR-0009: Native Android port in Kotlin + Jetpack Compose (Material 3)
- Failure
- TimetableScreen
- ExamEditorMode
- TimetableMode
- FfiGradeScale
- Microsoft Teams: Azure app registration
- SharedStoreTests
- AppModel+Exams.swift
- .mergesIntoExistingData
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
1. `L()` - 197 edges
2. `L()` - 152 edges
3. `AppModel` - 139 edges
4. `sfSymbol()` - 106 edges
5. `MeldoCalendar` - 66 edges
6. `AppModel` - 65 edges
7. `MeldoScreen()` - 55 edges
8. `MeldeError` - 51 edges
9. `rememberReduceMotion()` - 37 edges
10. `AppData` - 35 edges

## Surprising Connections (you probably didn't know these)
- `Rules that keep the architecture honest` --references--> `FfiDate`  [INFERRED]
  vault/03-Architecture/Architecture Overview.md → apps/ios/MeldeCore/Sources/MeldeCore/CalendarBridge.swift
- `Rules that keep the architecture honest` --references--> `FfiDateTime`  [INFERRED]
  vault/03-Architecture/Architecture Overview.md → apps/ios/MeldeCore/Sources/MeldeCore/CalendarBridge.swift
- `Rules (from the project CLAUDE.md, they apply here too)` --references--> `L()`  [INFERRED]
  apps/android/docs/PORTING.md → apps/android/app/src/main/java/app/meldeplanner/android/core/Localization.kt
- `Glossary` --references--> `State`  [INFERRED]
  vault/05-Glossary/Glossary.md → apps/ios/Shared/Localization.swift
- `Architecture (already in place — read these files first)` --references--> `newID()`  [INFERRED]
  apps/android/docs/PORTING.md → apps/android/app/src/main/java/app/meldeplanner/android/data/Models.kt

## Import Cycles
- 2-file cycle: `crates/melde-untis/src/lib.rs -> crates/melde-untis/src/rest.rs -> crates/melde-untis/src/lib.rs`
- 3-file cycle: `crates/melde-untis/src/lib.rs -> crates/melde-untis/src/rest.rs -> crates/melde-untis/src/rpc.rs -> crates/melde-untis/src/lib.rs`

## Communities (208 total, 67 thin omitted)

### Community 0 - "StatsEntry"
Cohesion: 0.14
Nodes (8): .body, StatsEntry, StatsProvider, StatsWidgetView, .body, .chart, .summary, Charts

### Community 1 - "StatisticsView.swift"
Cohesion: 0.16
Nodes (14): DayValue, .id, StatisticsView, .body, .referenceDate, SubjectBreakdownCard, .body, TrendCard (+6 more)

### Community 2 - "Results"
Cohesion: 0.13
Nodes (13): ADR-0001 — AI tooling, skills and project memory, Consequences, Context, Decision, Addendum — Ponytail, RTK and LLM Council (2026-10-21), Apple skills plugin (indie-apple-stack) — 183 targets — CRITICAL: 4, HIGH: 12, LOW: 127, MEDIUM: 40, claude-mem plugin skills — 27 targets — CRITICAL: 2, HIGH: 2, LOW: 22, MEDIUM: 1, Not installed (by choice, not for security reasons) (+5 more)

### Community 3 - "Melde Planner"
Cohesion: 0.22
Nodes (8): Command output, Commands (Windows), graphify, Hard rules, Melde Planner, Project memory (three layers), Read first, Skills

### Community 5 - "L"
Cohesion: 0.06
Nodes (45): gradeText(), holiday(), HolidayText, upcomingHolidays(), homeworkStreak(), tasks(), CustomizeButton(), Card() (+37 more)

### Community 6 - "derive.rs"
Cohesion: 0.14
Nodes (22): LocalTime, .MINUTES_PER_DAY, cancellations_and_substitutions_become_changes(), d(), derive_schedule(), DerivedChange, DerivedChangeKind, Cancelled (+14 more)

### Community 7 - "sfSymbol"
Cohesion: 0.06
Nodes (36): MeldoMenu(), meldoMenuGroupColor(), meldoMenuItemColors(), MeldoSegmented(), MenuAnchor(), sfSymbol(), ExamDetailScreen(), OpenPdf (+28 more)

### Community 9 - "Date"
Cohesion: 0.10
Nodes (32): parityTitle(), Date, d(), Group, Completed, Later, NoDate, group_of() (+24 more)

### Community 10 - "Codable"
Cohesion: 0.19
Nodes (26): ContentState, AppData, BellPeriod, ExamDocument, .kind, GradeEntry, Holiday, Kind (+18 more)

### Community 11 - "MeldeError"
Cohesion: 0.12
Nodes (26): date(), FfiPriority, High, Low, Normal, FfiRecurrence, Biweekly, Daily (+18 more)

### Community 12 - "melde-statistics/src/lib.rs"
Cohesion: 0.17
Nodes (16): d(), daily_counts(), daily_counts_include_empty_days(), entry(), goal_progress(), goal_progress_caps_fraction(), GoalProgress, ParticipationEntry (+8 more)

### Community 16 - "UntisConnectScreen.kt"
Cohesion: 0.12
Nodes (23): FormFooter(), FormHeader(), formItems(), formRowShape(), meldoAnimateItem(), TeamsConnectScreen(), ConnectActionRow(), ConnectIconLabel() (+15 more)

### Community 17 - ".toggleDone"
Cohesion: 0.11
Nodes (4): .subjects, .tasks, TaskSection, .id

### Community 18 - "properties.rs"
Cohesion: 0.28
Nodes (5): category_strategy(), config_and_assessments(), rounding_strategy(), scale_strategy(), value_for()

### Community 19 - "participation.rs"
Cohesion: 0.25
Nodes (11): entries(), FfiDayCount, FfiGoalProgress, FfiParticipationEntry, FfiSubjectCount, FfiWeekSummary, participation_daily_counts(), participation_goal_progress() (+3 more)

### Community 20 - "Preferences"
Cohesion: 0.09
Nodes (13): AppIconChoice, .assetName, .id, night, orange, standard, AppLanguage, english (+5 more)

### Community 21 - "MeldoTodayWidget.swift"
Cohesion: 0.16
Nodes (18): CircularView, .body, LessonHeader, .body, MediumView, .body, MeldenButton, .body (+10 more)

### Community 22 - "MeldeError"
Cohesion: 0.08
Nodes (40): MeldeError, InvalidInput, UntisMalformed, UntisServer, derives_schedule_across_the_boundary(), ffi_exam(), FfiTimeUnit, FfiUntisAbsence (+32 more)

### Community 23 - "String"
Cohesion: 0.25
Nodes (3): Assignment, TeamsClient, Tokens

### Community 24 - "TimetableStyle.kt"
Cohesion: 0.14
Nodes (5): blockAccessibilityText(), LegendItem(), BlockStyle, FitText(), UntisColors

### Community 25 - "grades.rs"
Cohesion: 0.08
Nodes (33): assessments(), FfiAssessment, FfiCategory, Oral, Written, FfiForecast, FfiForecastOutcome, AlreadySecured (+25 more)

### Community 26 - "TaskListScreen.kt"
Cohesion: 0.06
Nodes (5): Localization, DS, Segments, color(), StateColors

### Community 27 - "ExamListView"
Cohesion: 0.09
Nodes (20): DocumentCategoryText, ExamDetailView, .body, ExamEditorView, .body, .isNew, ExamListView, .actionButtons (+12 more)

### Community 28 - "CustomizableCardGrid"
Cohesion: 0.08
Nodes (15): CardDropDelegate, CardGridLayout, CardSpanKey, CustomizableCardGrid, .body, .columns, .shown, CustomizeButton (+7 more)

### Community 30 - "MeldeCore"
Cohesion: 0.13
Nodes (11): .body, GradeEditorView, .body, .usesPoints, .value, GradeSettingsView, .body, GradesView (+3 more)

### Community 31 - "DashboardCard"
Cohesion: 0.08
Nodes (27): CardSize, .id, large, medium, small, CardSlot, .defaultHome, .defaultStats (+19 more)

### Community 34 - "AppTab"
Cohesion: 0.08
Nodes (20): AppTab, about, absences, calendar, exams, grades, holidays, home (+12 more)

### Community 35 - "TodayEntry"
Cohesion: 0.20
Nodes (3): LessonInfo, TodayEntry, TodayProvider

### Community 36 - "Frosted.kt"
Cohesion: 0.15
Nodes (8): applyBlurBehind(), frosted(), frostedScrim(), FrostedWindow(), MeldoAlertDialog(), MeldoDatePickerDialog(), MeldoSheet(), rememberWindowBlurEnabled()

### Community 37 - "melde-scheduling/src/lib.rs"
Cohesion: 0.11
Nodes (33): LocalDateTime, ab_weeks_alternate(), cancelled_and_substituted_lessons(), ChangeKind, Cancelled, Substituted, current_and_next_lesson(), d() (+25 more)

### Community 38 - "CaseIterable"
Cohesion: 0.10
Nodes (19): DocumentCategory, document, exam, .folderName, .id, worksheet, GradeScaleChoice, .id (+11 more)

### Community 39 - "L"
Cohesion: 0.05
Nodes (53): L(), forecastText(), GradeChip(), GradeEditorSheet(), GradeRow(), GradeSettingsSheet(), GradesScreen(), Stat() (+45 more)

### Community 40 - "CodingKeys"
Cohesion: 0.08
Nodes (23): CodingKeys, adultStudent, appearance, appIcon, askAfterLesson, checkInPromptDismissed, className, dashboardCards (+15 more)

### Community 41 - "TimetableView"
Cohesion: 0.06
Nodes (42): BlockDetail, compact, full, medium, BlockStyle, BreakBand, Color, DayGrid (+34 more)

### Community 42 - "timetable.rs"
Cohesion: 0.12
Nodes (27): current_lesson_round_trip(), FfiChangeKind, Cancelled, Substituted, FfiHoliday, FfiLesson, FfiOccurrence, FfiTimetable (+19 more)

### Community 43 - "UntisLoginWatcher"
Cohesion: 0.14
Nodes (7): .body, Coordinator, UntisLoginWatcher, UntisWebLoginView, .body, UntisWebView, WebKit

### Community 44 - "SubjectIcon"
Cohesion: 0.10
Nodes (16): Badge(), CardHeader(), HSpacer(), LessonRow(), ProgressRing(), SectionHeader(), SubjectIcon(), EvenGrid() (+8 more)

### Community 45 - ".addExam"
Cohesion: 0.15
Nodes (5): .exams, ExamFiles, ADR-0003: Offline-first persistence and sync model, Consequences, Decision

### Community 46 - "average.rs"
Cohesion: 0.21
Nodes (18): a(), Assessment, Category, category_average(), Oral, Written, empty_subject_has_no_average(), fifty_fifty_written_oral() (+10 more)

### Community 47 - "ADR-0007: Optional WebUntis import"
Cohesion: 0.40
Nodes (5): ADR-0007: Optional WebUntis import, Consequences, Context, Decision, Update 2026-10-21: school login (SSO) and search

### Community 48 - "Weekday"
Cohesion: 0.09
Nodes (18): Weekday, .ALL, Friday, Monday, Saturday, Sunday, Thursday, Tuesday (+10 more)

### Community 49 - "rpc.rs"
Cohesion: 0.10
Nodes (37): UntisError, .BAD_CREDENTIALS, Malformed, .NOT_AUTHENTICATED, Server, parse_exams(), Auth, authenticate_request() (+29 more)

### Community 50 - "DayGrid"
Cohesion: 0.15
Nodes (15): BlockDetail, compact, full, medium, BlockLabel(), DayGrid(), EmptyStateCard(), GridMetrics (+7 more)

### Community 51 - "RootScreen.kt"
Cohesion: 0.04
Nodes (13): FloatingTabBar(), TabBarScrollState, TabButton(), TabItem, AmbientGlow(), Navigator, rememberStackMotion(), unplaced() (+5 more)

### Community 52 - "Foundation"
Cohesion: 0.14
Nodes (7): ActivityKit, Foundation, MeldeCore, MeldePlanner, Observation, Testing, UserNotifications

### Community 53 - "FormParts.kt"
Cohesion: 0.07
Nodes (12): ExamEditorScreen(), ProblemLabel(), FormDivider(), FormSection(), FormValue(), groupShape(), PickerRow(), SwitchRow() (+4 more)

### Community 54 - "CalendarScreen.kt"
Cohesion: 0.04
Nodes (20): CardCell(), CustomizableCardGrid(), EditChrome(), HiddenCardsTray(), rememberHaptic(), rememberReduceMotion(), ResizeHandle(), span() (+12 more)

### Community 56 - "MoreWidgets.swift"
Cohesion: 0.14
Nodes (16): DataEntry, DataProvider, HolidayCountdownView, .body, HolidayCountdownWidget, .body, HomeworkWidget, .body (+8 more)

### Community 57 - "UntisClient"
Cohesion: 0.10
Nodes (9): Failure, network, noAccess, noLessons, server, sessionExpired, tooManyResults, wrongCredentials (+1 more)

### Community 58 - "rest.rs"
Cohesion: 0.10
Nodes (20): Absence, data(), day(), Exam, Homework, NewsMessage, parse_absences(), parse_duration() (+12 more)

### Community 59 - "TimetableBlock"
Cohesion: 0.11
Nodes (9): Kind, cancelled, exam, regular, roomChange, substitution, TimetableBlock, .roomChanged (+1 more)

### Community 60 - "State"
Cohesion: 0.12
Nodes (11): SubjectEditorView, .body, SubjectListView, .body, Localization, .bundle, .locale, State (+3 more)

### Community 61 - "View"
Cohesion: 0.06
Nodes (44): Card, .body, CardHeaderLabelStyle, Mascot, .body, CheckInPromptCard, .body, AbsencesCard (+36 more)

### Community 62 - "scale.rs"
Cohesion: 0.18
Nodes (8): EPSILON, kmk_point_table_round_trips(), points_to_traditional(), Tendency, Minus, None, Plus, traditional_to_points()

### Community 63 - ".body"
Cohesion: 0.10
Nodes (18): .body, HolidayListView, AboutView, .body, MoreView, .body, SettingsView, StatusView (+10 more)

### Community 64 - "Charts.kt"
Cohesion: 0.08
Nodes (8): SymbolBitmaps, BarChart(), LineChart(), monotonePath(), niceTicks(), Plot, rememberAnimatedValues(), yAxis()

### Community 65 - "AppModelUntis.kt"
Cohesion: 0.10
Nodes (23): BellPeriod, newID(), UntisPeriodRecord, UntisTimetable, applyUntis(), applyUntisHolidays(), connectUntis(), connectUntisWithBrowser() (+15 more)

### Community 67 - "AbsencesScreen"
Cohesion: 0.07
Nodes (16): MeldoMenuItem, CalendarLegend(), CalendarScreen(), DayCell(), DayDetails(), Dot(), MeldungGroup, MonthGrid() (+8 more)

### Community 68 - "forecast.rs"
Cohesion: 0.25
Nodes (16): detects_already_secured_target(), detects_unreachable_target(), Forecast, forecast(), ForecastOutcome, AlreadySecured, Reachable, Unreachable (+8 more)

### Community 69 - "AppModel.kt"
Cohesion: 0.05
Nodes (32): AppIconChoice, night, orange, standard, AppLanguage, english, german, turkish (+24 more)

### Community 70 - "ExcuseNoteScreen.kt"
Cohesion: 0.05
Nodes (5): setExcuseDetails(), share(), extend(), Field(), renderFirstPage()

### Community 71 - "AppModelExams.kt"
Cohesion: 0.07
Nodes (18): addExam(), deleteExam(), exam(), ExamException, ExamFiles, file(), organizeDocuments(), Reason (+10 more)

### Community 72 - "SubjectColor"
Cohesion: 0.07
Nodes (22): AppearanceChoice, dark, light, system, AppTheme, green, indigo, orange (+14 more)

### Community 73 - "WidgetKit.kt"
Cohesion: 0.11
Nodes (20): HolidayCountdownView(), TodayScheduleView(), Caption(), Chip(), Countdown(), Dot(), HeroBadge(), strike() (+12 more)

### Community 74 - "AppModelSchool.kt"
Cohesion: 0.09
Nodes (13): absences(), assessments(), deleteGrade(), gradeNeeded(), grades(), gradeSummary(), holidayInWeekOf(), saveGrade() (+5 more)

### Community 75 - "MeldoCalendar"
Cohesion: 0.13
Nodes (3): MeldoCalendar, DayHeader(), TimetableDates

### Community 76 - "MeldeEngine"
Cohesion: 0.14
Nodes (3): MeldeEngine, MeldenTileService, weekday()

### Community 79 - "AppModelTasks.kt"
Cohesion: 0.12
Nodes (10): deleteTask(), ffiTask(), nextLessonDay(), shiftReminder(), task(), TaskSection, taskSections(), toggleDone() (+2 more)

### Community 80 - "TeamsClient"
Cohesion: 0.17
Nodes (5): Assignment, Authorization, Denied, TeamsClient, Tokens

### Community 81 - "AppTab"
Cohesion: 0.12
Nodes (17): AppTab, about, absences, calendar, exams, grades, holidays, home (+9 more)

### Community 82 - ".preview"
Cohesion: 0.19
Nodes (8): LessonActivity, .isAvailable, LessonActivityAttributes, PreviewResult, disabledInSettings, failed, noLessons, shown

### Community 85 - "AppearanceChoice"
Cohesion: 0.15
Nodes (9): SampleData, UITestLaunch, AppearanceChoice, .colorScheme, dark, .id, light, .localizedName (+1 more)

### Community 86 - "WidgetStyle"
Cohesion: 0.17
Nodes (17): LessonBadge(), LessonHeader(), LessonInfo, LessonName(), MediumView(), meldoPreferences(), MeldoTodayWidget, MeldoTodayWidgetReceiver (+9 more)

### Community 87 - "L"
Cohesion: 0.08
Nodes (21): .title, .hiddenCards, .body, PDFKitView, AppIconPicker, .body, DashboardCardsView, .body (+13 more)

### Community 88 - ".dayDetails"
Cohesion: 0.10
Nodes (17): CalendarLegend, .body, .items, CalendarView, .body, .date, .dayDetails, .month (+9 more)

### Community 89 - "Localization.kt"
Cohesion: 0.13
Nodes (3): main(), source_keys(), to_key()

### Community 90 - "AppModelWeek.kt"
Cohesion: 0.30
Nodes (9): assignLanes(), block(), chooseCourse(), courseKey(), mergeDoublePeriods(), pickCourses(), TimetableBlock, timetableBlocks() (+1 more)

### Community 91 - "PrintDocumentAdapter"
Cohesion: 0.18
Nodes (3): print(), PrintDocumentAdapter, share()

### Community 92 - ".content"
Cohesion: 0.22
Nodes (6): disabledInSettings, failed, LivePreviewResult, noLessons, shown, Surfaces

### Community 93 - "MeldenButton"
Cohesion: 0.07
Nodes (16): DS, UnassignedCard, .body, HolidayBanner, .body, MeldenButton, .body, .label (+8 more)

### Community 94 - "SubjectIcon"
Cohesion: 0.15
Nodes (11): Badge, .body, LessonRow, .body, ProgressRing, .body, SubjectIcon, .body (+3 more)

### Community 95 - "UntisLoginView"
Cohesion: 0.16
Nodes (10): .body, UntisLoginView, .body, UntisMessages, UntisSchoolSearchView, .body, UntisStatusView, .school (+2 more)

### Community 96 - ".body"
Cohesion: 0.20
Nodes (6): LessonLiveActivity, MeldeWidgetsBundle, .body, MeldoStatsWidget, MeldoTodayWidget, .body

### Community 97 - "StatusScreen"
Cohesion: 0.14
Nodes (5): Notifications, StatusRow(), StatusScreen(), StatusState, syncText()

### Community 99 - "AppGroup"
Cohesion: 0.39
Nodes (3): AppGroup, .allCandidates, .containerURL

### Community 100 - "GradeScale"
Cohesion: 0.23
Nodes (6): GradeScale, Points, Traditional, RoundingRule, HalfTowardBetter, HalfTowardWorse

### Community 101 - "UntisClient.kt"
Cohesion: 0.06
Nodes (12): Network, NoAccess, NoLessons, Probe, Request, Response, Server, SessionExpired (+4 more)

### Community 104 - "TeamsClient.kt"
Cohesion: 0.15
Nodes (8): Body, Class, GraphAssignments, GraphClasses, GraphMe, GraphToken, Item, TeamsConfig

### Community 105 - "Decision Log.md"
Cohesion: 0.25
Nodes (5): ADR-0008: Microsoft Teams assignments via Microsoft Graph, Consequences, Context, Decision, Decision Log

### Community 106 - "TimetableMode"
Cohesion: 0.22
Nodes (9): TimetableMode, day, .dayCount, .id, .symbol, threeDays, .title, twoDays (+1 more)

### Community 107 - "ADR-0006: Sync with Supabase, not iCloud"
Cohesion: 0.40
Nodes (5): ADR-0006: Sync with Supabase, not iCloud, Consequences, Context, Decision, Update 2026-10-21: superseded

### Community 109 - "LogParticipationIntent"
Cohesion: 0.09
Nodes (9): AppIntents, LessonActivityAttributes, .isPreview, LessonActivityView, .body, .body, MeldenControl, .body (+1 more)

### Community 110 - "FfiDate"
Cohesion: 0.24
Nodes (3): FfiDate, FfiDateTime, BridgeTests

### Community 111 - "TaskEditorView"
Cohesion: 0.08
Nodes (17): ThemedBackground, .body, HomeworkCard, .body, .body, TaskEditorView, .body, .defaultReminder (+9 more)

### Community 112 - "WidgetKit"
Cohesion: 0.29
Nodes (4): DeepLink, Notification.Name, Surfaces, WidgetKit

### Community 113 - "Melde Planner — Product & Engineering Spec"
Cohesion: 0.14
Nodes (14): 10. Begin development with, 1. Role, 2. Development environment & technical requirements, 3. Design direction — Apple-level premium (highest priority), 4. Features, 5. Additional product requirements, 6. Project structure (suggested; adjust to best practice), 7. Development phases (+6 more)

### Community 114 - "Kind"
Cohesion: 0.33
Nodes (6): Kind, cancelled, exam, regular, roomChange, substitution

### Community 115 - "TaskRecurrence"
Cohesion: 0.29
Nodes (7): TaskRecurrence, biweekly, daily, .id, never, weekdays, weekly

### Community 117 - "SubjectColor"
Cohesion: 0.08
Nodes (25): AppTheme, green, .id, indigo, .localizedName, orange, .tint, .wash (+17 more)

### Community 118 - "Recurrence"
Cohesion: 0.33
Nodes (6): Recurrence, Biweekly, Daily, None, Weekdays, Weekly

### Community 119 - "String"
Cohesion: 0.11
Nodes (10): Mood, cheer, sleep, wave, Action, once, skip, twice (+2 more)

### Community 120 - "MoreWidgets.kt"
Cohesion: 0.12
Nodes (15): DueChip(), HolidayCountdownWidget, HolidayCountdownWidgetReceiver, HomeworkWidget, HomeworkWidgetReceiver, HomeworkWidgetView(), TodayScheduleWidget, TodayScheduleWidgetReceiver (+7 more)

### Community 121 - "SymbolLabel"
Cohesion: 0.23
Nodes (9): Chart(), StatsEntry, StatsWidgetView(), Streak(), Summary(), Family, large, medium (+1 more)

### Community 125 - "ValidationError"
Cohesion: 0.13
Nodes (7): ensure_finite(), ensure_range(), ValidationError, Invalid, NotFinite, OutOfRange, traditional_value()

### Community 126 - "MeldeEngine.kt"
Cohesion: 0.12
Nodes (4): WeekParity, a, b, every

### Community 127 - "UntisLoginWatcher"
Cohesion: 0.19
Nodes (4): UntisLoginWatcher, WebChromeClient, WebViewClient, UntisWebLoginScreen()

### Community 128 - "MainActivity.kt"
Cohesion: 0.20
Nodes (4): MainActivity, DeepLinkTarget, homework, melden

### Community 129 - "MeldoTheme.kt"
Cohesion: 0.08
Nodes (11): meldoBlurSource(), meldoChrome(), accentScheme(), dynamicAccentPreview(), isDark(), MeldoColors, MeldoTheme(), withSurfaces() (+3 more)

### Community 131 - "WeekParity"
Cohesion: 0.40
Nodes (5): WeekParity, a, b, every, .id

### Community 137 - "ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package"
Cohesion: 0.33
Nodes (5): ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package, Alternatives considered, Consequences, Context, Decision

### Community 139 - "melde-ffi/src/lib.rs"
Cohesion: 0.19
Nodes (4): FfiDate, FfiDateTime, invalid(), LocalDateTime

### Community 140 - "Windows 11 → macOS build workflow"
Cohesion: 0.17
Nodes (10): ADR-0004: Windows-first development with macOS CI, Consequences, Decision, Daily loop, Interactive macOS when needed, Local toolchain (installed 2026-10-21), One-time Apple setup (needs your accounts; Claude cannot do these), Status (checked 2026-10-22 with `gh run list`) (+2 more)

### Community 141 - "LocalStore"
Cohesion: 0.15
Nodes (5): LoadException, LocalStore, NewerSchema, Unreadable, MeldoApp

### Community 142 - "Models.kt"
Cohesion: 0.09
Nodes (39): InstantSerializer, AppData, DocumentCategory, document, exam, worksheet, ExamDocument, GradeEntry (+31 more)

### Community 144 - "DocumentScanner"
Cohesion: 0.06
Nodes (9): AppDelegate, BackgroundRefresh, MeldePlannerApp, .body, Coordinator, DocumentScanner, .isSupported, BackgroundTasks (+1 more)

### Community 146 - "setup-mac.sh"
Cohesion: 0.67
Nodes (3): MELDE_TEAM_ID, setup-mac.sh script, step()

### Community 148 - "ADR-0005: The app is called Meldo"
Cohesion: 0.50
Nodes (3): ADR-0005: The app is called Meldo, Consequences, Decision

### Community 150 - "AppModel"
Cohesion: 0.06
Nodes (18): AppModel, .currentDate, .ffiEntries, .ffiTimetable, .isSharedWithWidgets, .lessons, .participationGraceMinutes, .preferences (+10 more)

### Community 152 - "AppModelTeams.kt"
Cohesion: 0.14
Nodes (12): Cancelled, Expired, Network, NotConfigured, TeamsFailure, connectTeams(), disconnectTeams(), importTeams() (+4 more)

### Community 153 - "String"
Cohesion: 0.33
Nodes (3): TimeText, WeekdayText, .calendar

### Community 155 - "TeamsClient.swift"
Cohesion: 0.20
Nodes (11): Body, Class, GraphAssignments, GraphClasses, GraphMe, GraphToken, Item, TeamsConfig (+3 more)

### Community 157 - ".onReceive"
Cohesion: 0.24
Nodes (4): Alarms, runAsync(), SurfacesBootReceiver, SurfacesReceiver

### Community 160 - "FfiTaskGroup"
Cohesion: 0.25
Nodes (8): FfiTaskGroup, Completed, Later, NoDate, Overdue, ThisWeek, Today, Tomorrow

### Community 161 - ".importFromUntis"
Cohesion: 0.14
Nodes (4): AppModel, .untisLink, SubjectSymbols, UntisImportSummary

### Community 162 - "Composable"
Cohesion: 0.22
Nodes (4): MeldoDataWidget, MeldoGlanceTheme(), prepareWidgetData(), rememberSnapshot()

### Community 163 - "Architecture Overview"
Cohesion: 0.29
Nodes (7): Android app (ADR-0009), Architecture Overview, PWA path (Phase 19, later), Repository layout, Rules that keep the architecture honest, System, Technology decisions

### Community 164 - ".recordParticipation"
Cohesion: 0.43
Nodes (3): NeedsSubject, Recorded, RecordOutcome

### Community 167 - "ADR-0009: Native Android port in Kotlin + Jetpack Compose (Material 3)"
Cohesion: 0.33
Nodes (5): ADR-0009: Native Android port in Kotlin + Jetpack Compose (Material 3), Alternatives considered, Consequences, Context, Decision

### Community 168 - "Failure"
Cohesion: 0.14
Nodes (12): ExamError, storage, unreadablePDF, Failure, cancelled, denied, expired, network (+4 more)

### Community 169 - "TimetableScreen"
Cohesion: 0.13
Nodes (14): WeekdayText, formSection(), LessonEditorScreen(), PickerRow(), ValueRow(), TimetableLegend(), GoToDateDialog(), isSchoolDay() (+6 more)

### Community 170 - "ExamEditorMode"
Cohesion: 0.40
Nodes (3): ExamEditorMode, Existing, New

### Community 171 - "TimetableMode"
Cohesion: 0.40
Nodes (5): TimetableMode, day, threeDays, twoDays, week

### Community 172 - "FfiGradeScale"
Cohesion: 0.50
Nodes (4): FfiGradeScale, Points, Traditional, g::GradeScale

### Community 176 - "Microsoft Teams: Azure app registration"
Cohesion: 0.50
Nodes (3): Microsoft Teams: Azure app registration, School approval, Steps (about 10 minutes)

### Community 182 - "AppModel+Exams.swift"
Cohesion: 0.40
Nodes (3): PDFKit, UIKit, XCTest

### Community 188 - "Home.md"
Cohesion: 0.24
Nodes (5): Melde Planner, Quick start (Windows 11), Status, Open Questions, Feature Index

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
- **456 isolated node(s):** `orange`, `indigo`, `green`, `system`, `light` (+451 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1428 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **67 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppModel` connect `AppModel` to `AppModel`, `.importTeams`, `Failure`, `AppModelSchool.kt`, `.addExam`, `.toggleDone`, `Foundation`, `.gradeNeeded`, `.untisExams`, `AppearanceChoice`, `.preview`, `AppModel+Exams.swift`, `SharedStoreTests`, `TimetableBlock`, `.mergesIntoExistingData`, `AppModel+Holidays.swift`?**
  _High betweenness centrality (0.263) - this node is a cross-community bridge._
- **Are the 150 inferred relationships involving `L()` (e.g. with `.init()` and `.mutate()`) actually correct?**
  _`L()` has 150 INFERRED edges - model-reasoned connections that need verification._
- **What connects `orange`, `indigo`, `green` to the rest of the system?**
  _456 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `StatsEntry` be split into smaller, more focused modules?**
  _Cohesion score 0.13768115942028986 - nodes in this community are weakly interconnected._
- **Why does `L()` connect `L` to `L`, `.build`, `sfSymbol`, `Date`, `UntisConnectScreen.kt`, `Reminders.kt`, `TimetableStyle.kt`, `AppModelTeams.kt`, `TaskListScreen.kt`, `LogParticipation.kt`, `TimetableScreen`, `SubjectIcon`, `DayGrid`, `RootScreen.kt`, `FormParts.kt`, `CalendarScreen.kt`, `AppModel`, `AbsencesScreen`, `AppModel.kt`, `ExcuseNoteScreen.kt`, `AppModelExams.kt`, `WidgetKit.kt`, `AppModelSchool.kt`, `MeldeEngine`, `LessonCheckIns.kt`, `WidgetStyle`, `Localization.kt`, `AppModelWeek.kt`, `.content`, `StatusScreen`, `MoreWidgets.kt`, `SymbolLabel`, `Surfaces.kt`, `UntisLoginWatcher`?**
  _High betweenness centrality (0.169) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `AppModel` (e.g. with `.widgetWriteIsNotLostWhenAppSaves()` and `.mergesIntoExistingData()`) actually correct?**
  _`AppModel` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Should `Results` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._