---
type: moc
tags:
- features
permalink: melde-planner/04-features/feature-index
---

# Feature Index

Status: `not started` · `in progress` · `implemented (unverified)` · `verified` · `blocked`. "Verified" requires a real build/test run, never an assumption.

| # | Feature | Phase | Status |
|---|---|---|---|
| 1 | Dashboard | 2 | in progress: today, Melde ring + streak, homework card, unassigned Meldungen, reorderable cards, 2-column iPad grid, Meldo mascot; grades/exams/study time missing |
| 2 | Stundenplan | 2 | in progress: subjects, lessons, A/B weeks, overlap validation in Rust; holidays/changes in Rust only, no UI yet |
| 3 | Melde Tracker | 2 | in progress: 1-tap recording, auto lesson match with 5-min grace, manual subject, undo, delete; per-month view missing |
| 4 | Wochenziele | 3 | in progress: overall weekly goal + Rust suggestion; per-subject goals missing |
| 5 | Notenrechner | 3 | in progress: Rust core + tests done (scales, weights, rounding, KMK table); no UI |
| 6 | Notenprognose | 3 | in progress: Rust core + property tests done; no UI |
| 7 | Kalender | 4 | in progress: date picker with lessons and Meldungen per day; exams/homework/events missing |
| 8 | Prüfungen & PDF | 5 | in progress: camera scan to PDF (VisionKit), PDF import, viewer, share, by subject/date, grade text + notes; annotations and sync missing |
| 9 | Todo List | 4 | in progress: homework/to-dos, priorities, due dates, subjects, recurrence, reminders (local), groups from Rust, 'due next lesson'; no sync |
| 10 | Tagesplaner | 4 | not started |
| 11 | Fokus Timer | 4 | not started |
| 12 | Statistiken | 3 | in progress: Swift Charts per day, per subject, 8-week trend (participation only) |
| 13 | Meine Ziele | 3 | not started |
| 14 | Themes | 5 | in progress: 6 themes, Meldo accent, 3 app icons (indigo/orange/night), mascot on/off, haptics, home card order; accessibility review pending |
| 15 | Languages | 5 | in progress: de/tr/en catalog (126 strings) with in-app switching; native-speaker review of Turkish pending |
| 16 | Cloud Sync | 5 | in progress: Supabase schema, RLS and pgTAP tests written; no client sync |
| 17 | Benutzerkonto | 2 | not started |
| 18 | Multiple Users | 2 | in progress: RLS isolation + ownership triggers + tests (server side) |
| 19 | PWA | later | not started |
| 20 | Benachrichtigungen | 4 | in progress: after-lesson check-ins with quick answers (local), task reminders; exam/study-session reminders missing |

Create a note per feature from [[Templates/Feature]] when work starts.
**Verification (2026-10-21):** Rust has 44 tests passing locally. The Swift app, Swift tests and pgTAP tests are written but have **not run yet** (no macOS CI run so far). Nothing is marked `verified`.
| — | Widgets, Control, Live Activity (extra) | 4 | in progress: Home/Lock Screen widget with interactive Melden, Control Center/Lock Screen control, lesson Live Activity; needs App Group at install |
| — | iPad layout (extra) | 5 | in progress: sidebar tabs, 2-column dashboard, full-week timetable grid, side-by-side calendar; Stage Manager/multiwindow untested |
