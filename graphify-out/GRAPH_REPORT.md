# Graph Report - Mledeapp  (2026-10-22)

## Corpus Check
- 231 files · ~160,800 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 52 file(s) not represented in the graph (top: .xml 38, (none) 7, .properties 2)

## Summary
- 4365 nodes · 11538 edges · 203 communities (152 shown, 51 thin omitted)
- Extraction: 94% EXTRACTED · 6% INFERRED · 0% AMBIGUOUS · INFERRED: 640 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `f91071cc`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- MeldoScreen
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
- View
- MeldeError
- String
- Date
- grades.rs
- DashboardScreen.kt
- ExamListView
- CustomizableCardGrid
- MeldeCore
- DashboardCard
- LocalStore
- AppTab
- Frosted.kt
- melde-scheduling/src/lib.rs
- CaseIterable
- FormSection
- CodingKeys
- TimetableView
- timetable.rs
- UntisLoginWatcher
- Components.kt
- .addExam
- average.rs
- ADR-0007: Optional WebUntis import
- Weekday
- rpc.rs
- TimetableScreen
- Navigator.kt
- Foundation
- TaskEditorScreen
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
- L
- UntisMergeTest.kt
- .onCreate
- AppearanceChoice
- WidgetStyle
- L
- .dayDetails
- AppModelWeek.kt
- RootScreen
- .content
- MeldenButton
- SubjectIcon
- UntisLoginView
- TodayScheduleView
- StatusScreen
- .key
- AppGroup
- GradeScale
- UntisClient.kt
- LessonEditorView
- TeamsClient.kt
- Decision Log.md
- TaskListScreen.kt
- ADR-0006: Sync with Supabase, not iCloud
- AppDelegate
- SwiftUI
- FfiDate
- TaskEditorView
- GradesScreen.kt
- Melde Planner — Product & Engineering Spec
- rememberReduceMotion
- TaskRecurrence
- MeldePlannerApp.swift
- SubjectColor
- TaskList
- String
- MoreWidgets.kt
- SymbolLabel
- DashboardCard
- FfiWeekday
- ValidationError
- MeldeEngine.kt
- UntisLoginWatcher
- MainActivity.kt
- MeldoTheme.kt
- DocumentImport.kt
- Date
- .importTeams
- .build
- MeldoApp.kt
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
- TabBarScrollState
- FormRows.kt
- ADR-0005: The app is called Meldo
- .gradeNeeded
- AppModel
- Alarms.kt
- AppModelTeams.kt
- String
- ExcuseNote
- TeamsClient.swift
- SubjectEditorScreen
- .onReceive
- LogParticipation.kt
- AppModel+Holidays.swift
- FfiTaskGroup
- .importFromUntis
- Composable
- Architecture Overview
- .recordParticipation
- Porting the iOS app to Android (Meldo for Android)
- ADR-0009: Native Android port in Kotlin + Jetpack Compose (Material 3)
- Failure
- LessonEditorScreen
- ExamEditorMode
- TimetableMode
- FfiGradeScale
- Kind
- Microsoft Teams: Azure app registration
- Failure
- SharedStoreTests
- check_strings.py
- AppModel+Exams.swift
- TeamsFailure
- .mergesIntoExistingData
- TaskRecurrence
- PDFKitView
- Home.md
- AppLanguage
- ExamException
- FloatingTabBar
- TaskPriority
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
1. `L()` - 196 edges
2. `AppModel` - 157 edges
3. `L()` - 152 edges
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
- 2-file cycle: `crates/melde-untis/src/lib.rs -> crates/melde-untis/src/rpc.rs -> crates/melde-untis/src/lib.rs`
- 2-file cycle: `crates/melde-untis/src/lib.rs -> crates/melde-untis/src/rest.rs -> crates/melde-untis/src/lib.rs`
- 3-file cycle: `crates/melde-untis/src/lib.rs -> crates/melde-untis/src/rest.rs -> crates/melde-untis/src/rpc.rs -> crates/melde-untis/src/lib.rs`

## Communities (203 total, 51 thin omitted)

