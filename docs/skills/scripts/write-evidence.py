#!/usr/bin/env python3
"""Write docs/skills/test-results/<skill>.md from a finished headless test work dir.

Usage: write-evidence.py <workdir> <skill> <prompt> <start-utc> <out.md> [fixture]
Reads <workdir>/stream.jsonl and <workdir>/changed.txt. Exit 0 if the Skill tool was called with
exactly <skill>.
"""
import os
import sys

os.chdir(sys.argv[1])
sys.argv = [sys.argv[0]] + sys.argv[2:] + ([""] if len(sys.argv) < 7 else [])
import json, os, sys
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
changed = []
for l in open("changed.txt", encoding="utf-8"):
    l = l.rstrip()
    if not l or l.endswith("changed.txt"):
        continue
    path = l[3:]
    if path.startswith(("obj/", "bin/")):  # dotnet build output: collapse
        l = l[:3] + path.split("/")[0] + "/ (build output)"
        if l in changed:
            continue
    changed.append(l)
all_skills = init.get("skills", [])
project_skills = [s for s in all_skills if os.path.isfile(os.path.join(".claude/skills", s, "SKILL.md"))]
other_skills = len(all_skills) - len(project_skills)
text = (result or {}).get("result", "") or ""
if len(text) > 6000:
    text = text[:6000] + "\n\n[... truncated, full text in stream.jsonl ...]"
md = f"""# Test result — `{skill}`

- Kết quả: **{"PASS — Skill tool triggered" if ok else "FAIL — expected skill not triggered"}**
- Loại test: **real** (headless CLI `claude -p`, stream-json), chạy lúc {start}
- CLI: `{init.get("claude_code_version", "?")}` · thư mục test mới, có đủ {len(project_skills)} skill của repo
  (`{", ".join(sorted(project_skills))}`) + {other_skills} skill có sẵn của môi trường (built-in/plugin, ví dụ `anthropic-skills:pdf`)
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
