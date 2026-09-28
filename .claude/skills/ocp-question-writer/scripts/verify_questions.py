#!/usr/bin/env python3
"""Verify OCP practice questions by compiling and running them with JDK 21.

Standalone subset of the questions.yaml format used by books/java-ocp/tools/book.py
(kinds: output, compile_error, variants). Inside that book, prefer
`python3 tools/book.py questions <set>`; use this script anywhere else.

Usage: verify_questions.py questions.yaml [--keep DIR]
Exit 1 if any question is wrong. Needs javac/java 21+ and PyYAML.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml

RELEASE = "21"
TYPE_RE = re.compile(r"^(?:public\s+)?(?:(?:final|abstract|sealed|non-sealed)\s+)*"
                     r"(?:class|record|enum|interface)\s+(\w+)", re.M)
PUB_RE = re.compile(r"^public\s+(?:(?:final|abstract|sealed|non-sealed)\s+)*"
                    r"(?:class|record|enum|interface)\s+(\w+)", re.M)


def env():
    e = dict(os.environ)
    for k in ("JAVA_TOOL_OPTIONS", "JDK_JAVA_OPTIONS"):
        e.pop(k, None)  # avoid "Picked up ..." noise on stderr
    e.update(TZ="UTC", LANG="C.UTF-8", LC_ALL="C.UTF-8")
    return e


def norm(s):
    return "\n".join(line.rstrip() for line in str(s).strip().splitlines())


def compile_run(src, main=None):
    with tempfile.TemporaryDirectory() as tmp:
        m = PUB_RE.search(src) or TYPE_RE.search(src)
        cls = main or (m.group(1) if m else "Main")
        (Path(tmp) / f"{cls}.java").write_text(src)
        c = subprocess.run(["javac", "--release", RELEASE, "-Xlint:none", "-d", "cls", f"{cls}.java"],
                           cwd=tmp, env=env(), capture_output=True, text=True)
        res = {"compiled": c.returncode == 0, "javac": c.stderr}
        if not res["compiled"]:
            res["error_lines"] = sorted({int(x) for x in re.findall(r"\.java:(\d+): error:", c.stderr)})
            return res
        r = subprocess.run(["java", "-Duser.language=en", "-Duser.country=US", "-cp", "cls", cls],
                           cwd=tmp, env=env(), capture_output=True, text=True, timeout=60)
        ex = re.search(r'Exception in thread "main" ([\w.$]+)', r.stderr)
        res.update(stdout=r.stdout, stderr=r.stderr, exit=r.returncode, exception=ex.group(1) if ex else None)
        return res


def marker_lines(src, markers):
    lines = src.split("\n")
    out = []
    for mk in markers:
        hit = [i + 1 for i, ln in enumerate(lines) if re.search(r"//\s*" + re.escape(mk) + r"\b", ln)]
        if len(hit) != 1:
            raise ValueError(f"marker {mk} found {len(hit)} times")
        out += hit
    return sorted(out)


def answers(q):
    a = q["answer"]
    return list(a) if isinstance(a, list) else [a]


def structure(q):
    errs = []
    for k in ("id", "level", "topic", "q", "kind", "options", "answer", "why"):
        if k not in q:
            errs.append(f"missing field {k}")
    if errs:
        return errs
    if len(q["options"]) < 4:
        errs.append("needs at least 4 options")
    for a in answers(q):
        if a not in q["options"]:
            errs.append(f"answer {a} not in options")
    wrong = q.get("wrong") or {}
    for k in q["options"]:
        if k not in answers(q) and k not in wrong:
            errs.append(f"no 'wrong' explanation for option {k}")
    if q["level"] not in ("easy", "medium", "hard"):
        errs.append("level must be easy|medium|hard")
    return errs


def check(q):
    kind, ans = q["kind"], answers(q)
    if kind == "output":
        r = compile_run(q["code"], q.get("main"))
        if not r["compiled"]:
            return [f"does not compile:\n{r['javac']}"], ""
        if "expect_exception" in q:
            if not (r["exception"] or "").endswith(q["expect_exception"]):
                return [f"expected exception {q['expect_exception']}, got {r['exception']}"], ""
            return [], f"exception {r['exception']} confirmed"
        errs = []
        if norm(r["stdout"]) != norm(q["expect"]):
            errs.append(f"stdout mismatch\n--- got ---\n{r['stdout']}--- expected ---\n{q['expect']}")
        if len(ans) == 1 and norm(q["options"][ans[0]]) != norm(q["expect"]):
            errs.append(f"option {ans[0]} text != expected output")
        dup = [k for k, v in q["options"].items() if k not in ans and norm(v) == norm(q["expect"])]
        if dup:
            errs.append(f"options {dup} have the same text as the answer")
        return errs, f"output {r['stdout'].strip()!r} confirmed"
    if kind == "compile_error":
        r = compile_run(q["code"], q.get("main"))
        if r["compiled"]:
            return ["expected a compile error, but it compiled"], ""
        if q.get("error_markers"):
            want = marker_lines(q["code"], q["error_markers"])
            if r["error_lines"] != want:
                return [f"errors on lines {r['error_lines']}, expected {want}\n{r['javac']}"], ""
        return [], f"compile error on lines {r['error_lines']} confirmed"
    if kind == "variants":
        crit = q.get("criterion", "compiles")
        good = []
        for letter, ins in q["options"].items():
            code = q["template"].replace("/*INSERT*/", ins if isinstance(ins, str) else ins["insert"])
            r = compile_run(code, q.get("main"))
            if crit == "compiles":
                ok = r["compiled"]
            elif crit == "runs":
                ok = r["compiled"] and r["exit"] == 0
            elif isinstance(crit, dict) and "output" in crit:
                ok = r["compiled"] and r["exit"] == 0 and norm(r["stdout"]) == norm(crit["output"])
            else:
                return [f"unsupported criterion {crit}"], ""
            if ok:
                good.append(letter)
        if sorted(good) != sorted(ans):
            return [f"options satisfying {crit}: {good}, answer says {ans}"], ""
        return [], f"variants {''.join(good)} satisfy {crit}"
    return [f"unsupported kind {kind} (use tools/book.py in the OCP book)"], ""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("yaml")
    a = ap.parse_args()
    if not shutil.which("javac"):
        print("BLOCKER: javac not found (need JDK 21+)")
        return 2
    data = yaml.safe_load(Path(a.yaml).read_text(encoding="utf-8"))
    qs = data["questions"] if isinstance(data, dict) else data
    bad = 0
    for q in qs:
        errs = structure(q)
        summary = ""
        if not errs:
            errs, summary = check(q)
        print(f"PASS {q.get('id', '?')}: {summary}" if not errs else f"FAIL {q.get('id', '?')}")
        for e in errs:
            print("   " + e.replace("\n", "\n   "))
        bad += bool(errs)
    jv = subprocess.run(["javac", "-version"], capture_output=True, text=True, env=env())
    print(f"\n{len(qs) - bad}/{len(qs)} questions verified with {(jv.stdout or jv.stderr).strip()} --release {RELEASE}")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
