#!/usr/bin/env bash
# Run ONE real headless test of a skill and write evidence.
# Usage: run-skill-test.sh <expected-skill> <prompt> [fixture-dir]
#   - Creates a fresh work dir under $SKILL_TEST_BASE (default: /tmp/skill-tests).
#   - Copies ALL skills from .claude/skills (so the model must pick the right one).
#   - Copies the fixture dir content (sample files for the prompt) if given.
#   - Runs `claude -p` with stream-json (prompt right after -p: --allowedTools is variadic).
#   - Writes docs/skills/test-results/<skill>.md (evidence) and keeps the raw stream in the work dir.
# Exit 0 if the Skill tool was called with exactly <expected-skill>, else 1.
set -euo pipefail
skill="$1"; prompt="$2"; fixture="${3:-}"
repo="$(cd "$(dirname "$0")/../../.." && pwd)"
base="${SKILL_TEST_BASE:-/tmp/skill-tests}"
work="$base/$skill-$(date +%s)"
mkdir -p "$work/.claude" "$repo/docs/skills/test-results"
cp -r "$repo/.claude/skills" "$work/.claude/skills"
if [[ -n "$fixture" ]]; then cp -r "$fixture"/. "$work/"; fi
cd "$work"
git init -q . && git add -A && git -c user.email=t@t -c user.name=t commit -qm fixture
start=$(date -u +%Y-%m-%dT%H:%M:%SZ)
timeout "${SKILL_TEST_TIMEOUT:-900}" claude -p "$prompt" --output-format stream-json --verbose \
  --allowedTools "Bash,Read,Edit,Write,Grep,Glob,Skill" > stream.jsonl 2> stderr.txt || true
echo "WORK=$work"
git status --porcelain --untracked-files=all -- . ':!stream.jsonl' ':!stderr.txt' > changed.txt || true
python3 "$repo/docs/skills/scripts/write-evidence.py" "$work" "$skill" "$prompt" "$start" \
  "$repo/docs/skills/test-results/$skill.md" "$fixture"
