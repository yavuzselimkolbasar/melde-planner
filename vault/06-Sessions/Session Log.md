---
type: session
tags:
- sessions
permalink: melde-planner/06-sessions/session-log
---

# Session Log

Newest first. One line per working session: date — what changed — what's left. Details go in `06-Sessions/YYYY-MM-DD topic.md` from [[Templates/Session]].

- 2026-10-21: Widgets/Control/Live Activity/check-ins (App Group store, coordinated writes); Meldo brand (icons light/dark/tinted + 2 alternates via resvg, mascot SVGs wave/cheer/sleep), iPad layouts, customization. Next: Supabase sync, WebUntis.
- 2026-10-21: Homework + streaks + exam scanner: melde-tasks crate (grouping, recurrence, homework streak, due-next-lesson), task list/editor/reminders, dashboard homework card, scanner/PDF import/viewer, German de.lproj fix, data migration v1→v2. Decisions: brand Meldo, Supabase sync (no iCloud on free account), WebUntis import. Next: widgets/notifications/Live Activity.
- 2026-10-21 — Phase 1 foundation: architecture doc + ADR-0002..0004, Rust workspace (44 tests), UniFFI bridge, Supabase schema/RLS/pgTAP, SwiftUI shell (5 tabs, Melde accessory, dashboard, timetable, calendar, statistics, settings, de/tr/en), CI workflows. Left: first macOS CI run, onboarding, auth, grades UI.

- 2026-10-21 — Dev environment set up: skills, claude-mem, graphify, this vault, SkillSpector scan. No app code yet.

- 2026-10-21 — UI review on iPhone/iPad simulators (3 runs): app clock fix, iPad week grid and tab order, widget button in tinted/clear mode, WebUntis search hint for -6003, Microsoft 365 / school login (SSO) via in-app WebUntis page. SSO not yet tried with a real account.
- 2026-10-21 — Holidays from WebUntis (Start, Stundenplan banner, Kalender, Mehr → Ferien), 8-week import in one request, SSO login detection on the real host with diagnosis. Build 49bc078 green; not yet tried with a real account.
