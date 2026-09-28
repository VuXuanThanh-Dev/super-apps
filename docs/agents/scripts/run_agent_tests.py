#!/usr/bin/env python3
"""Run one real test per subagent with the headless Claude Code CLI.

For each test:
  1. Create a fresh work dir (outside the repo) with a copy of .claude/agents/ and the sample files,
     and make it a git repo (some agents need git).
  2. Run `claude -p` with a prompt that does NOT name the agent. The prompt only asks Claude to
     delegate to the most suitable project subagent. This tests that the `description` triggers the
     right agent.
  3. Parse the stream-json transcript: which subagent was called, which tools it used, final answer.
  4. Write docs/agents/test-results/<agent>.md.

Usage: python3 docs/agents/scripts/run_agent_tests.py [agent ...]   (default: all)
Needs: `claude` CLI logged in. Work dirs go to $AGENT_TEST_DIR (default /tmp/agent-tests).
"""
import concurrent.futures as cf
import json
import os
import shutil
import subprocess
import sys
from datetime import date
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]
SAMPLES = REPO / "docs/agents/samples"
RESULTS = REPO / "docs/agents/test-results"
WORK = Path(os.environ.get("AGENT_TEST_DIR", "/tmp/agent-tests"))
WRAP = ("Delegate this task to the single most suitable project subagent defined in .claude/agents "
        "(do not do it yourself). After it finishes, output its full answer unchanged.\n\nTask: ")


def git(cwd, *args):
    subprocess.run(["git", *args], cwd=cwd, check=True, capture_output=True)


def setup_conflict(w):
    """git-helper: create a real merge conflict on feature/discount."""
    (w / "price.js").write_text("const VAT = 0.1;\nmodule.exports = { VAT };\n")
    git(w, "add", "."); git(w, "commit", "-qm", "base")
    git(w, "checkout", "-qb", "feature/discount")
    (w / "price.js").write_text("const VAT = 0.1;\nconst DISCOUNT = 0.05;\nmodule.exports = { VAT, DISCOUNT };\n")
    git(w, "commit", "-qam", "feat: add discount")
    git(w, "checkout", "-q", "main")
    (w / "price.js").write_text("const VAT = 0.08; // new tax law 2026\nmodule.exports = { VAT };\n")
    git(w, "commit", "-qam", "fix: VAT is 8%")
    git(w, "checkout", "-q", "feature/discount")
    subprocess.run(["git", "merge", "main"], cwd=w, capture_output=True)  # leaves conflict


def setup_staged(w):
    """pr-and-commit-writer: stage a real change."""
    git(w, "add", "."); git(w, "commit", "-qm", "chore: initial")
    s = (w / "server.js").read_text().replace(
        "  res.writeHead(404);",
        "  if (req.url === '/version') {\n    res.writeHead(200, { 'Content-Type': 'application/json' });\n"
        "    return res.end(JSON.stringify({ version: require('./package.json').version }));\n  }\n  res.writeHead(404);")
    (w / "server.js").write_text(s)
    git(w, "add", "server.js")


TESTS = {
    "code-reviewer": ("review", None,
        "Please review the change in add-user-search.diff before I merge it into develop. Be strict."),
    "angular-expert": ("angular", None,
        "Refactor legacy-counter.component.ts to modern Angular: standalone, signal inputs/outputs, "
        "signals for state, built-in control flow. Write the result to counter.component.ts."),
    "java-spring-backend": ("java", None,
        "In OrderService.java, when stock is too low the exception is thrown but the saved order is NOT "
        "rolled back. Why? Show the fix."),
    "csharp-dotnet": ("csharp", None,
        "ReportService.cs sometimes hangs under load in our ASP.NET Core API. Fix it the right way and "
        "explain. Create a small console or xUnit project to prove the fixed code compiles."),
    "react-native-mobile": ("react-native", None,
        "ContactList.tsx is slow with 2000 contacts and React warns about keys. Rewrite it properly "
        "for our Expo app (write ContactList.fixed.tsx)."),
    "database-designer": (None, None,
        "Thiết kế database (PostgreSQL) cho module đặt phòng họp: phòng có sức chứa và thiết bị; nhân viên "
        "đặt phòng theo khung giờ; không được trùng lịch cùng phòng; có thể đặt lặp lại hằng tuần; "
        "cần báo cáo tỉ lệ sử dụng phòng theo tháng."),
    "ba-requirements-challenger": ("srs", None,
        "BA vừa gửi leave-request-srs.md. Trước khi ước lượng, hãy tìm các chỗ thiếu, mâu thuẫn, mơ hồ "
        "và yêu cầu phi chức năng còn thiếu."),
    "test-case-writer": ("srs", None,
        "Write QA test cases for section 3.1 (Create request) and BR-1, BR-2 of leave-request-srs.md."),
    "security-reviewer": ("security", None,
        "Before release, check UserController.java for security problems only."),
    "debugger": ("debug", None,
        "PriceCalculatorTest fails: 'expected 170.0 but was 200.0'. Run it with javac/java, find the "
        "root cause and fix it."),
    "performance-optimizer": ("perf", None,
        "findDuplicates in find-duplicates.js takes about 8 seconds for 20,000 emails (node bench.js). "
        "Make it fast, keep the same result, show before/after numbers."),
    "git-helper": (None, setup_conflict,
        "I am on feature/discount and merging main gave a conflict in price.js. Resolve it so both "
        "changes are kept, and finish the merge."),
    "devops-ci": ("node-app", None,
        "Create a .gitlab-ci.yml (test and docker build stages) and a production Dockerfile for this "
        "Node app."),
    "docs-writer": ("node-app", None,
        "Viết README song ngữ (tiếng Việt + English) cho app Node này: cài đặt, chạy, test, endpoint."),
    "pr-and-commit-writer": ("node-app", setup_staged,
        "Write the commit message for my staged change, and a short MR description."),
    "estimation-and-planning": ("srs", None,
        "Chia task và ước lượng effort cho leave-request-srs.md. Team: 2 Angular dev, 1 Java Spring dev, "
        "1 QA."),
    "intern-mentor": ("mentor", None,
        "Our intern asks what search.component.ts does and why switchMap instead of mergeMap. Explain it "
        "for a junior."),
}

