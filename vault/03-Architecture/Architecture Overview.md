---
type: architecture
status: draft
tags:
- architecture
permalink: melde-planner/03-architecture/architecture-overview
---

# Architecture Overview

Draft — to be replaced by the Phase 1 architecture decision document.

```
SwiftUI (iOS 26, Liquid Glass) ──UniFFI──► Rust core (melde-core, -grades, -scheduling, -statistics, -ffi)
        │                                         │
        └── local store (offline-first) ◄── sync logic (Rust) ──► Supabase (Postgres + RLS, Auth, Storage)
PWA (secondary) ──wasm-bindgen──► same Rust crates
```

Builds: code on Windows 11 → push to GitHub → macOS runner (Xcode) builds/tests → TestFlight.
See [[01-Spec/Melde Planner Spec]] §2 and §6.