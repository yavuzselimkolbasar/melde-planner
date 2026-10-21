---
type: adr
status: accepted
date: 2026-10-21
tags:
- adr
- sync
- supabase
permalink: melde-planner/02-decisions/adr-0003-offline-first-persistence-and-sync-model
---

# ADR-0003: Offline-first persistence and sync model

## Decision
- Phase 1: one JSON document on device (atomic writes, iOS data protection, schema version, unreadable files are backed up and never overwritten).
- Phase 2: Rust-owned SQLite store with an outbox; Supabase sync pulls rows changed since the last `updated_at` per table.
- Rows use client-generated UUIDs; conflicts resolve last-writer-wins on `updated_at`; deletions are `deleted_at` tombstones.
- Server: RLS owner-only policies on every table using `(select auth.uid())`, plus triggers that reject foreign keys pointing at another user's rows. Storage bucket `documents` is private with `<user id>/…` paths.

## Consequences
- The app works fully without network or an account.
- Last-writer-wins can drop a concurrent edit on two devices. That is acceptable for single-student data, and it is surfaced in the sync status UI (Phase 5).
- UUIDv4 primary keys fragment indexes slightly; this is negligible at per-student data volumes and can move to UUIDv7 later.