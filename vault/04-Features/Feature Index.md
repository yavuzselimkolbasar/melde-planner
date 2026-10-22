---
type: moc
tags:
- features
permalink: melde-planner/04-features/feature-index
---

# Feature Index

Status: `not started` · `in progress` · `implemented (unverified)` · `verified` · `blocked` · `deferred` · `dropped`. "Verified" requires a real build/test run, never an assumption.

**Build state (2026-10-22):** everything below that says "(unbuilt)" in older notes is now compiled: `core.yml` and `ios.yml` are green on `fc22606` (77 Rust tests, 5 Swift Testing suites). Compiling is not the same as verified: most screens have no automated test and none has been tried with a real WebUntis/Teams account, so nothing is marked `verified` yet.

| # | Feature | Phase | Status |
|---|---|---|---|
| 1 | Dashboard | 2 | in progress: customizable cards (small/medium/large, drag or arrows, hide/add) for today preview, week preview, Meldungen, streak, homework, Untis exams, school news, absences; grades/study time missing |
| 2 | Stundenplan | 2 | in progress: Untis-style time grid with bell times, breaks, merged double periods, exam/room change/cancel/substitution colors, holidays blue, week and day paging, look-ahead limit; manual lessons and A/B weeks |
| 3 | Melde Tracker | 2 | in progress: 1-tap recording, auto lesson match with 5-min grace, manual subject, undo, delete; per-month view missing |
| 4 | Wochenziele | 3 | in progress: overall weekly goal + Rust suggestion; per-subject goals missing |
| 5 | Notenrechner | 3 | in progress: Rust core + tests done (scales, weights, rounding, KMK table); no UI |
| 6 | Notenprognose | 3 | in progress: Rust core + property tests done; no UI |
| 7 | Kalender | 4 | in progress: own month grid with flame on Meldung days, exam/homework/absence dots, holidays; day shows Untis lessons, exams, homework, absences, grouped Meldungen |
| 8 | Prüfungen & PDF | 5 | in progress: camera scan to PDF (VisionKit), PDF import, viewer, share, by subject/date, grade text + notes; annotations and sync missing |
| 9 | Todo List | 4 | in progress: homework/to-dos, priorities, due dates, subjects, recurrence, reminders (local), groups from Rust, 'due next lesson'; no sync |
| 10 | Tagesplaner | 4 | not started |
| 11 | Fokus Timer | 4 | not started |
| 12 | Statistiken | 3 | in progress: Swift Charts per day, per subject, 8-week trend on customizable cards |
| 13 | Meine Ziele | 3 | not started |
| 14 | Themes | 5 | in progress: 6 themes, Meldo accent, 3 app icons (indigo/orange/night), mascot on/off, haptics, home card order; accessibility review pending |
| 15 | Languages | 5 | in progress: de/tr/en catalog (126 strings) with in-app switching; native-speaker review of Turkish pending |
| 16 | Cloud Sync | 5 | deferred: waits for the paid Apple Developer account, then iCloud (ADR-0006 update) |
| 17 | Benutzerkonto | 2 | deferred: no account while Meldo is local-only; revisit with iCloud sync (ADR-0006 update) |
| 18 | Multiple Users | 2 | deferred: the Supabase RLS isolation + ownership triggers + pgTAP tests exist in `supabase/` but are unused since Supabase was dropped (ADR-0006 update); data is per device |
| 19 | PWA | later | not started; data source open since there is no Supabase backend |
| 20 | Benachrichtigungen | 4 | in progress: after-lesson check-ins with quick answers (local), task reminders; exam/study-session reminders missing |

Create a note per feature from [[Templates/Feature]] when work starts.
**Verification (2026-10-22):** see *Build state* at the top: Rust (77 tests) and the Swift test suites pass on CI at `fc22606`; TestFlight has never run. Nothing is marked `verified`.
| — | Widgets, Control, Live Activity (extra) | 4 | in progress: Home/Lock Screen widget with interactive Melden, Control Center/Lock Screen control, lesson Live Activity; needs App Group at install |
| — | WebUntis (extra) | 4 | in progress: school search, password or Microsoft 365/school login, 8-week timetable, holidays, bell schedule, absences, exams, homework → Aufgaben, school news (ADR-0007) |
| — | Microsoft Teams (extra) | 4 | in progress: Graph assignments → Aufgaben via PKCE sign-in; needs Azure client ID (ADR-0008, Teams Azure Setup) |
| — | iPad layout (extra) | 5 | in progress: sidebar with Schule/App sections for every destination, 4-column card grid, week grid, side-by-side calendar; Melden only on Start and Stundenplan |
