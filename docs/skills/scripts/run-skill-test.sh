#!/usr/bin/env bash
# Run ONE real headless test of a skill and write evidence.
# Usage: run-skill-test.sh <expected-skill> <prompt> [fixture-dir]
#   - Creates a fresh work dir under $SKILL_TEST_BASE (default: /tmp/skill-tests).
#   - Copies ALL skills from .claude/skills (so the model must pick the right one).
#   - Copies the fixture dir content (sample files for the prompt) if given.
#   - Runs `claude -p` with stream-json and saves the raw stream + a summary.
# Exit 0 if the Skill tool was called with <expected-skill>, else 1.
set -euo pipefail
skill="$1"; prompt="$2"; fixture="${3:-}"
repo="$(cd "$(dirname "$0")/../../.." && pwd)"
base="${SKILL_TEST_BASE:-/tmp/skill-tests}"
work="$base/$skill-$(date +%s)"
mkdir -p "$work/.claude"
cp -r "$repo/.claude/skills" "$work/.claude/skills"
if [[ -n "$fixture" ]]; then cp -r "$fixture"/. "$work/"; fi
cd "$work"
git init -q . 2>/dev/null || true
timeout "${SKILL_TEST_TIMEOUT:-900}" claude -p "$prompt" --output-format stream-json --verbose \
  --allowedTools "Bash,Read,Edit,Write,Grep,Glob,Skill" > stream.jsonl 2> stderr.txt || true
echo "WORK=$work"
python3 - "$skill" stream.jsonl <<'PY'
import json, sys
skill, path = sys.argv[1], sys.argv[2]
calls, tools, result = [], [], None
for line in open(path, encoding="utf-8"):
    try:
        ev = json.loads(line)
    except json.JSONDecodeError:
        continue
    if ev.get("type") == "assistant":
        for c in ev["message"].get("content", []):
            if c.get("type") == "tool_use":
                tools.append(c["name"])
                if c["name"] == "Skill":
                    calls.append(c.get("input", {}))
    if ev.get("type") == "result":
        result = ev
print("SKILL_CALLS=" + json.dumps(calls, ensure_ascii=False))
print("TOOLS=" + ",".join(tools))
if result:
    print(f"RESULT_SUBTYPE={result.get('subtype')} TURNS={result.get('num_turns')} "
          f"DURATION_MS={result.get('duration_ms')}")
ok = any(c.get("skill", "").split(":")[-1] == skill for c in calls)
print("TRIGGERED=" + ("yes" if ok else "no"))
sys.exit(0 if ok else 1)
PY
