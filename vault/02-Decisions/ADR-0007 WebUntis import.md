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

## Update 2026-10-21: school login (SSO) and search
- Schools that sign in through Microsoft 365, IServ or another page have no WebUntis password. Meldo shows the school's real WebUntis login page in a WebKit view; the student signs in there. Meldo reads only the WebUntis session cookies for that server, asks `GET /WebUntis/api/app/config` for the logged-in person (`loginServiceConfig.user.personId`, person `type`), then calls `getTimetable` with that session. This mirrors the open-source `webuntis` npm library. The cookies, not a password, go to the Keychain; when the session runs out the student signs in again (the Microsoft sign-in is usually remembered).
- The school search (`schoolquery2`) answers `-6003 "too many results"` for broad queries such as "Köln" (verified live). That is shown as a calm hint, not an error code.
- Not verified with a real SSO account yet: needs a student of an SSO school to try it.
- Import window: eight weeks in one `getTimetable` request. The weekly timetable starts at the first week with regular lessons (`first_teaching_week`), so holidays at the start don't empty it; changes come from all eight weeks. An import with no lessons never replaces the timetable.
- Holidays come from `getHolidays` and are shown on Start, as a Stundenplan banner, in the Kalender and under Mehr → Ferien. Imported holidays are marked `fromUntis` and replaced on each import.

