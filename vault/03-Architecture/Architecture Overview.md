---
type: architecture
status: accepted
date: 2026-10-21
updated: 2026-10-22
tags:
- architecture
- phase-1
permalink: melde-planner/03-architecture/architecture-overview
---

# Architecture Overview

Technical architecture and technology decisions for Melde Planner. Scope and quality bar: [[01-Spec/Melde Planner Spec]]. Terms: [[05-Glossary/Glossary]]. Decisions: [[02-Decisions/Decision Log]].

## System

```
┌───────────────────────── iPhone / iPad (iOS 26) ─────────────────────────┐
│ SwiftUI app (Swift 6, MainActor by default, Liquid Glass)                │
│   Features ── AppModel (@Observable) ── LocalStore (JSON in App Group,   │
│                    │        │              file protection)              │
│                    │        └── Data/: UntisClient, TeamsClient, Keychain│
│                    ▼  MeldeCore Swift package (generated bindings)       │
│              UniFFI ── MeldeFFI.xcframework (static Rust library)        │
│   MeldeWidgets extension (widgets, Control, Live Activity) ── same store │
└────────────────────┼─────────────────────────────────────────────────────┘
                     ▼                     School servers, straight from the phone:
        Rust workspace (crates/)           WebUntis (JSON-RPC, student login/SSO)
        melde-core        primitives       Microsoft Graph (Teams assignments)
        melde-grades      Notenrechner
        melde-scheduling  Stundenplan      No Meldo backend in use (ADR-0006 update).
        melde-statistics  Melde stats      supabase/ is kept in the repo but unused.
        melde-tasks       Aufgaben
        melde-untis       WebUntis parsing
        melde-ffi         UniFFI surface ──► later: wasm-bindgen for the PWA
```

## Technology decisions

| Area | Decision | Why | Trade-off |
|---|---|---|---|
| UI | SwiftUI on **iOS 26+**, native `TabView`/`Tab`, `glassEffect`, `GlassEffectContainer`, `.glass`/`.glassProminent` buttons | Genuine Liquid Glass only exists in the iOS 26 SDK | No support for iOS 18 and older |
| Glass usage | Glass for navigation and controls (tab bar, bottom accessory, weekday selector, buttons); content cards are opaque grouped surfaces | Readability; Apple HIG guidance | Less "glass everywhere" look, by design |
| Business logic | Rust crates, pure functions over plain data, no clock or time-zone access | Testable on Windows, reusable for the PWA via WASM, deterministic | FFI mapping layer to maintain |
| Interop | **UniFFI 0.32** proc-macros, library-mode bindgen pinned in `tools/uniffi-bindgen` | Mature, Mozilla-maintained, generates idiomatic Swift (`throws`, optionals, enums with payloads) | Records are copied across the boundary (fine at this data size) |
| Swift ↔ Rust packaging | Local Swift package `MeldeCore` = binary target `MeldeFFI.xcframework` + generated Swift in Swift 5 language mode | Isolates generated code from the app's Swift 6 strict concurrency; SPM links the static library correctly | Requires `scripts/build-rust-ios.sh` before opening in Xcode |
| Xcode project | **XcodeGen** `project.yml`, `.xcodeproj` generated, not committed | Editable from Windows, no pbxproj merge conflicts | One extra step on macOS (`xcodegen generate`) |
| Persistence (current) | One JSON document (`AppData`, `LocalStore`) in the App Group container (falls back to Application Support and migrates from it), coordinated atomic writes shared with the widget extension, data protection, schema version + migrations, corrupt-file backup | Small data; simplest thing that is fully correct; widgets and the Control need the same store | No cross-device sync |
| Sync | **Deferred.** Meldo is fully local per device until the owner has the paid Apple Developer Program account; then iCloud (CloudKit). See [[02-Decisions/ADR-0006 Sync with Supabase instead of iCloud|ADR-0006]] (update) | CloudKit needs the paid program; the owner decided against Supabase | Two devices don't share data yet |
| Backend | **None in use.** The Supabase schema (RLS, owner triggers, pgTAP tests) in `supabase/` stays in the repo unused; no Supabase project exists for Meldo. The Rust-SQLite/outbox plan of [[02-Decisions/ADR-0003 Offline-first persistence and sync model|ADR-0003]] is on hold with it | Keeps the option open without cost | Dead code to keep green in `core.yml` |
| School data | WebUntis ([[02-Decisions/ADR-0007 WebUntis import|ADR-0007]]) and Teams via Microsoft Graph ([[02-Decisions/ADR-0008 Teams assignments via Graph|ADR-0008]]), called directly from the phone with the student's own login; credentials/session cookies only in the Keychain; Rust (`melde-untis`) parses the responses | No Meldo server sees school data; no cost | Can break when Untis/Microsoft change things; SSO schools may need admin consent |
| Localization | String Catalog (`Localizable.xcstrings`, German source, `tr`, `en`); in-app language switch via the language's `.lproj` bundle | Spec requires changing language in-app; German default | Strings must go through `L(…)`; `scripts/check_strings.py` enforces coverage in CI |
| Tests | Rust: unit + `proptest` property tests; Swift: Swift Testing (`MeldeCore` bridge, `AppModel`, shared store, tasks/exams/migration, WebUntis merge) plus `MeldePlannerUITests`; SQL: pgTAP RLS isolation tests (for the unused schema) | Each layer tested where it runs | iOS tests run only on macOS CI |
| CI | GitHub Actions: `core.yml` (Rust on Ubuntu + Windows, pgTAP on Ubuntu), `ios.yml` (iOS build + tests on `macos-26`), `ui-review.yml` (manual, simulator screenshots), `testflight.yml` (manual) | Owner has no Mac | macOS minutes cost more; iOS job runs only when relevant paths change on PRs |

