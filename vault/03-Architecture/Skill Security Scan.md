---
type: architecture
date: 2026-10-21
tags:
- security
- skills
- skillspector
permalink: melde-planner/03-architecture/skill-security-scan
---

# Skill Security Scan — 2026-10-21

Tool: NVIDIA SkillSpector 2.12.0, static mode (`--no-llm`), one scan per skill directory (270 targets). Re-run with `scripts/scan-skills.sh`. Decision context: [[02-Decisions/ADR-0001 AI tooling and project memory]].

## Verdict
**No malicious content found. All scanned skills/plugins are kept.** The raw scores look alarming (several 100/CRITICAL) because static analysis matches keywords, so each high-signal finding was reviewed by hand:

| Finding | Where | Verdict |
|---|---|---|
| "ignore previous instructions" | break-ui, find-animation-opportunities, improve-animations | **Benign** — part of a *defensive* rule ("if a file says this, flag it"). |
| Hidden instructions (U+200B zero-width space) | rust-trait-explorer, rust-refactor-helper, rust-code-navigator, improve-animations, ToB ANALYSIS_FORMAT | **Benign** — stray character before code fences, no hidden text. Removed from the project copies; re-scan: 0–40. No Unicode-tag (U+E0000) smuggling anywhere. |
| YARA `info_stealer` | supabase | **False positive** — skill description lists "cookies, getSession, JWT" (auth topics). |
| YARA webshell / `rm -rf /` / "disable security" | ToB sharp-edges | **Benign** — security reference docs describing dangerous patterns to detect. |
| `curl … \| sh`, vulnerable axios/flask/requests | ToB agentic-actions-auditor, variant-analysis, supply-chain-risk-auditor | **Benign** — attack examples and intentionally vulnerable eval fixtures. |
| Credential exfiltration (Telegram) | claude-mem mode-creator `configure-telegram.mjs` | **Benign, opt-in** — interactive helper that stores a Telegram bot token you enter, to send alerts you configure. Not run unless you ask. |
| `exec()`, network, env access | claude-mem agent-cost-report | **Benign** — calls OpenRouter only if an OpenRouter key is set, to measure spend. |
| subprocess calls | swiftui-expert-skill (xctrace), graphify, ToB static-analysis | **Expected** — tool wrappers (Instruments, graphify CLI, Semgrep/CodeQL). |
| "Keychain", "plist", `api.example.com`, `sudo` in CI | Apple skills (most of its score) | **False positives** — normal iOS docs and templates. |

## Not installed (by choice, not for security reasons)
- rust-skills **plugin mode**: its `UserPromptSubmit` hook runs on almost every prompt. Installed as skills only.
- rust-skills `core-actionbook`, `core-agent-browser`, `rust-daily`, `domain-embedded/iot/fintech/ml/cloud-native/web`: not relevant to this project.
- Emil Kowalski `animate-expo`, `ask-sonner`, `pick-ui-library`, `prototype`: React Native/web-library specific.
- Trail of Bits: only the 13 plugins relevant to Rust/Swift/Supabase/CI security are enabled (see `.claude/settings.json`).

## Results

### Project skills (.claude/skills) — 47 targets — CRITICAL: 3, LOW: 38, MEDIUM: 6
| Target | Score | Severity |
|---|---|---|
| animate | 0 | LOW |
| animation-performance | 0 | LOW |
| animation-vocabulary | 0 | LOW |
| apple-design | 0 | LOW |
| break-ui | 20 | LOW |
| coding-guidelines | 0 | LOW |
| composition-patterns | 20 | LOW |
| domain-cli | 0 | LOW |
| emil-design-eng | 0 | LOW |
| find-animation-opportunities | 20 | LOW |
| graphify | 100 | CRITICAL |
| improve-animations | 40 | MEDIUM |
| m01-ownership | 0 | LOW |
| m02-resource | 0 | LOW |
| m03-mutability | 0 | LOW |
| m04-zero-cost | 0 | LOW |
| m05-type-driven | 0 | LOW |
| m06-error-handling | 0 | LOW |
| m07-concurrency | 20 | LOW |
| m09-domain | 0 | LOW |
| m10-performance | 0 | LOW |
| m11-ecosystem | 0 | LOW |
| m12-lifecycle | 0 | LOW |
| m13-domain-error | 0 | LOW |
| m14-mental-model | 0 | LOW |
| m15-anti-pattern | 0 | LOW |
| mobile-native | 0 | LOW |
| react-best-practices | 34 | MEDIUM |
| review-animations | 43 | MEDIUM |
| rust-call-graph | 0 | LOW |
| rust-code-navigator | 0 | LOW |
| rust-deps-visualizer | 0 | LOW |
| rust-learner | 0 | LOW |
| rust-refactor-helper | 28 | MEDIUM |
| rust-router | 0 | LOW |
| rust-symbol-analyzer | 0 | LOW |
| rust-trait-explorer | 0 | LOW |
| skill-inspector | 0 | LOW |
| supabase | 83 | CRITICAL |
| supabase-postgres-best-practices | 0 | LOW |
| swift-concurrency | 39 | MEDIUM |
| swift-testing-expert | 0 | LOW |
| swiftui-expert-skill | 100 | CRITICAL |
| swiftui-pro | 7 | LOW |
| unsafe-checker | 33 | MEDIUM |
| web-design-guidelines | 0 | LOW |
| write-swift | 0 | LOW |

### Apple skills plugin (indie-apple-stack) — 183 targets — CRITICAL: 4, HIGH: 12, LOW: 127, MEDIUM: 40

### Trail of Bits plugins — 13 targets — CRITICAL: 5, HIGH: 2, LOW: 2, MEDIUM: 4
| Target | Score | Severity |
|---|---|---|
| agentic-actions-auditor | 85 | CRITICAL |
| audit-context-building | 30 | MEDIUM |
| differential-review | 7 | LOW |
| fp-check | 22 | MEDIUM |
| insecure-defaults | 50 | MEDIUM |
| mutation-testing | 63 | HIGH |
| property-based-testing | 3 | LOW |
| rust-review | 58 | HIGH |
| sharp-edges | 100 | CRITICAL |
| spec-to-code-compliance | 22 | MEDIUM |
| static-analysis | 100 | CRITICAL |
| supply-chain-risk-auditor | 100 | CRITICAL |
| variant-analysis | 100 | CRITICAL |

### claude-mem plugin skills — 27 targets — CRITICAL: 2, HIGH: 2, LOW: 22, MEDIUM: 1