### Community 0 - "MeldoScreen"
Cohesion: 0.09
Nodes (23): AboutScreen(), AccentRow(), AccentSwatch(), AppIconPickerScreen(), ExcuseDetailsDialog(), iconTitle(), MoreScreen(), SettingsScreen() (+15 more)

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
Cohesion: 0.07
Nodes (37): Card(), Mascot(), CheckInPromptCard(), AbsencesCard(), BlockRow(), CardButton(), DashboardCardView(), DashboardScreen() (+29 more)

### Community 6 - "derive.rs"
Cohesion: 0.15
Nodes (22): LocalTime, .MINUTES_PER_DAY, cancellations_and_substitutions_become_changes(), d(), derive_schedule(), DerivedChange, DerivedChangeKind, Cancelled (+14 more)

### Community 7 - "sfSymbol"
Cohesion: 0.13
Nodes (14): sfSymbol(), ExamDetailScreen(), OpenPdf, PdfView(), DocumentCategoryText, ExamList(), ExamListScreen(), ExamRow() (+6 more)

### Community 9 - "Date"
Cohesion: 0.08
Nodes (35): d(), Group, Completed, Later, NoDate, group_of(), Overdue, ThisWeek (+27 more)

### Community 10 - "Codable"
Cohesion: 0.17
Nodes (23): ContentState, AppData, BellPeriod, ExamDocument, .kind, GradeEntry, Holiday, Lesson (+15 more)

### Community 11 - "MeldeError"
Cohesion: 0.12
Nodes (26): date(), FfiPriority, High, Low, Normal, FfiRecurrence, Biweekly, Daily (+18 more)

### Community 12 - "melde-statistics/src/lib.rs"
Cohesion: 0.17
Nodes (16): d(), daily_counts(), daily_counts_include_empty_days(), entry(), goal_progress(), goal_progress_caps_fraction(), GoalProgress, ParticipationEntry (+8 more)

### Community 16 - "UntisConnectScreen.kt"
Cohesion: 0.19
Nodes (14): TeamsConnectScreen(), ConnectActionRow(), ConnectIconLabel(), ConnectLabeledRow(), ConnectList(), ConnectNote(), connectRelativeTime(), ConnectSection() (+6 more)

### Community 17 - ".toggleDone"
Cohesion: 0.13
Nodes (3): .tasks, TaskSection, .id

### Community 18 - "properties.rs"
Cohesion: 0.28
Nodes (5): category_strategy(), config_and_assessments(), rounding_strategy(), scale_strategy(), value_for()

### Community 19 - "participation.rs"
Cohesion: 0.25
Nodes (11): entries(), FfiDayCount, FfiGoalProgress, FfiParticipationEntry, FfiSubjectCount, FfiWeekSummary, participation_daily_counts(), participation_goal_progress() (+3 more)

### Community 20 - "Preferences"
Cohesion: 0.09
Nodes (16): .groups, AppIconChoice, .assetName, .id, night, orange, standard, CardSlot (+8 more)

### Community 21 - "View"
Cohesion: 0.10
Nodes (21): CircularView, .body, LessonHeader, .body, LessonInfo, MediumView, .body, MeldenButton (+13 more)

### Community 22 - "MeldeError"
Cohesion: 0.08
Nodes (40): MeldeError, InvalidInput, UntisMalformed, UntisServer, derives_schedule_across_the_boundary(), ffi_exam(), FfiTimeUnit, FfiUntisAbsence (+32 more)

### Community 23 - "String"
Cohesion: 0.24
Nodes (3): Assignment, TeamsClient, Tokens

### Community 24 - "Date"
Cohesion: 0.12
Nodes (5): .ffiEntries, .lessons, RecordOutcome, needsSubject, recorded

### Community 25 - "grades.rs"
Cohesion: 0.08
Nodes (33): assessments(), FfiAssessment, FfiCategory, Oral, Written, FfiForecast, FfiForecastOutcome, AlreadySecured (+25 more)

### Community 26 - "DashboardScreen.kt"
Cohesion: 0.10
Nodes (9): holiday(), HolidayText, upcomingHolidays(), homeworkStreak(), DS, TimeText, statsCardSymbol(), statsCardTitle() (+1 more)

### Community 27 - "ExamListView"
Cohesion: 0.09
Nodes (18): DocumentCategoryText, ExamDetailView, .body, ExamEditorView, .body, .isNew, ExamListView, .actionButtons (+10 more)