## Rules that keep the architecture honest

- **The Rust core never reads the clock or a time zone.** Swift converts `Date` to local `FfiDate`/`FfiDateTime` first (`CalendarBridge.swift`). Everything time-based is therefore reproducible in tests.
- **Grade direction goes through `GradeScale`.** No raw `<`/`>` on grade values (see glossary).
- **Exact vs rounded vs official.** `exact` is the weighted average; `rounded` applies the configured rule; neither is an official grade.
- **Participation is activity, not a grade.** The UI says so wherever counts and goals appear.
- **Validation lives in Rust.** For example, lesson overlaps are detected by `timetable_validate` before saving.

## Repository layout

```
apps/ios/                 XcodeGen project.yml; MeldePlanner app (App/, Data/, DesignSystem/, Features/, Navigation/),
                          Shared/ (models, LocalStore, App Group, L()), MeldeWidgets extension, MeldeCore package,
                          MeldePlannerTests, MeldePlannerUITests, Design/
crates/                   Rust workspace members (see diagram)
tools/uniffi-bindgen/     pinned bindings generator
supabase/                 config.toml, migrations/, tests/database/ (pgTAP) — unused, see Backend
scripts/                  build-rust-ios.sh (macOS), check_strings.py, scan-skills.sh
.github/workflows/        core.yml, ios.yml, ui-review.yml, testflight.yml
vault/                    this knowledge base
```

## Android app (ADR-0009)
`apps/android` is a native Kotlin + Jetpack Compose (Material 3) port of the iOS app for Android 16–17 (minSdk 36, target 37). It uses the same Rust core through UniFFI's Kotlin bindings (`libmelde_ffi.so` via `cargo-ndk`, built by Gradle), the same `data.json` model (`data/Models.kt` mirrors `Shared/Models.swift`) and the same String Catalog (`L()` reads it from a generated `assets/strings.json`). Platform equivalents: Glance widgets, Quick Settings tile, Android 16 Live Updates, ML Kit document scanner, Keystore, Custom Tabs, WebView SSO, WorkManager. Porting conventions: `apps/android/docs/PORTING.md`. CI: `.github/workflows/android.yml` (unit tests + APK artifact).

## PWA path (Phase 19, later)
`melde-grades`, `melde-scheduling` and `melde-statistics` depend only on `chrono` (no clock, `std` only) and compile to `wasm32-unknown-unknown`. A `melde-wasm` crate with `wasm-bindgen` will mirror `melde-ffi`. How the PWA gets the student's data is open now that there is no Supabase backend (iCloud is not reachable from a PWA without CloudKit JS). Not started.