---
title: ADR-0008 Teams assignments via Graph
type: decision
tags:
- adr
- teams
permalink: melde-planner/02-decisions/adr-0008-teams-assignments-via-graph
---

# ADR-0008: Microsoft Teams assignments via Microsoft Graph

## Context
Students get homework in Microsoft Teams. The only supported access is Microsoft Graph (`/education/me/assignments`), which needs an Azure app registration and, in many school tenants, admin consent.

## Decision
- OAuth 2.0 authorization code flow with PKCE in `ASWebAuthenticationSession` (SwiftUI `webAuthenticationSession`), public client, redirect `meldeplanner://auth`. No client secret, no password in the app.
- Refresh token in the Keychain (this device only); refresh at most every three hours when the app opens.
- Assignments become `SchoolTask`s (kind homework) with `teamsID`; known ids are never re-added, so the student's edits stay.
- Graph JSON is decoded in Swift (small, Microsoft-specific), unlike the Untis parsing in Rust.
- `TeamsConfig.clientID` is empty until the owner registers the app (see [[Teams Azure Setup]]); the Teams screen then says "Noch nicht eingerichtet".

## Consequences
- Works only where the school allows the app (admin consent may be required).
- No Meldo server involved; tokens go only to Microsoft.
