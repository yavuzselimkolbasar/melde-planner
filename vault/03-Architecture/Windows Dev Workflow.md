---
type: architecture
date: 2026-10-21
tags:
- workflow
- windows
- ci
- apple
permalink: melde-planner/03-architecture/windows-dev-workflow
---

# Windows 11 → macOS build workflow

Xcode and the iOS Simulator **do not run on Windows**. Everything that needs them runs on GitHub Actions `macos-26` runners (or a rented Mac). Everything else runs locally.

## What runs where

| Task | Windows 11 (local) | macOS (CI / remote Mac) |
|---|---|---|
| Edit Rust, Swift, SQL, YAML | ✅ VS Code | ✅ |
| `cargo test` / `clippy` / `fmt` (all business logic) | ✅ | ✅ |
| Generate Swift bindings (`uniffi-bindgen … --language swift`) | ✅ (for inspection) | ✅ |
| Build XCFramework, compile Swift, run iOS tests | ❌ | ✅ `ios.yml` |
| Supabase pgTAP tests (schema unused, ADR-0006) | ✅ with Docker Desktop | ✅ `core.yml` (Ubuntu) |
| UI screenshots (iPhone + iPad) | ❌ | ✅ `ui-review.yml` (manual) |
| TestFlight upload | ❌ | ✅ `testflight.yml` (manual) |
| Interactive Simulator / UI review | ❌ | Rented Mac (see below) or TestFlight on a real iPhone |

## Local toolchain (installed 2026-10-21)
- Rust 1.99.1, toolchain `stable-x86_64-pc-windows-gnu` (rustup, minimal profile + clippy + rustfmt)
- WinLibs MinGW-w64 (GCC 16, binutils): supplies `dlltool`/`gcc` for the GNU toolchain. Installed via winget, user scope.
- Supabase CLI 2.121.0 in `%LOCALAPPDATA%\Programs\supabase` (checksum verified against the GitHub release digest)
- Node 24, Python 3.13, uv, git, gh

After opening a **new** terminal (PATH changes): 

```bash
cargo test --workspace
cargo clippy --workspace --all-targets -- -D warnings
python -I scripts/check_strings.py
```

## Daily loop
1. Write Rust logic + tests → `cargo test` locally.
2. Write Swift UI against the generated API (inspect it with `cargo run -p uniffi-bindgen -- generate --library target/debug/melde_ffi.dll --language swift --out-dir <tmp>`).
3. Push a branch → `ios.yml` builds the XCFramework, generates the Xcode project, builds the app and runs both Swift test suites on an iPhone simulator. Failing runs upload `.xcresult` bundles as artifacts.
4. Merge → `testflight.yml` (manual) → install via TestFlight on your iPhone.

## One-time Apple setup (needs your accounts; Claude cannot do these)
1. **Apple Developer Program** membership (99 USD/year), as an individual or organization. Note your **Team ID**.
2. **App ID / bundle id** `app.meldeplanner.ios` (change `bundleIdPrefix` in `apps/ios/project.yml` if you prefer another domain you control).
3. **App Store Connect app record** for that bundle id (name "Melde Planner", primary language German).
4. **App Store Connect API key** (Users and Access → Integrations) with the *Admin* role so CI can create signing certificates and profiles (cloud-managed signing). Download the `.p8` once.
5. GitHub repository secrets (Settings → Secrets → Actions, environment `testflight`):
   - `APPLE_TEAM_ID`, `ASC_KEY_ID`, `ASC_ISSUER_ID`
   - `ASC_PRIVATE_KEY_BASE64`: run `base64 -w0 AuthKey_XXXX.p8` in Git Bash.
6. iCloud sync (planned once the paid account exists, see ADR-0006 update) needs an iCloud container and the CloudKit capability on the App ID. There is no Supabase Auth or account sign-in.

## Interactive macOS when needed
GitHub runners cannot show a live Simulator. For design review sessions, rent a Mac by the hour (e.g. MacinCloud, AWS EC2 Mac, Scaleway Mac mini), `git clone`, then run `scripts/build-rust-ios.sh && cd apps/ios && xcodegen generate && open MeldePlanner.xcodeproj`.

## Status (checked 2026-10-22 with `gh run list`)
- Remote: `github.com/yavuzselimkolbasar/melde-planner` (`origin`).
- ✅ `core.yml` green on `fc22606` (2026-10-21): 77 Rust tests pass on Ubuntu and Windows.
- ✅ `ios.yml` green on `fc22606`: XCFramework, app and widget extension build on `macos-26`; the Swift Testing suites "Rust core through UniFFI", "AppModel", "Shared store, engine and check-ins", "Tasks, exams and data migration" and "WebUntis import merge" pass on the simulator.
- ✅ `ui-review.yml` (manual) has run green (last on `2169b1d`); it exports simulator screenshots from `MeldePlannerUITests` for iPhone and iPad as the `ui-review-screens` artifact.
- ⏳ `testflight.yml` has never run (needs the paid Apple Developer account and the secrets above).
- ⏳ Not yet tried on a real device with a real WebUntis/SSO or Teams account.