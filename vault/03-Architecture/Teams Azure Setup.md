---
title: Teams Azure Setup
type: guide
tags:
- teams
- azure
permalink: melde-planner/03-architecture/teams-azure-setup
---

# Microsoft Teams: Azure app registration

Meldo reads Teams assignments through Microsoft Graph (ADR-0008). Microsoft only allows that for a registered app. The registration is free. The app (client) ID is not secret; it goes into `apps/ios/MeldePlanner/Data/TeamsClient.swift` → `TeamsConfig.clientID`.

## Steps (about 10 minutes)

1. Open https://portal.azure.com and sign in with a Microsoft account (a private one works).
2. Search for **Microsoft Entra ID** → **App registrations** → **New registration**.
3. Fill in:
   - **Name:** `Meldo`
   - **Supported account types:** *Accounts in any organizational directory (Any Microsoft Entra ID tenant – Multitenant)*. School accounts live in the school's own tenant.
   - **Redirect URI:** platform *Public client/native (mobile & desktop)*, value `meldeplanner://auth`
4. Click **Register**. Copy the **Application (client) ID** from the overview (format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).
5. **Authentication** → *Advanced settings* → **Allow public client flows: Yes** → Save.
6. **API permissions** → **Add a permission** → **Microsoft Graph** → **Delegated permissions**, then add:
   - `User.Read`
   - `offline_access`
   - `EduAssignments.ReadBasic`
   - `EduRoster.ReadBasic`
7. Send the client ID; it goes into `TeamsConfig.clientID` and the next build has Teams.

## School approval

Microsoft blocks students from approving apps from unverified publishers in many school tenants. Then the sign-in says *"Need admin approval"*. In that case the school's IT has to grant consent once for the whole school (Entra admin center → Enterprise applications → Meldo → Permissions → *Grant admin consent*). Nothing in the app can bypass this.
