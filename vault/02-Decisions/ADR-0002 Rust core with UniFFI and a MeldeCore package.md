---
type: adr
status: accepted
date: 2026-10-21
tags:
- adr
- rust
- ffi
permalink: melde-planner/02-decisions/adr-0002-rust-core-with-uni-ffi-and-a-melde-core-package
---

# ADR-0002: Rust core via UniFFI, packaged as the MeldeCore Swift package

## Context
The spec puts grades, forecasting, scheduling, statistics, validation and sync in Rust, and the UI in SwiftUI. The owner works on Windows.

## Decision
- Pure Rust crates (`melde-core`, `melde-grades`, `melde-scheduling`, `melde-statistics`) without FFI types, a clock or time zones.
- `melde-ffi` exposes plain records through UniFFI 0.32 proc-macros. A pinned `tools/uniffi-bindgen` generates the Swift bindings in library mode.
- The iOS app consumes a local Swift package `MeldeCore`: a binary target `MeldeFFI.xcframework` (static library for device + fat simulator) plus the generated Swift, compiled in Swift 5 mode. The app builds in Swift 6 with MainActor default isolation.

## Alternatives considered
- *cbindgen + hand-written Swift wrappers*: more code and unsafe pointer handling for every type.
- *swift-bridge*: smaller community; less mature enum/error support.
- *Generated Swift compiled into the app target*: generated globals conflict with Swift 6 MainActor default isolation.

## Consequences
- All business logic is unit- and property-tested on Windows (`cargo test`).
- Every API change needs matching record types in `melde-ffi`.
- `scripts/build-rust-ios.sh` must run before Xcode can build (CI does this).