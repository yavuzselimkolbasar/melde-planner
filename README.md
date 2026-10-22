# Melde Planner

A premium native iOS academic planner for students at German schools. It tracks classroom participation (Melden), timetables, grades and forecasts, goals and study time.

- **App:** SwiftUI on iOS 26 with Liquid Glass: [`apps/ios`](apps/ios)
- **Logic:** Rust core exposed to Swift through UniFFI: [`crates/`](crates)
- **Backend:** Supabase (Postgres with row-level security, Auth, Storage): [`supabase/`](supabase)
- **Docs and memory:** Obsidian vault: [`vault/Home.md`](vault/Home.md). Start with the [spec](vault/01-Spec/Melde%20Planner%20Spec.md), the [architecture](vault/03-Architecture/Architecture%20Overview.md) and the [Windows → macOS workflow](vault/03-Architecture/Windows%20Dev%20Workflow.md).

## Quick start (Windows 11)

```bash
cargo test --workspace
```

```bash
cargo clippy --workspace --all-targets -- -D warnings
```

```bash
python -I scripts/check_strings.py
```

The iOS app builds only on macOS. CI does that: [`.github/workflows/ios.yml`](.github/workflows/ios.yml). On a Mac:

```bash
bash scripts/setup-mac.sh
```

It checks Xcode 26, Homebrew, XcodeGen and Rust, builds the Rust core for iOS, generates the Xcode project and opens it. Re-run it after pulling changes.

## Status
Phase 1 (foundation) is in progress. See the [feature index](vault/04-Features/Feature%20Index.md) for what is implemented, verified or missing.
