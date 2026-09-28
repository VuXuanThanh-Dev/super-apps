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
mkdir -p "$work/.claude"
cp -r "$repo/.claude/skills" "$work/.claude/skills"
if [[ -n "$fixture" ]]; then cp -r "$fixture"/. "$work/"; fi
cd "$work"
git init -q . && git add -A && git -c user.email=t@t -c user.name=t commit -qm fixture
start=$(date -u +%Y-%m-%dT%H:%M:%SZ)
timeout "${SKILL_TEST_TIMEOUT:-900}" claude -p "$prompt" --output-format stream-json --verbose \
  --allowedTools "Bash,Read,Edit,Write,Grep,Glob,Skill" > stream.jsonl 2> stderr.txt || true
echo "WORK=$work"
git status --porcelain --untracked-files=all -- . ':!stream.jsonl' ':!stderr.txt' > changed.txt || true
python3 - "$skill" "$prompt" "$start" "$repo/docs/skills/test-results/$skill.md" "$fixture" <<'PY'
import json, sys
skill, prompt, start, out, fixture = sys.argv[1:6]
calls, tools, result, init = [], [], None, {}
for line in open("stream.jsonl", encoding="utf-8"):
    try:
        ev = json.loads(line)
    except json.JSONDecodeError:
        continue
    if ev.get("type") == "system" and ev.get("subtype") == "init":
        init = ev
    if ev.get("type") == "assistant":
        for c in ev["message"].get("content", []):
            if c.get("type") == "tool_use":
                tools.append(c["name"])
                if c["name"] == "Skill":
                    calls.append({"id": c.get("id"), "input": c.get("input", {})})
    if ev.get("type") == "result":
        result = ev
# exact match: a plugin/user skill such as "anthropic-skills:x" does NOT count as project skill "x"
ok = any(c["input"].get("skill", "") == skill for c in calls)
changed = [l.rstrip() for l in open("changed.txt", encoding="utf-8") if l.strip()]
project_skills = [s for s in init.get("skills", []) if ":" not in s]
text = (result or {}).get("result", "") or ""
if len(text) > 6000:
    text = text[:6000] + "\n\n[... truncated, full text in stream.jsonl ...]"
md = f"""# Test result — `{skill}`

- Kết quả: **{"PASS — Skill tool triggered" if ok else "FAIL — expected skill not triggered"}**
- Loại test: **real** (headless CLI `claude -p`, stream-json), chạy lúc {start}
- CLI: `{init.get("claude_code_version", "?")}` · thư mục test mới, có đủ {len(project_skills)} skill của repo
  (`{", ".join(sorted(project_skills))}`) + skill có sẵn của môi trường
- Fixture: `{fixture.split("docs/skills/")[-1] if fixture else "(none)"}`
- Kết thúc: `{(result or {}).get("subtype")}`, {(result or {}).get("num_turns")} turns, {round(((result or {}).get("duration_ms") or 0)/1000)} s

## Prompt
```text
{prompt}
```

## Bằng chứng kích hoạt (tool_use "Skill" trong stream)
```json
{json.dumps(calls, ensure_ascii=False, indent=1)}
```

Thứ tự tool đã gọi: `{" → ".join(tools)}`

## File thay đổi trong thư mục test
```text
{chr(10).join(changed) if changed else "(none)"}
```

## Câu trả lời cuối của Claude (nguyên văn)
{text}
"""
open(out, "w", encoding="utf-8").write(md)
print("SKILL_CALLS=" + json.dumps([c["input"] for c in calls], ensure_ascii=False))
print("TRIGGERED=" + ("yes" if ok else "no"), "EVIDENCE=" + out)
sys.exit(0 if ok else 1)
PY
