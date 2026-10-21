---
type: architecture
status: accepted
date: 2026-10-21
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
│   Features ── AppModel (@Observable) ── LocalStore (JSON, file protection)│
│                    │                                                     │
│                    ▼  MeldeCore Swift package (generated bindings)       │
│              UniFFI ── MeldeFFI.xcframework (static Rust library)        │
└────────────────────┼─────────────────────────────────────────────────────┘
                     ▼
        Rust workspace (crates/)          Supabase (Phase 2+)
        melde-core        primitives      Postgres + RLS, Auth, Storage
        melde-grades      Notenrechner    supabase/migrations
        melde-scheduling  Stundenplan     supabase/tests (pgTAP)
        melde-statistics  Melde stats
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
| Persistence (Phase 1) | One JSON document in Application Support, atomic writes, data protection, schema version, corrupt-file backup | Small data; simplest thing that is fully correct | Replaced in Phase 2 (below) |
| Persistence (Phase 2) | Rust-owned SQLite (`rusqlite`, bundled) with an outbox for sync | Spec puts offline data management and sync in Rust | Needs a C compiler on Windows (WinLibs installed) |
| Sync model | Client-generated UUIDs, `updated_at` last-writer-wins, `deleted_at` tombstones, pull by `(user_id, updated_at)` index | Offline-first with simple, explainable conflict handling | Concurrent edits of the same field resolve by time; acceptable for single-user data |
| Backend | Supabase Postgres 17 + RLS on every table, owner triggers on foreign keys, private `documents` bucket with per-user folders | Strict per-student isolation (spec §17–18), GDPR | Service-role work (account deletion) needs an Edge Function |
| Localization | String Catalog (`Localizable.xcstrings`, German source, `tr`, `en`); in-app language switch via the language's `.lproj` bundle | Spec requires changing language in-app; German default | Strings must go through `L(…)`; `scripts/check_strings.py` enforces coverage in CI |
| Tests | Rust: unit + `proptest` property tests; Swift: Swift Testing (`MeldeCore` bridge tests, `AppModel` tests); SQL: pgTAP RLS isolation tests | Each layer tested where it runs | iOS tests run only on macOS CI |
| CI | GitHub Actions: Rust on Ubuntu + Windows, Supabase pgTAP on Ubuntu, iOS build + tests on `macos-26` (Xcode 26.6), manual TestFlight workflow | Owner has no Mac | macOS minutes cost more; iOS job runs only when relevant paths change on PRs |

## Rules that keep the architecture honest

- **The Rust core never reads the clock or a time zone.** Swift converts `Date` to local `FfiDate`/`FfiDateTime` first (`CalendarBridge.swift`). Everything time-based is therefore reproducible in tests.
- **Grade direction goes through `GradeScale`.** No raw `<`/`>` on grade values (see glossary).
- **Exact vs rounded vs official.** `exact` is the weighted average; `rounded` applies the configured rule; neither is an official grade.
- **Participation is activity, not a grade.** The UI says so wherever counts and goals appear.
- **Validation lives in Rust.** For example, lesson overlaps are detected by `timetable_validate` before saving.

## Repository layout

```
apps/ios/                 XcodeGen project.yml, MeldePlanner app, MeldePlannerTests, MeldeCore package
crates/                   Rust workspace members (see diagram)
tools/uniffi-bindgen/     pinned bindings generator
supabase/                 config.toml, migrations/, tests/database/ (pgTAP)
scripts/                  build-rust-ios.sh (macOS), check_strings.py, scan-skills.sh
.github/workflows/        core.yml, ios.yml, testflight.yml
vault/                    this knowledge base
```

## PWA path (Phase 19, later)
`melde-grades`, `melde-scheduling` and `melde-statistics` depend only on `chrono` (no clock, `std` only) and compile to `wasm32-unknown-unknown`. A `melde-wasm` crate with `wasm-bindgen` will mirror `melde-ffi`; the PWA talks to the same Supabase project with the same RLS. Not started.