---
type: adr
status: accepted
date: 2026-10-21
tags:
- adr
- sync
permalink: melde-planner/02-decisions/adr-0006-sync-with-supabase-instead-of-i-cloud
---

# ADR-0006: Sync with Supabase, not iCloud

## Context
The owner sideloads with a free Apple ID. Apple's capability table (checked 2026-10-21) lists iCloud (CloudKit, documents, key-value), push notifications and Sign in with Apple as **paid-program only**. App Groups are available to free accounts.

## Decision
Device sync uses the existing Supabase backend (free tier) with email login. iCloud is not used.

## Consequences
- Sync works on free sideloaded builds, and later for the iPad and the PWA.
- Needs an account (email + password or magic link). Sign in with Apple only once there is a paid account.
- Remote push isn't possible on the free account; all reminders are local notifications.