### Community 28 - "CustomizableCardGrid"
Cohesion: 0.07
Nodes (22): CardDropDelegate, CardGridLayout, .title, CardSpanKey, CustomizableCardGrid, .body, .columns, .hiddenCards (+14 more)

### Community 30 - "MeldeCore"
Cohesion: 0.14
Nodes (10): GradeEditorView, .body, .usesPoints, .value, GradeSettingsView, .body, GradesView, .body (+2 more)

### Community 31 - "DashboardCard"
Cohesion: 0.13
Nodes (15): DashboardCard, absences, exams, grades, homework, .id, news, nextHoliday (+7 more)

### Community 33 - "LocalStore"
Cohesion: 0.17
Nodes (4): LoadError, newerSchema, unreadable, LocalStore

### Community 34 - "AppTab"
Cohesion: 0.12
Nodes (17): AppTab, about, absences, calendar, exams, grades, holidays, home (+9 more)

### Community 36 - "Frosted.kt"
Cohesion: 0.10
Nodes (15): MeldoMenu(), meldoMenuGroupColor(), MeldoMenuItem, meldoMenuItemColors(), MeldoSegmented(), MenuAnchor(), applyBlurBehind(), frosted() (+7 more)

### Community 37 - "melde-scheduling/src/lib.rs"
Cohesion: 0.13
Nodes (27): ab_weeks_alternate(), cancelled_and_substituted_lessons(), ChangeKind, Cancelled, Substituted, current_and_next_lesson(), d(), holidays_remove_lessons() (+19 more)

### Community 38 - "CaseIterable"
Cohesion: 0.10
Nodes (19): DocumentCategory, document, exam, .folderName, .id, worksheet, GradeScaleChoice, .id (+11 more)

### Community 39 - "FormSection"
Cohesion: 0.11
Nodes (33): GradeChip(), GradeEditorSheet(), GradeRow(), GradeSettingsSheet(), GradesScreen(), Stat(), SubjectGradesScreen(), ActionRow() (+25 more)

### Community 40 - "CodingKeys"
Cohesion: 0.08
Nodes (23): CodingKeys, adultStudent, appearance, appIcon, askAfterLesson, checkInPromptDismissed, className, dashboardCards (+15 more)

### Community 41 - "TimetableView"
Cohesion: 0.04
Nodes (58): Mood, cheer, sleep, wave, .body, BlockDetail, compact, full (+50 more)

### Community 42 - "timetable.rs"
Cohesion: 0.12
Nodes (27): current_lesson_round_trip(), FfiChangeKind, Cancelled, Substituted, FfiHoliday, FfiLesson, FfiOccurrence, FfiTimetable (+19 more)

### Community 43 - "UntisLoginWatcher"
Cohesion: 0.15
Nodes (6): .body, Coordinator, UntisLoginWatcher, UntisWebLoginView, .body, UntisWebView

### Community 44 - "Components.kt"
Cohesion: 0.19
Nodes (7): Badge(), HSpacer(), LessonRow(), ProgressRing(), SectionHeader(), SubjectIcon(), WeekdayText

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
Cohesion: 0.10
Nodes (18): Weekday, .ALL, Friday, Monday, Saturday, Sunday, Thursday, Tuesday (+10 more)

### Community 49 - "rpc.rs"
Cohesion: 0.10
Nodes (35): UntisError, .BAD_CREDENTIALS, Malformed, .NOT_AUTHENTICATED, Server, Auth, authenticate_request(), CLIENT (+27 more)

### Community 50 - "TimetableScreen"
Cohesion: 0.05
Nodes (35): LabeledValue(), SheetButton(), SheetLabel(), SheetSection(), TimetableBlockSheet(), blockAccessibilityText(), BlockDetail, compact (+27 more)

### Community 51 - "Navigator.kt"
Cohesion: 0.07
Nodes (3): meldoBlurSource(), meldoChrome(), meldoHairline()

### Community 52 - "Foundation"
Cohesion: 0.17
Nodes (4): Foundation, MeldePlanner, Observation, Testing

### Community 53 - "TaskEditorScreen"
Cohesion: 0.18
Nodes (11): ExamEditorScreen(), ProblemLabel(), FormDivider(), FormSection(), FormValue(), PickerRow(), SwitchRow(), SubjectPickerRow() (+3 more)

