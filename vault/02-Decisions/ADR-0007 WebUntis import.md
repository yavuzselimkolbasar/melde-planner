---
type: adr
status: accepted
date: 2026-10-21
tags:
- adr
- integration
- webuntis
permalink: melde-planner/02-decisions/adr-0007-web-untis-import
---

# ADR-0007: Optional WebUntis import

## Context
Many German schools use WebUntis. It has no free public partner API; the JSON-RPC API that apps use is not publicly documented, is read-only, has rate limits (about 10/s, 1800/h reported) and needs the student's own account. Some schools restrict it.

## Decision
An optional import that the student turns on, using their own WebUntis login, talking directly from the phone to the school's WebUntis server. Credentials live only in the Keychain. Imported lessons and changes are read-only copies; manual entry keeps working.

## Consequences
- No cost for the owner. Risk: it may break if Untis changes the API or a school blocks access, so the UI must fail clearly and keep local data.
- No Untis data goes through our servers.