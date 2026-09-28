#!/usr/bin/env python3
"""Run the code samples in Markdown files and paste their REAL output.

Marker convention (invisible in rendered Markdown/PDF):

    <!-- run -->              <- next fenced block is executed
    ```java
    public class Hello { public static void main(String[] a) { System.out.println("hi"); } }
    ```
    <!-- output -->           <- next fenced block is replaced by the real output
    ```text
    (anything; will be overwritten)
    ```

Optional: `<!-- run: expect-fail -->` for samples that must fail (compile error / exception);
the output then contains the error text.

Languages: java (javac --release 21 + java), csharp/cs (dotnet run file.cs, .NET 10+),
typescript/ts (node, type stripping), javascript/js (node), python/py, bash/sh.
If the tool for a language is missing, the output block becomes "NOT RUN: <tool> not found"
and the script exits 3 so it can be listed under Blockers.

Usage: run_samples.py [--check] file.md [file2.md ...]
  --check  do not write; exit 1 if any output block differs from the real output.
Exit: 0 ok, 1 sample failed or --check mismatch, 3 some samples NOT RUN.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

BLOCK = re.compile(
    r"(?P<marker><!-- run(?P<opt>: expect-fail)? -->\n)"
    r"(?P<code>```(?P<lang>[\w+-]*)[^\n]*\n(?P<body>.*?)^```\n)"
    r"(?P<gap>\s*)"
    r"(?:(?P<omarker><!-- output -->\n)(?P<out>```[^\n]*\n.*?^```\n)?)?",
    re.S | re.M,
)
TOOLS = {"java": "javac", "csharp": "dotnet", "cs": "dotnet", "typescript": "node", "ts": "node",
         "javascript": "node", "js": "node", "python": "python3", "py": "python3",
         "bash": "bash", "sh": "bash"}
JAVA_CLASS = re.compile(r"^(?:public\s+)?(?:final\s+)?(?:class|record|enum|interface)\s+(\w+)", re.M)


def env():
    e = dict(os.environ)
    for k in ("JAVA_TOOL_OPTIONS", "JDK_JAVA_OPTIONS"):
        e.pop(k, None)
    e.update(TZ="UTC", LANG="C.UTF-8", LC_ALL="C.UTF-8", DOTNET_CLI_TELEMETRY_OPTOUT="1",
             DOTNET_NOLOGO="1", NODE_NO_WARNINGS="1")
    return e


def sh(cmd, cwd, timeout=120):
    p = subprocess.run(cmd, cwd=cwd, env=env(), capture_output=True, text=True, timeout=timeout)
    return p.returncode, p.stdout, p.stderr


def run(lang, body):
    """Return (ok, output_text)."""
    with tempfile.TemporaryDirectory() as d:
        if lang == "java":
            m = JAVA_CLASS.search(body)
            cls = m.group(1) if m else "Main"
            Path(d, f"{cls}.java").write_text(body)
            rc, out, err = sh(["javac", "--release", "21", "-d", ".", f"{cls}.java"], d)
            if rc:
                return False, err.replace(d + "/", "")
            rc, out, err = sh(["java", "-cp", ".", cls], d)
        elif lang in ("csharp", "cs"):
            Path(d, "sample.cs").write_text(body)
            rc, out, err = sh(["dotnet", "run", "sample.cs"], d, timeout=300)
        elif lang in ("typescript", "ts"):
            Path(d, "sample.ts").write_text(body)
            rc, out, err = sh(["node", "sample.ts"], d)
        elif lang in ("javascript", "js"):
            Path(d, "sample.mjs").write_text(body)
            rc, out, err = sh(["node", "sample.mjs"], d)
        elif lang in ("python", "py"):
            Path(d, "sample.py").write_text(body)
            rc, out, err = sh(["python3", "sample.py"], d)
        else:
            Path(d, "sample.sh").write_text(body)
            rc, out, err = sh(["bash", "sample.sh"], d)
        text = out + (err if rc else "")
        return rc == 0, text.replace(d + "/", "")


def process(md: Path, check: bool):
    src = md.read_text(encoding="utf-8")
    stats = {"ok": 0, "failed": 0, "not_run": 0, "changed": 0}

    def repl(m):
        lang = m.group("lang").lower()
        expect_fail = bool(m.group("opt"))
        tool = TOOLS.get(lang)
        if not tool:
            print(f"{md}: unsupported language '{lang}'")
            stats["failed"] += 1
            return m.group(0)
        if not shutil.which(tool):
            stats["not_run"] += 1
            text = f"NOT RUN: {tool} not found\n"
        else:
            ok, text = run(lang, m.group("body"))
            if ok == expect_fail:
                stats["failed"] += 1
                print(f"{md}: {lang} sample {'succeeded' if ok else 'FAILED'} "
                      f"(expected {'failure' if expect_fail else 'success'}):\n{text}")
            else:
                stats["ok"] += 1
        new_out = "```text\n" + (text if text.endswith("\n") else text + "\n") + "```\n"
        if (m.group("out") or "") != new_out:
            stats["changed"] += 1
        tail = "" if m.group("omarker") else (m.group("gap") or "\n")
        return m.group("marker") + m.group("code") + "\n<!-- output -->\n" + new_out + tail

    new = BLOCK.sub(repl, src)
    if not check and new != src:
        md.write_text(new, encoding="utf-8")
    return stats


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("files", nargs="+")
    a = ap.parse_args()
    total = {"ok": 0, "failed": 0, "not_run": 0, "changed": 0}
    for f in a.files:
        s = process(Path(f), a.check)
        print(f"{f}: ok={s['ok']} failed={s['failed']} not_run={s['not_run']} "
              f"{'outdated' if a.check else 'updated'}={s['changed']}")
        for k in total:
            total[k] += s[k]
    if total["failed"] or (a.check and total["changed"]):
        return 1
    return 3 if total["not_run"] else 0


if __name__ == "__main__":
    sys.exit(main())