### Community 54 - "CalendarScreen.kt"
Cohesion: 0.04
Nodes (10): tasks(), drawMeldo(), MascotMood, cheer, sleep, wave, roundRect(), groupedShape() (+2 more)

### Community 55 - ".preview"
Cohesion: 0.21
Nodes (3): FfiDateTime, Calendar, MeldeEngine

### Community 56 - "MoreWidgets.swift"
Cohesion: 0.05
Nodes (32): MeldeWidgetsBundle, .body, MeldoStatsWidget, .body, StatsEntry, StatsProvider, StatsWidgetView, .body (+24 more)

### Community 58 - "rest.rs"
Cohesion: 0.10
Nodes (22): Absence, data(), day(), Exam, Homework, NewsMessage, parse_absences(), parse_duration() (+14 more)

### Community 59 - "TimetableBlock"
Cohesion: 0.11
Nodes (9): Kind, cancelled, exam, regular, roomChange, substitution, TimetableBlock, .roomChanged (+1 more)

### Community 60 - "State"
Cohesion: 0.12
Nodes (11): SubjectEditorView, .body, SubjectListView, .body, Localization, .bundle, .locale, State (+3 more)

### Community 61 - "View"
Cohesion: 0.07
Nodes (44): Card, Mascot, .body, CheckInPromptCard, .body, AbsencesCard, .body, BlockRow (+36 more)

### Community 62 - "scale.rs"
Cohesion: 0.18
Nodes (8): EPSILON, kmk_point_table_round_trips(), points_to_traditional(), Tendency, Minus, None, Plus, traditional_to_points()

### Community 63 - ".body"
Cohesion: 0.10
Nodes (16): HolidayListView, AboutView, .body, MoreView, .body, SettingsView, AbsenceRow, .dates (+8 more)

### Community 64 - "Charts.kt"
Cohesion: 0.08
Nodes (8): SymbolBitmaps, BarChart(), LineChart(), monotonePath(), niceTicks(), Plot, rememberAnimatedValues(), yAxis()

### Community 65 - "AppModelUntis.kt"
Cohesion: 0.09
Nodes (21): newID(), disconnectTeams(), applyUntis(), applyUntisHolidays(), connectUntis(), connectUntisWithBrowser(), disconnectUntis(), importFromUntis() (+13 more)

### Community 66 - "AppModel"
Cohesion: 0.07
Nodes (4): AppModel, deleteGrade(), setTendencyStep(), setWrittenWeight()

### Community 67 - "AbsencesScreen"
Cohesion: 0.12
Nodes (11): CalendarLegend(), CalendarScreen(), DayCell(), DayDetails(), Dot(), MeldungGroup, MonthGrid(), absenceDates() (+3 more)

### Community 68 - "forecast.rs"
Cohesion: 0.25
Nodes (16): detects_already_secured_target(), detects_unreachable_target(), Forecast, forecast(), ForecastOutcome, AlreadySecured, Reachable, Unreachable (+8 more)

### Community 69 - "AppModel.kt"
Cohesion: 0.09
Nodes (18): AppIconChoice, night, orange, standard, AppLanguage, english, german, turkish (+10 more)

### Community 70 - "ExcuseNoteScreen.kt"
Cohesion: 0.06
Nodes (6): setExcuseDetails(), share(), print(), PrintDocumentAdapter, renderFirstPage(), share()

### Community 71 - "AppModelExams.kt"
Cohesion: 0.14
Nodes (8): addExam(), deleteExam(), exam(), ExamFiles, file(), organizeDocuments(), ScanMirror, update()

### Community 72 - "SubjectColor"
Cohesion: 0.07
Nodes (22): AppearanceChoice, dark, light, system, AppTheme, green, indigo, orange (+14 more)

### Community 73 - "WidgetKit.kt"
Cohesion: 0.08
Nodes (7): Caption(), Countdown(), MeldenWidgetCallback, Symbol(), timeText(), WidgetColors, WidgetText

### Community 74 - "AppModelSchool.kt"
Cohesion: 0.11
Nodes (10): absences(), assessments(), gradeNeeded(), grades(), gradeSummary(), holidayInWeekOf(), saveGrade(), setGradeScale() (+2 more)

