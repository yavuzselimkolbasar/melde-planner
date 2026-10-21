---
type: adr
status: accepted
date: 2026-10-21
tags:
- adr
- tooling
permalink: melde-planner/02-decisions/adr-0001-ai-tooling-and-project-memory
---

# ADR-0001 — AI tooling, skills and project memory

## Context
The app is built with heavy Claude Code assistance from Windows 11. Context must survive across sessions, terminology is German-specific, and third-party skills run with agent trust.

## Decision
- **Memory, three layers:**
  1. This Obsidian vault (`vault/`) — curated, human-readable decisions, spec, glossary, feature status. Also registered as a `basic-memory` MCP project so Claude can search/write it.
  2. **claude-mem** plugin — automatic per-session observation capture and context injection (local worker, provider = Claude plan, cloud sync off).
  3. **graphify** — code/document knowledge graph in `graphify-out/`, exported into `vault/07-Graph` for Obsidian.
- **Skills** live in `.claude/skills/` (project-scoped, committed). Large plugin collections (Apple skills, Trail of Bits) are enabled via `.claude/settings.json` marketplaces.
- **Every skill/plugin is scanned with NVIDIA SkillSpector before use**; results in [[03-Architecture/Skill Security Scan]].
- rust-skills installed in *skills-only* mode (its plugin hook fires on almost every prompt).

## Consequences
- New skills must be scanned before being added.
- `graphify-out/` and `vault/07-Graph` are generated; never hand-edited.