# Melde Planner

Premium native iOS (SwiftUI, iOS 26 Liquid Glass) academic planner for German students, with a Rust core (UniFFI), Supabase backend, and an optional PWA companion. Developed on **Windows 11**; iOS builds run on macOS CI (GitHub Actions) or a remote Mac.

## Read first
- Spec (source of truth): `vault/01-Spec/Melde Planner Spec.md`
- Glossary — German terms and their code names: `vault/05-Glossary/Glossary.md`. Use these names; never invent alternates.
- Feature status: `vault/04-Features/Feature Index.md`
- Decisions: `vault/02-Decisions/` · Open questions: `vault/00-Inbox/Open Questions.md`

## Hard rules
- Never claim Xcode, the iOS Simulator, or an iOS build/test ran unless it actually ran (on macOS CI or a remote Mac) and you saw the output. Windows can build and test the Rust crates only.
- Never fabricate build/test results or Apple platform capabilities. Check current APIs (context7, apple skills) before using iOS 26 Liquid Glass APIs.
- Participation counts are not grades. Grade comparisons go through the scale type (1–6 lower is better, 0–15 higher is better). Grading rules are configuration, not constants.
- Never put Supabase service-role keys or other secrets in client code or the repo. Every table has RLS.
- No dependency without a stated reason. No mock data presented as real.
- German is the default locale; every user-facing string is localized (de, tr, en).

## Project memory (three layers)
1. **Obsidian vault `vault/`** — curated memory. Also the `melde-planner` project in the basic-memory MCP (search/write it there). When ambiguous, add to Open Questions instead of guessing. After finishing a piece of work, update the Feature Index status, add an ADR for architectural decisions, and append one line to `vault/06-Sessions/Session Log.md`.
2. **claude-mem** — automatic session observations (plugin, local worker on http://127.0.0.1:37777). Use `/mem-search` for "what did we do about X".
3. **graphify** — code/doc knowledge graph (rules below). Export to Obsidian with `graphify export obsidian --dir vault/07-Graph`. `vault/07-Graph/` and `graphify-out/` are generated; never hand-edit.

## Skills
Project skills live in `.claude/skills/` (Apple design, SwiftUI, Swift concurrency/testing, Rust, Supabase, web design for the PWA, graphify, skill-inspector). Plugins: Apple skills (indie-apple-stack), claude-mem, Trail of Bits security plugins, Ponytail (YAGNI mode, default `lite`; it never overrides the spec's "no mock/placeholder" quality bar).
RTK compresses Bash output through a PreToolUse hook (`rtk hook claude`); see the rtk section below.
**Before adding any new skill or plugin, scan it:** `skillspector scan <path> --no-llm` and record the result in `vault/03-Architecture/Skill Security Scan.md`.

## Commands (Windows)
- Rust: `cargo test --workspace` (needs rustup; not installed yet)
- Graph: `graphify update .` after code changes
- Memory worker: `npx claude-mem start` / `npx claude-mem doctor`

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- When graphify-out/graph.json exists, run `graphify query "<question>"` before your first grep, search or source-file read for a codebase question, and put this rule in every subagent prompt that explores code. Read raw files only for lines the graph or an earlier read already located. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
- A committed graphify-out/graph.json is rewritten whole on every build, so a large diff to it in a pull request is expected. Do not flag it as churn or suggest skipping the graph rebuild or its hooks.

<!-- rtk-instructions v2 -->
# Command output

Command output here is condensed to save tokens, keeping every signal and
dropping costly noise. Treat it as the complete result: run commands
normally, and batch related commands into one call to avoid extra turns.
Truncated results state their recovery path in their own output. Re-run a
command as `rtk bypass <cmd>` only when its result is unusable: empty when
output was clearly expected, contradicting its exit code, or garbled.
<!-- /rtk-instructions -->