### Community 75 - "MeldoCalendar"
Cohesion: 0.20
Nodes (4): MeldoCalendar, CardHeader(), MeldoColors, Architecture (already in place — read these files first)

### Community 79 - "AppModelTasks.kt"
Cohesion: 0.12
Nodes (10): deleteTask(), ffiTask(), nextLessonDay(), shiftReminder(), task(), TaskSection, taskSections(), toggleDone() (+2 more)

### Community 80 - "TeamsClient"
Cohesion: 0.17
Nodes (5): Assignment, Authorization, Denied, TeamsClient, Tokens

### Community 81 - "AppTab"
Cohesion: 0.12
Nodes (17): AppTab, about, absences, calendar, exams, grades, holidays, home (+9 more)

### Community 82 - "L"
Cohesion: 0.09
Nodes (15): L(), CustomizeButton(), dashboardCardSymbol(), dashboardCardTitle(), forecastText(), appearanceName(), sizeTitle(), themeName() (+7 more)

### Community 85 - "AppearanceChoice"
Cohesion: 0.15
Nodes (9): SampleData, UITestLaunch, AppearanceChoice, .colorScheme, dark, .id, light, .localizedName (+1 more)

### Community 86 - "WidgetStyle"
Cohesion: 0.30
Nodes (10): LessonHeader(), LessonInfo, MediumView(), SmallView(), TodayEntry, TodayWidgetView(), Unavailable(), WeekLine() (+2 more)

### Community 87 - "L"
Cohesion: 0.15
Nodes (14): .body, WeeklyGoalSheet, .body, .body, AppIconPicker, .body, DashboardCardsView, .body (+6 more)

### Community 88 - ".dayDetails"
Cohesion: 0.11
Nodes (15): CalendarLegend, .body, .items, CalendarView, .date, .dayDetails, .month, DayCell (+7 more)

### Community 90 - "AppModelWeek.kt"
Cohesion: 0.17
Nodes (15): assignLanes(), block(), chooseCourse(), courseKey(), Kind, cancelled, exam, regular (+7 more)

### Community 91 - "RootScreen"
Cohesion: 0.38
Nodes (4): Destination, DrawerItem(), RootScreen(), StorageBanner()

### Community 92 - ".content"
Cohesion: 0.16
Nodes (6): disabledInSettings, failed, LivePreviewResult, noLessons, shown, Surfaces

### Community 93 - "MeldenButton"
Cohesion: 0.14
Nodes (9): MeldenButton, .body, .label, .lessonCount, SubjectPickerSheet, .body, .suggestions, Suggestion (+1 more)

### Community 94 - "SubjectIcon"
Cohesion: 0.11
Nodes (12): Badge, .body, .body, CardHeaderLabelStyle, LessonRow, .body, ProgressRing, .body (+4 more)

### Community 95 - "UntisLoginView"
Cohesion: 0.16
Nodes (10): .body, UntisLoginView, .body, UntisMessages, UntisSchoolSearchView, .body, UntisStatusView, .school (+2 more)

### Community 96 - "TodayScheduleView"
Cohesion: 0.18
Nodes (10): HolidayCountdownView(), HomeworkWidgetView(), TodayScheduleView(), dateText(), Family, large, medium, small (+2 more)

### Community 97 - "StatusScreen"
Cohesion: 0.31
Nodes (4): Notifications, StatusRow(), StatusScreen(), StatusState

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
Cohesion: 0.16
Nodes (8): Body, Class, GraphAssignments, GraphClasses, GraphMe, GraphToken, Item, TeamsConfig

### Community 105 - "Decision Log.md"
Cohesion: 0.25
Nodes (5): ADR-0008: Microsoft Teams assignments via Microsoft Graph, Consequences, Context, Decision, Decision Log

### Community 107 - "ADR-0006: Sync with Supabase, not iCloud"
Cohesion: 0.40
Nodes (5): ADR-0006: Sync with Supabase, not iCloud, Consequences, Context, Decision, Update 2026-10-21: superseded

### Community 109 - "SwiftUI"
Cohesion: 0.04
Nodes (31): ActivityKit, AppIntents, DS, HolidayBanner, .body, StatusView, .body, .groupName (+23 more)

