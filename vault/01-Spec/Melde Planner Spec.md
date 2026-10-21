---
type: spec
status: source-of-truth
tags:
- spec
- melde-planner
permalink: melde-planner/01-spec/melde-planner-spec
---

# Melde Planner — Product & Engineering Spec

> Original brief from the product owner. This note is the **source of truth**. If code, ADRs or other notes disagree with it, flag the conflict instead of silently picking one. Per-feature notes live in [[04-Features/Feature Index]]; terminology in [[05-Glossary/Glossary]].

## 1. Role
Act as a senior Apple platform engineer, expert Rust developer, UI/UX designer, and full-stack software architect. Design and develop a complete, production-quality iOS application called **"Melde Planner"**: an intelligent academic productivity app primarily for students attending German schools. It combines grade management, classroom participation tracking, academic goals, exam preparation, scheduling, productivity tools and detailed statistics. It must feel like a polished, premium Apple product — not a generic school-management app or web dashboard. Real, functional app; excellent performance; sophisticated design; reliable data handling; scalable architecture.

## 2. Development environment & technical requirements

**Primary environment:** Windows 11 · VS Code · Rust core · native iOS target (iPhone + iPad) · Apple Liquid Glass design language · Supabase backend · Git + GitHub.

### Architecture
**Native iOS frontend:** SwiftUI; genuine Liquid Glass components/materials; native navigation, gestures, sheets, menus, transitions, animations; SF Symbols + Apple typography; Swift Charts; native notifications, document scanning, PDF viewing.

**Rust core** (wherever technically practical): grade calculations, grade forecasting, goal algorithms, participation statistics, timetable/scheduling logic, data validation, business logic, offline data management, synchronization logic. Use a maintained Rust↔Swift interop solution (UniFFI or appropriate FFI).

**Backend:** Supabase PostgreSQL, Auth, Storage, Row Level Security, secure cloud sync.

### Windows 11 workflow
The owner has **no Mac**. Write/maintain on Windows 11; build/test the iOS app with Xcode on a remote macOS environment or GitHub Actions macOS runners. Explain build-system config, Apple developer accounts, signing, provisioning, TestFlight. **Never claim Xcode or the iOS Simulator run natively on Windows.** If something can't be done in Rust, use native Apple tech while keeping as much reusable logic in Rust as practical.

### Optional cross-platform companion
PWA companion for Android/Windows, sharing Rust logic through WebAssembly where appropriate. Native iOS takes priority; never compromise it for cross-platform.

## 3. Design direction — Apple-level premium (highest priority)
Minimalist, genuine Liquid Glass, clean layouts and precise spacing, premium typography, carefully chosen colors, elegant rounded components, soft depth/shadows, fluid context-aware animation, clear hierarchy, very responsive navigation, no clutter.

**Liquid Glass:** target **iOS 26+**. Use genuine Apple APIs: SwiftUI glass materials, `GlassEffectContainer`, glass-styled controls, floating glass navigation, system sheets/toolbars, morphing transitions, interactive glass buttons, context-sensitive transparency, haptics. Glass primarily for navigation and interactive controls; keep content readable. Support Reduce Motion, Reduce Transparency, Dynamic Type, VoiceOver, proper contrast.

**Inspiration (do not copy):** Apple Health, Fitness, Calendar, Reminders, Journal, modern iOS. Create an original design system.

**Navigation:** bottom tab bar with 5 destinations — Home, Timetable, Calendar, Statistics, More. Contextual access to participation, grades, goals, tasks, productivity. FABs or native contextual actions where appropriate; minimal taps.

