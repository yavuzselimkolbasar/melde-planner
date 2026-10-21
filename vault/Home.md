---
type: moc
tags:
- home
permalink: melde-planner/home
---

# Melde Planner — Project Brain

Shared memory for the owner **and** Claude. Plain Markdown with `[[wikilinks]]`, so both Obsidian and Claude read it directly.

## Start here
- [[01-Spec/Melde Planner Spec|Spec]] — source of truth for scope and quality bar
- [[05-Glossary/Glossary|Glossary]] — German school terms and project vocabulary (read before naming anything)
- [[04-Features/Feature Index|Feature Index]] — 20 feature areas with status
- [[03-Architecture/Architecture Overview|Architecture Overview]]
- [[02-Decisions/Decision Log|Decision Log]] — ADRs, newest first
- [[00-Inbox/Open Questions|Open Questions]] — ambiguities waiting on the owner
- [[06-Sessions/Session Log|Session Log]] — what each working session did

## Generated (do not hand-edit)
- `07-Graph/` — graphify export of the code/doc knowledge graph (one note per node + `graph.canvas`). Rebuilt by graphify; edits are overwritten.

## Conventions
- One idea per note, linked with `[[...]]`. Frontmatter `type:` is one of `spec | feature | adr | architecture | glossary | session | question | moc`.
- Feature notes track **Implemented / Not yet / Blocked on** honestly — never mark something done that wasn't built and verified.
- Decisions that change architecture get an ADR from `Templates/ADR.md`.
- Ambiguity goes to Open Questions instead of being guessed.