### Community 111 - "TaskEditorView"
Cohesion: 0.07
Nodes (17): ThemedBackground, .body, HomeworkCard, .body, .body, TaskEditorView, .body, .defaultReminder (+9 more)

### Community 112 - "GradesScreen.kt"
Cohesion: 0.08
Nodes (3): Localization, gradeText(), PagerSetup

### Community 113 - "Melde Planner — Product & Engineering Spec"
Cohesion: 0.14
Nodes (14): 10. Begin development with, 1. Role, 2. Development environment & technical requirements, 3. Design direction — Apple-level premium (highest priority), 4. Features, 5. Additional product requirements, 6. Project structure (suggested; adjust to best practice), 7. Development phases (+6 more)

### Community 114 - "rememberReduceMotion"
Cohesion: 0.17
Nodes (12): CardCell(), CustomizableCardGrid(), EditChrome(), HiddenCardsTray(), rememberHaptic(), rememberReduceMotion(), ResizeHandle(), span() (+4 more)

### Community 115 - "TaskRecurrence"
Cohesion: 0.29
Nodes (7): TaskRecurrence, biweekly, daily, .id, never, weekdays, weekly

### Community 116 - "MeldePlannerApp.swift"
Cohesion: 0.29
Nodes (4): BackgroundRefresh, MeldePlannerApp, .body, BackgroundTasks

### Community 117 - "SubjectColor"
Cohesion: 0.08
Nodes (25): AppTheme, green, .id, indigo, .localizedName, orange, .tint, .wash (+17 more)

### Community 118 - "TaskList"
Cohesion: 0.17
Nodes (10): CheckCircle(), EmptyState(), rowAnimation(), SwipeToDelete(), TaskBoard(), TaskFilterPicker(), TaskList(), TaskListScreen() (+2 more)

### Community 119 - "String"
Cohesion: 0.13
Nodes (6): Action, once, skip, twice, Answer, LessonCheckIns

### Community 120 - "MoreWidgets.kt"
Cohesion: 0.16
Nodes (14): HolidayCountdownWidget, HolidayCountdownWidgetReceiver, HomeworkWidget, HomeworkWidgetReceiver, MeldoDataWidget, TodayScheduleWidget, TodayScheduleWidgetReceiver, MeldoStatsWidget (+6 more)

### Community 121 - "SymbolLabel"
Cohesion: 0.39
Nodes (6): Chart(), StatsEntry, StatsWidgetView(), Summary(), weekday(), SymbolLabel()

### Community 122 - "DashboardCard"
Cohesion: 0.14
Nodes (14): DashboardCard, absences, exams, grades, homework, news, nextHoliday, nextLesson (+6 more)

### Community 125 - "ValidationError"
Cohesion: 0.13
Nodes (7): ensure_finite(), ensure_range(), ValidationError, Invalid, NotFinite, OutOfRange, traditional_value()

### Community 126 - "MeldeEngine.kt"
Cohesion: 0.12
Nodes (5): ffiWeekday(), WeekParity, a, b, every

### Community 127 - "UntisLoginWatcher"
Cohesion: 0.19
Nodes (4): UntisLoginWatcher, WebChromeClient, WebViewClient, UntisWebLoginScreen()

### Community 128 - "MainActivity.kt"
Cohesion: 0.20
Nodes (4): MainActivity, DeepLinkTarget, homework, melden

### Community 129 - "MeldoTheme.kt"
Cohesion: 0.20
Nodes (5): accentScheme(), brandColor(), isDark(), MeldoTheme(), withSurfaces()

### Community 130 - "DocumentImport.kt"
Cohesion: 0.17
Nodes (6): decode(), DocumentImporter, findActivity(), PendingExam, read(), rememberDocumentImporter()

### Community 131 - "Date"
Cohesion: 0.24
Nodes (8): LocalDateTime, Date, Holiday, monday_of(), Occurrence, Timetable, TimetableChange, next_lesson_date()

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
Cohesion: 0.29
Nodes (4): LoadException, LocalStore, NewerSchema, Unreadable

### Community 142 - "Models.kt"
Cohesion: 0.12
Nodes (35): InstantSerializer, AppData, BellPeriod, DocumentCategory, document, exam, worksheet, ExamDocument (+27 more)

