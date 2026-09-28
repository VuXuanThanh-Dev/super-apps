#!/usr/bin/env bash
# Negative trigger tests: prompts that belong to Task 1 agents (not to any repo skill).
# PASS = none of the repo skills in .claude/skills was invoked. Evidence: test-results/negative.md
set -uo pipefail
repo="$(cd "$(dirname "$0")/../../.." && pwd)"
base="${SKILL_TEST_BASE:-/tmp/skill-tests}"
out="$repo/docs/skills/test-results/negative.md"
prompts=(
  "Write QA test cases for this user story: As a user I can log in with email and password; after 5 wrong passwords the account is locked for 15 minutes. Answer in a Markdown table, do not create files."
  "Let's roleplay a daily stand-up meeting in English. You are my Scrum Master. Start the scene with one short question."
  "Đọc user story sau và hỏi BA những câu khó trước khi estimate: 'Người dùng có thể xuất báo cáo doanh thu theo tháng.' Không tạo file."
)
skills=$(ls "$repo/.claude/skills")
{ echo "# Negative trigger tests"; echo; echo "Prompt thuộc việc của agent Task 1 → không skill nào của repo được gọi."; echo; } > "$out"
fail=0
for p in "${prompts[@]}"; do
  work="$base/negative-$(date +%s%N)"; mkdir -p "$work/.claude"; cp -r "$repo/.claude/skills" "$work/.claude/skills"
  (cd "$work" && timeout 600 claude -p "$p" --output-format stream-json --verbose \
     --allowedTools "Bash,Read,Edit,Write,Grep,Glob,Skill" > stream.jsonl 2>/dev/null)
  called=$(python3 -c "
import json,sys
c=[]
for l in open('$work/stream.jsonl'):
    try: e=json.loads(l)
    except Exception: continue
    if e.get('type')=='assistant':
        c+= [x['input'].get('skill','') for x in e['message'].get('content',[]) if x.get('type')=='tool_use' and x['name']=='Skill']
print(','.join(c))")
  hit=""; for s in $skills; do [[ ",$called," == *",$s,"* ]] && hit="$hit $s"; done
  if [[ -z "$hit" ]]; then r=PASS; else r=FAIL; fail=1; fi
  { echo "## $r"; echo; echo '```text'; echo "$p"; echo '```'; echo "- Skill tool calls: \`${called:-(none)}\`"; echo "- Repo skills triggered: \`${hit:-(none)}\`"; echo; } >> "$out"
  echo "$r: ${called:-(none)}"
done
exit $fail
