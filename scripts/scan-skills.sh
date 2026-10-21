#!/usr/bin/env bash
# Scan every project skill (and optionally another path) with NVIDIA SkillSpector, static mode.
# Usage: scripts/scan-skills.sh [extra-skill-dir ...]
# Record notable results in vault/03-Architecture/Skill Security Scan.md.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
targets=("$root"/.claude/skills/*/ "$@")
for dir in "${targets[@]}"; do
  [ -f "$dir/SKILL.md" ] || [ -d "$dir/skills" ] || continue
  result=$(skillspector scan "$dir" --no-llm --recursive --format json 2>/dev/null || true)
  printf '%-45s %s\n' "$(basename "$dir")" "$(printf '%s' "$result" | python -I -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print("scan failed"); sys.exit()
r = d.get("risk_assessment") or {}
print(r.get("score", d.get("max_risk_score")), r.get("severity", d.get("risk_severity")))
')"
done