### Community 144 - "DocumentScanner"
Cohesion: 0.16
Nodes (3): Coordinator, DocumentScanner, .isSupported

### Community 147 - "FormRows.kt"
Cohesion: 0.15
Nodes (5): extend(), formatDate(), formRowShape(), Segments, syncText()

### Community 148 - "ADR-0005: The app is called Meldo"
Cohesion: 0.50
Nodes (3): ADR-0005: The app is called Meldo, Consequences, Decision

### Community 150 - "AppModel"
Cohesion: 0.07
Nodes (15): AppModel, .currentDate, .ffiTimetable, .isSharedWithWidgets, .participationGraceMinutes, .preferences, .subjects, .gradeConfig (+7 more)

### Community 152 - "AppModelTeams.kt"
Cohesion: 0.31
Nodes (5): connectTeams(), importTeams(), refreshTeams(), refreshTeamsIfStale(), TeamsMerge

### Community 153 - "String"
Cohesion: 0.33
Nodes (3): TimeText, WeekdayText, .calendar

### Community 154 - "ExcuseNote"
Cohesion: 0.19
Nodes (5): .body, ExcuseNote, .bodyText, .defaultSalutation, ExcuseNoteView

### Community 155 - "TeamsClient.swift"
Cohesion: 0.20
Nodes (11): Body, Class, GraphAssignments, GraphClasses, GraphMe, GraphToken, Item, TeamsConfig (+3 more)

### Community 156 - "SubjectEditorScreen"
Cohesion: 0.21
Nodes (5): MorphShape, EvenGrid(), section(), SubjectEditorScreen(), SubjectRow()

### Community 157 - ".onReceive"
Cohesion: 0.42
Nodes (3): runAsync(), SurfacesBootReceiver, SurfacesReceiver

### Community 160 - "FfiTaskGroup"
Cohesion: 0.25
Nodes (8): FfiTaskGroup, Completed, Later, NoDate, Overdue, ThisWeek, Today, Tomorrow

### Community 162 - "Composable"
Cohesion: 0.13
Nodes (6): meldoPreferences(), MeldoGlanceTheme(), NotConnected(), prepareWidgetData(), rememberSnapshot(), WidgetContainer()

### Community 163 - "Architecture Overview"
Cohesion: 0.29
Nodes (7): Android app (ADR-0009), Architecture Overview, PWA path (Phase 19, later), Repository layout, Rules that keep the architecture honest, System, Technology decisions

### Community 164 - ".recordParticipation"
Cohesion: 0.43
Nodes (3): NeedsSubject, Recorded, RecordOutcome

### Community 166 - "Porting the iOS app to Android (Meldo for Android)"
Cohesion: 0.40
Nodes (4): Build, Ownership (parallel ports — touch only your files), Porting the iOS app to Android (Meldo for Android), Rules (from the project CLAUDE.md, they apply here too)

### Community 167 - "ADR-0009: Native Android port in Kotlin + Jetpack Compose (Material 3)"
Cohesion: 0.33
Nodes (5): ADR-0009: Native Android port in Kotlin + Jetpack Compose (Material 3), Alternatives considered, Consequences, Context, Decision

### Community 168 - "Failure"
Cohesion: 0.20
Nodes (9): ExamError, storage, unreadablePDF, Failure, cancelled, denied, expired, network (+1 more)

### Community 169 - "LessonEditorScreen"
Cohesion: 0.28
Nodes (5): formSection(), LessonEditorScreen(), parityTitle(), PickerRow(), ValueRow()

### Community 170 - "ExamEditorMode"
Cohesion: 0.40
Nodes (3): ExamEditorMode, Existing, New

### Community 171 - "TimetableMode"
Cohesion: 0.40
Nodes (5): TimetableMode, day, threeDays, twoDays, week

### Community 172 - "FfiGradeScale"
Cohesion: 0.50
Nodes (4): FfiGradeScale, Points, Traditional, g::GradeScale

### Community 174 - "Kind"
Cohesion: 0.67
Nodes (3): Kind, cancelled, substituted

### Community 176 - "Microsoft Teams: Azure app registration"
Cohesion: 0.50
Nodes (3): Microsoft Teams: Azure app registration, School approval, Steps (about 10 minutes)

