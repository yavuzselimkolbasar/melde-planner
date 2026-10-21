# Graph Report - Mledeapp  (2026-10-21)

## Corpus Check
- 68 files · ~26,363 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 6 file(s) not represented in the graph (top: (none) 4, .xcstrings 1, .toml 1)

## Summary
- 770 nodes · 1566 edges · 41 communities (34 shown, 7 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 162 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b83ace8b`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- String
- Card
- Results
- Melde Planner
- AppModel
- DayColumn
- ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package
- View
- SubjectColor
- SubjectIcon
- grades.rs
- FfiDate
- check_strings.py
- melde-scheduling/src/lib.rs
- timetable.rs
- average.rs
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
- ADR-NNNN — {{title}}
- melde-core
- Melde Planner — Project Brain
- Melde Planner
- build-rust-ios.sh
- Package.swift
- scan-skills.sh
- uniffi-bindgen

## God Nodes (most connected - your core abstractions)
1. `AppModel` - 59 edges
2. `L()` - 33 edges
3. `AppData` - 22 edges
4. `SubjectColor` - 22 edges
5. `ValidationError` - 22 edges
6. `MeldeError` - 22 edges
7. `AppTheme` - 21 edges
8. `Subject` - 19 edges
9. `GradeScale` - 19 edges
10. `Weekday` - 17 edges

## Surprising Connections (you probably didn't know these)
- `Technology decisions` --references--> `AppModel`  [INFERRED]
  vault/03-Architecture/Architecture Overview.md → apps/ios/MeldePlanner/App/AppModel.swift
- `Rules that keep the architecture honest` --references--> `FfiDate`  [INFERRED]
  vault/03-Architecture/Architecture Overview.md → apps/ios/MeldeCore/Sources/MeldeCore/CalendarBridge.swift
- `Rules that keep the architecture honest` --references--> `FfiDateTime`  [INFERRED]
  vault/03-Architecture/Architecture Overview.md → apps/ios/MeldeCore/Sources/MeldeCore/CalendarBridge.swift
- `Glossary` --references--> `Subject`  [INFERRED]
  vault/05-Glossary/Glossary.md → apps/ios/MeldePlanner/Data/Models.swift
- `Glossary` --references--> `Lesson`  [INFERRED]
  vault/05-Glossary/Glossary.md → apps/ios/MeldePlanner/Data/Models.swift

## Import Cycles
- 2-file cycle: `crates/melde-core/src/lib.rs -> crates/melde-core/src/time.rs -> crates/melde-core/src/lib.rs`

## Communities (41 total, 7 thin omitted)

### Community 0 - "String"
Cohesion: 0.30
Nodes (4): TimeText, WeekdayText, .calendar, .body

### Community 1 - "Card"
Cohesion: 0.13
Nodes (19): Card, .body, ThemedBackground, .body, DayValue, .id, StatisticsView, .body (+11 more)

### Community 2 - "Results"
Cohesion: 0.13
Nodes (13): ADR-0001 — AI tooling, skills and project memory, Consequences, Context, Decision, Addendum — Ponytail, RTK and LLM Council (2026-10-21), Apple skills plugin (indie-apple-stack) — 183 targets — CRITICAL: 4, HIGH: 12, LOW: 127, MEDIUM: 40, claude-mem plugin skills — 27 targets — CRITICAL: 2, HIGH: 2, LOW: 22, MEDIUM: 1, Not installed (by choice, not for security reasons) (+5 more)

### Community 3 - "Melde Planner"
Cohesion: 0.22
Nodes (8): Command output, Commands (Windows), graphify, Hard rules, Melde Planner, Project memory (three layers), Read first, Skills

### Community 4 - "AppModel"
Cohesion: 0.07
Nodes (18): AppModel, .currentDate, .ffiEntries, .ffiTimetable, .lessons, .preferences, .subjects, RecordOutcome (+10 more)

### Community 5 - "DayColumn"
Cohesion: 0.25
Nodes (6): DayColumn, LessonCard, .body, TimetableView, .days, WeekdayBar

### Community 6 - "ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package"
Cohesion: 0.40
Nodes (5): ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package, Alternatives considered, Consequences, Context, Decision

### Community 15 - "View"
Cohesion: 0.18
Nodes (9): AboutView, .body, MoreView, .body, SettingsView, SubjectEditorView, .body, SubjectListView (+1 more)

### Community 16 - "SubjectColor"
Cohesion: 0.05
Nodes (49): AppLanguage, english, german, .id, .nativeName, turkish, Holiday, Lesson (+41 more)

### Community 18 - "SubjectIcon"
Cohesion: 0.16
Nodes (9): Badge, .body, CardHeaderLabelStyle, LessonRow, .body, ProgressRing, .body, SubjectIcon (+1 more)

### Community 25 - "grades.rs"
Cohesion: 0.07
Nodes (37): assessments(), FfiAssessment, FfiCategory, Oral, Written, FfiForecast, FfiForecastOutcome, AlreadySecured (+29 more)

### Community 26 - "FfiDate"
Cohesion: 0.06
Nodes (21): FfiDate, FfiDateTime, FfiWeekday, .mondayIndex, BridgeTests, LoadError, newerSchema, unreadable (+13 more)

### Community 29 - "check_strings.py"
Cohesion: 0.31
Nodes (3): main(), source_keys(), to_key()

### Community 37 - "melde-scheduling/src/lib.rs"
Cohesion: 0.05
Nodes (61): LocalDateTime, LocalTime, .MINUTES_PER_DAY, Weekday, .ALL, Friday, Monday, Saturday (+53 more)

### Community 42 - "timetable.rs"
Cohesion: 0.06
Nodes (44): FfiDate, FfiDateTime, invalid(), LocalDateTime, MeldeError, InvalidInput, entries(), FfiDayCount (+36 more)

### Community 46 - "average.rs"
Cohesion: 0.21
Nodes (18): a(), Assessment, Category, category_average(), Oral, Written, empty_subject_has_no_average(), fifty_fifty_written_oral() (+10 more)

### Community 61 - ".body"
Cohesion: 0.19
Nodes (7): DashboardView, .body, GettingStartedCard, .body, TodayCard, .body, WeekParticipationCard

### Community 68 - "forecast.rs"
Cohesion: 0.25
Nodes (16): detects_already_secured_target(), detects_unreachable_target(), Forecast, forecast(), ForecastOutcome, AlreadySecured, Reachable, Unreachable (+8 more)

### Community 88 - ".status"
Cohesion: 0.13
Nodes (8): CalendarView, MeldeAccessory, .body, SubjectPickerSheet, .body, .body, MeldeCore, SwiftUI

### Community 100 - "GradeScale"
Cohesion: 0.22
Nodes (6): GradeScale, Points, Traditional, RoundingRule, HalfTowardBetter, HalfTowardWorse

### Community 113 - "Melde Planner — Product & Engineering Spec"
Cohesion: 0.14
Nodes (14): 10. Begin development with, 1. Role, 2. Development environment & technical requirements, 3. Design direction — Apple-level premium (highest priority), 4. Features, 5. Additional product requirements, 6. Project structure (suggested; adjust to best practice), 7. Development phases (+6 more)

### Community 114 - "AppTab"
Cohesion: 0.12
Nodes (11): MeldePlannerApp, .body, AppTab, calendar, home, more, statistics, timetable (+3 more)

### Community 125 - "ValidationError"
Cohesion: 0.11
Nodes (15): ensure_finite(), ensure_range(), ValidationError, Invalid, NotFinite, OutOfRange, EPSILON, kmk_point_table_round_trips() (+7 more)

### Community 126 - "LessonEditorView"
Cohesion: 0.20
Nodes (4): L(), LessonEditorView, .body, .body

### Community 139 - "Decision Log.md"
Cohesion: 0.29
Nodes (4): ADR-0003: Offline-first persistence and sync model, Consequences, Decision, Decision Log

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

### Community 258 - "ADR-NNNN — {{title}}"
Cohesion: 0.33
Nodes (5): ADR-NNNN — {{title}}, Alternatives considered, Consequences, Context, Decision

### Community 283 - "melde-core"
Cohesion: 0.70
Nodes (5): melde-core, melde-ffi, melde-grades, melde-scheduling, melde-statistics

### Community 312 - "Melde Planner — Project Brain"
Cohesion: 0.50
Nodes (4): Conventions, Generated (do not hand-edit), Melde Planner — Project Brain, Start here

### Community 328 - "Melde Planner"
Cohesion: 0.67
Nodes (3): Melde Planner, Quick start (Windows 11), Status

## Knowledge Gaps
- **122 isolated node(s):** `PackageDescription`, `.mondayIndex`, `Observation`, `.currentDate`, `.preferences` (+117 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 284 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppModel` connect `AppModel` to `Card`, `DayColumn`, `SubjectColor`, `AppTab`, `FfiDate`, `.body`, `LessonEditorView`?**
  _High betweenness centrality (0.111) - this node is a cross-community bridge._
- **Are the 11 inferred relationships involving `AppModel` (e.g. with `.greeting()` and `.isOver()`) actually correct?**
  _`AppModel` has 11 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `.mondayIndex`, `Observation` to the rest of the system?**
  _122 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Card` be split into smaller, more focused modules?**
  _Cohesion score 0.12681159420289856 - nodes in this community are weakly interconnected._
- **Why does `Subject` connect `SubjectColor` to `SubjectIcon`, `AppModel`, `View`?**
  _High betweenness centrality (0.074) - this node is a cross-community bridge._
- **Are the 31 inferred relationships involving `L()` (e.g. with `.init()` and `.persist()`) actually correct?**
  _`L()` has 31 INFERRED edges - model-reasoned connections that need verification._
- **Should `Results` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._