ENGLISH_TURNS = [
    "Let's practise English: roleplay a daily stand-up. You are my Scrum Master Sarah; I am the "
    "frontend lead. I will say 'end scene' when done.",
    "Yesterday I fix the bug of login page and today I will making the unit test. I have one blocker, "
    "the API from backend team is not ready since two days.",
    "Yes, I already ask them but they said maybe tomorrow. If not ready I will use mock data for continue.",
    "end scene",
]


def run(cmd, cwd):
    p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=1500)
    return p.stdout


def parse(stream):
    delegated, sub_tools, final = [], [], ""
    for line in stream.splitlines():
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        if ev.get("type") == "assistant":
            for c in ev["message"].get("content", []):
                if c.get("type") == "tool_use":
                    if c["name"] in ("Agent", "Task"):
                        delegated.append(c["input"].get("subagent_type"))
                    elif ev.get("parent_tool_use_id"):
                        sub_tools.append(c["name"])
        if ev.get("type") == "result":
            final = ev.get("result", "")
    return delegated, sorted(set(sub_tools)), final


def base_cmd(prompt):
    # The prompt must come right after -p: --allowedTools is variadic and would swallow it.
    return ["claude", "-p", prompt, "--output-format", "stream-json", "--verbose",
            "--permission-mode", "acceptEdits",
            "--allowedTools", "Bash,Read,Edit,Write,Grep,Glob,WebFetch,Agent"]


def prepare(name, sample, setup):
    w = WORK / name
    shutil.rmtree(w, ignore_errors=True)
    (w / ".claude").mkdir(parents=True)
    shutil.copytree(REPO / ".claude/agents", w / ".claude/agents")
    if sample:
        shutil.copytree(SAMPLES / sample, w, dirs_exist_ok=True)
    git(w, "init", "-q", "-b", "main")
    git(w, "config", "user.email", "test@example.com"); git(w, "config", "user.name", "Agent Test")
    if setup:
        setup(w)
    return w


def test_agent(name):
    if name == "english-coach":
        w = prepare(name, None, None)
        outputs = []
        for i, turn in enumerate(ENGLISH_TURNS):
            cmd = base_cmd(turn) + (["--agent", "english-coach"] if i == 0 else ["-c"])
            outputs.append(parse(run(cmd, w))[2])
        transcript = "\n\n".join(f"**User:** {t}\n\n**Coach:** {o}" for t, o in zip(ENGLISH_TURNS, outputs))
        return name, ["english-coach (run as main agent with --agent, multi-turn with -c)"], [], transcript, ENGLISH_TURNS[0]
    sample, setup, prompt = TESTS[name]
    w = prepare(name, sample, setup)
    stream = run(base_cmd(WRAP + prompt), w)
    (w / "transcript.jsonl").write_text(stream)
    delegated, tools, final = parse(stream)
    return name, delegated, tools, final, prompt


def write_result(name, delegated, tools, final, prompt):
    RESULTS.mkdir(parents=True, exist_ok=True)
    ok = name in " ".join(d or "" for d in delegated)
    body = (f"# Test result — {name}\n\n- Date: {date.today()}\n- Mode: real (headless `claude -p`)\n"
            f"- Delegated to: {', '.join(d or '?' for d in delegated) or 'NONE'}\n"
            f"- Correct agent triggered: {'yes' if ok else 'NO'}\n"
            f"- Tools the subagent used: {', '.join(tools) or '(none recorded)'}\n\n"
            f"## Prompt\n\n{prompt}\n\n## Result (verbatim)\n\n{final}\n")
    (RESULTS / f"{name}.md").write_text(body)
    return ok


def main():
    names = sys.argv[1:] or list(TESTS) + ["english-coach"]
    with cf.ThreadPoolExecutor(max_workers=int(os.environ.get("AGENT_TEST_JOBS", "4"))) as ex:
        for fut in cf.as_completed([ex.submit(test_agent, n) for n in names]):
            try:
                name, delegated, tools, final, prompt = fut.result()
            except Exception as e:  # keep going; report at the end
                print("ERROR", e)
                continue
            ok = write_result(name, delegated, tools, final, prompt)
            print(f"{name:28} delegated={delegated} tools={tools} triggered_ok={ok} answer_chars={len(final)}")


if __name__ == "__main__":
    main()