## 4. Features
1. **Dashboard** — overall grade average, academic progress, today's timetable, upcoming exams, pending homework, weekly participation, current study goals, study-time stats, quick actions. Cards, small charts, progress indicators; adapts to day and data.
2. **Stundenplan (Timetable)** — add/edit/delete subjects; colors + icons; lesson start/end; repeating weekly schedules; multiple lessons per subject; current lesson; highlight next lesson; timetable changes and holidays; beautiful weekly view.
3. **Melde Tracker (signature)** — one-tap participation recording; auto-associate with current subject/lesson; manual subject selection; timestamps; corrections/deletion; per lesson/day/week/month; streaks and trends; clear feedback. ~1–2 taps total.
4. **Wochenziele** — weekly participation targets; per-subject goals; actual vs planned; weekly progress; motivational indicators; suggest realistic targets from history. Students may enter a target oral grade. **Clearly distinguish participation activity from teacher-assigned oral grades; never promise that N hand-raises guarantees a grade.**
5. **Notenrechner** — grades 1–6; Oberstufe points 0–15; schriftlich/mündlich; configurable subject weighting; multiple assessments; weighted averages; per-subject and overall. **Do not assume all German states/schools use identical rules** — configurable. Distinguish exact averages from rounded/officially assigned grades.
6. **Notenprognose** — "what do I need on the next exam for a 2?", "what if I get 11 points?", effect on overall average; scenarios, target selection, future weighting, multiple hypotheticals, reachable/unreachable detection, visualization. Mathematically accurate and thoroughly tested.
7. **Kalender** — day/week/month; exams, homework deadlines, school events, study sessions, custom appointments, timetable integration; native-feeling interactions and indicators.
8. **Prüfungen & PDF** — camera scan → PDF; import PDFs; in-app viewer; organize by subject/date; attach grades; notes/annotations; secure storage; cross-device sync. Prefer VisionKit/PDFKit.
9. **Todo List** — CRUD, priorities, due dates, subject links, completion, recurring, optional reminders, grouping (today/upcoming/completed).
10. **Tagesplaner** — daily/weekly study plans; sessions per subject; planned duration; workload; reschedule; track completion; integrates with calendar and tasks.
11. **Fokus Timer** — Pomodoro, Stopwatch, Countdown; custom durations; start/pause/resume/reset; background-safe **timestamp-based** timing; optional sound/haptics; subject association; auto-record study time; daily/weekly focus stats.
12. **Statistiken** — grade development, participation trends, study time per subject, weekly productivity, goal progress, monthly comparisons, history. Swift Charts, interactive, selectable periods.
13. **Meine Ziele** — target grade per subject, overall targets, participation goals, study-time goals, progress tracking, completion history, realistic insights.
14. **Themes** — Light, Dark, Purple, Blue, Green, Orange. Light/Dark follow system; colored themes keep premium look, accessibility and Liquid Glass; avoid oversaturation.
15. **Languages** — German (default), Turkish, English; user-selectable in settings; everything localized (buttons, nav, settings, notifications, empty states, errors).
16. **Cloud Sync** — Supabase; account-scoped storage; automatic; offline-first; local persistence; conflict handling; sync status; graceful network interruption. Usable without internet.
17. **Benutzerkonto** — email/password, Google, Sign in with Apple, password recovery, account settings, secure logout, account deletion. Strict per-account isolation via RLS. **Never embed service-role keys or secrets in clients.**
18. **Multiple Users** — independent accounts; separate timetables, grades, tasks, goals, documents; isolated storage; no cross-user access without an explicit authorization mechanism.
19. **PWA** — optional companion for Android, Windows, desktop browsers; reuses backend and compatible Rust logic; secondary client.
20. **Benachrichtigungen** — exams, homework, study sessions, goals, custom events; native local notifications where possible; server push only where necessary; user preferences.

## 5. Additional product requirements
**Onboarding:** welcome → language → account/login → school & grading config → subjects → timetable → academic goals → personalized dashboard. Optional steps skippable.

**Every screen:** loading, empty, validation-error, network-error and success states; undo where appropriate; smooth navigation; consistent animation. No dead buttons. No placeholder charts disguised as real data.

**Performance:** low memory, fast startup, 60/120 Hz animation, minimal network, efficient queries, responsive scrolling, battery efficiency, reliable offline. Rust for reusable testable logic, not for things Apple frameworks do better.

**Privacy & security:** privacy by design; users may be minors → GDPR; secure auth; per-user DB authorization; private file storage; minimal data collection; secure PII handling; account and data deletion; privacy disclosures.

## 6. Project structure (suggested; adjust to best practice)
```
melde-planner/
├── apps/
│   ├── ios/ {App, Features, Components, DesignSystem, Navigation, Localization, Resources}
│   └── web/
├── crates/ {melde-core, melde-grades, melde-scheduling, melde-statistics, melde-ffi}
├── supabase/ {migrations, policies, functions}
├── scripts/
├── tests/
├── .github/workflows/
└── README.md
```
Clear separation of presentation, application logic, data access, persistence.

## 7. Development phases
1. **Foundation** — architecture, repo structure, Rust workspace, iOS structure, Rust/Swift interop, Supabase, Windows→macOS build workflow, design system.
2. **Core app** — onboarding, auth, navigation, dashboard, subject management, timetable, participation tracker.
3. **Academic intelligence** — grade calculator, forecasting, weekly participation goals, academic goals, statistics.
4. **Productivity** — calendar, tasks, daily planner, focus timer, notifications.
5. **Advanced** — document scanning, PDF management, file sync, themes, localization, offline conflict resolution.
6. **Quality & release** — unit/integration tests, accessibility, performance, iPhone/iPad layouts, CI build verification, TestFlight, App Store readiness.

Build in working, verifiable increments.

## 8. Expectations for each phase
1. Brief implementation approach. 2. Files to create/modify. 3. Complete source code. 4. How to run/test from Windows 11. 5. Steps needing macOS/Apple services. 6. DB schemas and migrations. 7. Tests. 8. No dependencies without clear reason. 9. Preserve architecture across phases. 10. Track implemented vs unfinished.

**Do not invent successful build results, test outcomes, or Apple platform capabilities.** Avoid mock implementations. If a feature depends on credentials/platform access/external services, say what's needed and ship a functional, configurable implementation.

## 9. Quality bar
Design comparable to Apple's own productivity apps; maintainable, secure, tested, scalable engineering; fast and reliable; intuitive for students; all 20 feature areas implemented across phases with no misleading mocks. Priority: native iOS, authentic Liquid Glass, Rust-powered logic, Windows-first workflow.

## 10. Begin development with
1. Technical architecture & technology decision document. 2. Premium design system. 3. Navigable iPhone app shell. 4. Rust workspace + Swift interop layer. 5. First functional dashboard and timetable components. 6. Windows 11 dev setup + macOS CI build config. Then continue through the phases.