### Community 177 - "Failure"
Cohesion: 0.22
Nodes (8): Failure, network, noAccess, noLessons, server, sessionExpired, tooManyResults, wrongCredentials

### Community 181 - "check_strings.py"
Cohesion: 0.31
Nodes (3): main(), source_keys(), to_key()

### Community 182 - "AppModel+Exams.swift"
Cohesion: 0.29
Nodes (4): PDFKit, UIKit, VisionKit, XCTest

### Community 183 - "TeamsFailure"
Cohesion: 0.29
Nodes (6): Cancelled, Expired, Network, NotConfigured, TeamsFailure, teamsMessage()

### Community 186 - "TaskRecurrence"
Cohesion: 0.33
Nodes (6): TaskRecurrence, biweekly, daily, never, weekdays, weekly

### Community 188 - "Home.md"
Cohesion: 0.24
Nodes (5): Melde Planner, Quick start (Windows 11), Status, Open Questions, Feature Index

### Community 189 - "AppLanguage"
Cohesion: 0.33
Nodes (6): AppLanguage, english, german, .id, .nativeName, turkish

### Community 190 - "ExamException"
Cohesion: 0.40
Nodes (4): ExamException, Reason, storage, unreadablePDF

### Community 191 - "FloatingTabBar"
Cohesion: 0.70
Nodes (3): FloatingTabBar(), TabButton(), TabItem

### Community 192 - "TaskPriority"
Cohesion: 0.40
Nodes (5): TaskPriority, high, .id, low, normal

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
- **452 isolated node(s):** `orange`, `indigo`, `green`, `system`, `light` (+447 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1404 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **51 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppModel` connect `AppModel` to `AppModel`, `.importFromUntis`, `.importTeams`, `Failure`, `Codable`, `AppModelSchool.kt`, `.addExam`, `.toggleDone`, `Foundation`, `.gradeNeeded`, `AppearanceChoice`, `.preview`, `Date`, `AppModel+Exams.swift`, `SharedStoreTests`, `TimetableBlock`, `.mergesIntoExistingData`, `AppModel+Holidays.swift`?**
  _High betweenness centrality (0.277) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `AppModel` (e.g. with `.widgetWriteIsNotLostWhenAppSaves()` and `.mergesIntoExistingData()`) actually correct?**
  _`AppModel` has 3 INFERRED edges - model-reasoned connections that need verification._
- **What connects `orange`, `indigo`, `green` to the rest of the system?**
  _452 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `MeldoScreen` be split into smaller, more focused modules?**
  _Cohesion score 0.08502024291497975 - nodes in this community are weakly interconnected._
- **Why does `L()` connect `L` to `MeldoScreen`, `DocumentImport.kt`, `.build`, `L`, `sfSymbol`, `MoreScreen.kt`, `UntisConnectScreen.kt`, `Reminders.kt`, `FormRows.kt`, `DashboardScreen.kt`, `SubjectEditorScreen`, `LogParticipation.kt`, `Composable`, `TimetableGrid.kt`, `Porting the iOS app to Android (Meldo for Android)`, `FormSection`, `LessonEditorScreen`, `Components.kt`, `TimetableScreen`, `Navigator.kt`, `TaskEditorScreen`, `CalendarScreen.kt`, `TeamsFailure`, `AppModel`, `AbsencesScreen`, `AppModel.kt`, `ExcuseNoteScreen.kt`, `AppModelExams.kt`, `WidgetKit.kt`, `AppModelSchool.kt`, `MeldeEngine`, `LessonCheckIns.kt`, `WidgetStyle`, `Localization.kt`, `AppModelWeek.kt`, `RootScreen`, `.content`, `TodayScheduleView`, `StatusScreen`, `TaskListScreen.kt`, `GradesScreen.kt`, `rememberReduceMotion`, `TaskList`, `SymbolLabel`, `Notifications.kt`, `UntisLoginWatcher`?**
  _High betweenness centrality (0.195) - this node is a cross-community bridge._
- **Are the 150 inferred relationships involving `L()` (e.g. with `.init()` and `.mutate()`) actually correct?**
  _`L()` has 150 INFERRED edges - model-reasoned connections that need verification._
- **Should `Results` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._