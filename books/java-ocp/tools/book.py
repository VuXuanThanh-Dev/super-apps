#!/usr/bin/env python3
"""Build and check tool for the Java OCP handbook.

Commands (run from anywhere):
  python3 tools/book.py examples [chNN ...]   compile + run examples, save output, sync chapter Markdown
  python3 tools/book.py questions [SET ...]   generate question Java files, compile + run them,
                                              confirm every answer, render Markdown
  python3 tools/book.py coverage              regenerate COVERAGE.md (fails on empty rows)
  python3 tools/book.py all                   everything above

Requirements: JDK 21 (javac/java on PATH), Python 3.11+, PyYAML.
"""
from __future__ import annotations

import concurrent.futures as cf
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
EX_DIR = ROOT / "examples"
Q_DIR = EX_DIR / "questions"
CH_DIR = ROOT / "chapters"
MOCK_DIR = ROOT / "mock"
RELEASE = "21"
WORKERS = max(2, os.cpu_count() or 2)

LEVELS = {"easy": "Dễ", "medium": "Vừa", "hard": "Khó"}


# --------------------------------------------------------------------------- helpers

def java_env() -> dict:
    env = dict(os.environ)
    env.pop("JAVA_TOOL_OPTIONS", None)  # the sandbox sets it; it prints noise on stderr
    env.pop("JDK_JAVA_OPTIONS", None)
    env["TZ"] = "UTC"
    env["LANG"] = "C.UTF-8"
    env["LC_ALL"] = "C.UTF-8"
    return env


JAVA_FLAGS = ["-Duser.language=en", "-Duser.country=US", "-Duser.timezone=UTC",
              "-Dfile.encoding=UTF-8", "-Dstdout.encoding=UTF-8", "-Dstderr.encoding=UTF-8",
              "-XX:+UseSerialGC", "-XX:TieredStopAtLevel=1", "-Xshare:auto"]


def run(cmd, cwd, timeout=60, merge=False):
    p = subprocess.run(cmd, cwd=cwd, env=java_env(), capture_output=not merge,
                       stdout=subprocess.PIPE if merge else None,
                       stderr=subprocess.STDOUT if merge else None,
                       text=True, timeout=timeout)
    return p


TYPE_RE = re.compile(r"^(?:public\s+)?(?:(?:final|abstract|sealed|non-sealed|strictfp)\s+)*"
                     r"(class|record|enum|interface)\s+(\w+)", re.M)
PUBLIC_RE = re.compile(r"^public\s+(?:(?:final|abstract|sealed|non-sealed|strictfp)\s+)*"
                       r"(?:class|record|enum|interface)\s+(\w+)", re.M)


def main_class(src: str, explicit: str | None = None) -> str:
    if explicit:
        return explicit
    m = PUBLIC_RE.search(src)
    if m:
        return m.group(1)
    m = TYPE_RE.search(src)
    if not m:
        raise ValueError("no top-level type found")
    return m.group(2)


def file_name(src: str, explicit: str | None = None) -> str:
    m = PUBLIC_RE.search(src)
    if m:
        return m.group(1) + ".java"
    return main_class(src, explicit) + ".java"


def norm(s: str) -> str:
    """Normalise program output for comparison: strip trailing spaces and blank edges."""
    lines = [ln.rstrip() for ln in s.replace("\r\n", "\n").split("\n")]
    return "\n".join(lines).strip("\n")


def replace_block(text: str, start: str, end: str, body: str) -> tuple[str, bool]:
    pat = re.compile(re.escape(start) + r".*?" + re.escape(end), re.S)
    if not pat.search(text):
        return text, False
    return pat.sub(lambda _m: start + "\n" + body.rstrip() + "\n" + end, text, count=1), True


# --------------------------------------------------------------------------- examples

def example_units(chapter: str):
    d = EX_DIR / chapter
    if not d.is_dir():
        return []
    units = []
    for p in sorted(d.iterdir()):
        if p.name.startswith("Ex") and (p.suffix == ".java" or (p.is_dir() and (p / "run.sh").exists())):
            units.append(p)
    return units


def run_example(p: Path) -> tuple[Path, str, bool, str]:
    """Returns (path, output, ok, message)."""
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        if p.is_dir():
            work = tmp / p.name
            shutil.copytree(p, work, ignore=shutil.ignore_patterns("output.txt", "out", "*.class"))
            r = run(["bash", "run.sh"], cwd=work, timeout=180, merge=True)
            out = r.stdout
            ok = r.returncode == 0
            return p, out, ok, "" if ok else f"run.sh exit {r.returncode}"
        src = p.read_text()
        expect_ce = "// expect: compile-error" in src
        expect_ex = "// expect: exception" in src
        shutil.copy(p, tmp / p.name)
        c = run(["javac", "--release", RELEASE, "-Xlint:none", "-d", "cls", p.name], cwd=tmp)
        if expect_ce:
            if c.returncode == 0:
                return p, "", False, "expected compile error but compiled"
            out = c.stderr.replace(str(tmp) + "/", "")
            return p, out, True, ""
        if c.returncode != 0:
            return p, c.stderr, False, "compile failed"
        r = run(["java", *JAVA_FLAGS, "-cp", "cls", p.stem], cwd=tmp, timeout=120, merge=True)
        ok = (r.returncode == 0) != expect_ex
        return p, r.stdout, ok, "" if ok else f"exit {r.returncode}"


def fence(lang: str, body: str) -> str:
    body = body.rstrip("\n")
    ticks = "```"
    while ticks in body:
        ticks += "`"
    return f"{ticks}{lang}\n{body}\n{ticks}"


def example_markdown(p: Path, out: str) -> str:
    parts = []
    if p.is_dir():
        files = [f for f in sorted(p.rglob("*")) if f.is_file() and f.name != "output.txt"
                 and "/out/" not in str(f) and f.suffix in (".java", ".sh", ".properties", ".txt", ".MF", ".mf")]
        # show run.sh last
        files.sort(key=lambda f: (f.name == "run.sh", str(f)))
        for f in files:
            lang = {".java": "java", ".sh": "bash", ".properties": "properties"}.get(f.suffix, "text")
            parts.append(f"`{p.name}/{f.relative_to(p)}`\n\n" + fence(lang, f.read_text()))
        label = "Output thật (chạy `bash run.sh`, JDK 21.0.10):"
    else:
        src = p.read_text()
        parts.append(f"`examples/{p.parent.name}/{p.name}`\n\n" + fence("java", src))
        if "// expect: compile-error" in src:
            label = "Output thật của `javac` (JDK 21.0.10) — cố ý không biên dịch được:"
        else:
            label = "Output thật (JDK 21.0.10):"
    parts.append(label + "\n\n" + fence("text", out if out.strip() else "(không in gì)"))
    return "\n\n".join(parts)


def cmd_examples(chapters: list[str]) -> bool:
    if not chapters:
        chapters = sorted(d.name for d in EX_DIR.iterdir() if d.is_dir() and re.fullmatch(r"ch\d\d", d.name))
    all_ok = True
    for ch in chapters:
        units = example_units(ch)
        with cf.ThreadPoolExecutor(WORKERS) as ex:
            results = list(ex.map(run_example, units))
        md_files = list(CH_DIR.glob(f"{ch}-*.md"))
        md = md_files[0].read_text() if md_files else ""
        n_ok = 0
        for p, out, ok, msg in results:
            out = norm(out)
            outfile = (p / "output.txt") if p.is_dir() else p.with_suffix(".out.txt")
            outfile.write_text(out + "\n")
            name = p.stem if p.is_file() else p.name
            if not ok:
                all_ok = False
                print(f"  FAIL {ch}/{p.name}: {msg}\n{out[:2000]}")
                continue
            n_ok += 1
            if md:
                md, found = replace_block(md, f"<!-- EX:{name} -->", "<!-- /EX -->", example_markdown(p, out))
                if not found:
                    print(f"  WARN {ch}/{p.name}: no <!-- EX:{name} --> marker in chapter")
        if md_files:
            md_files[0].write_text(md)
        print(f"examples {ch}: {n_ok}/{len(units)} ok")
    return all_ok


# --------------------------------------------------------------------------- questions

def load_set(name: str) -> dict:
    data = yaml.safe_load((Q_DIR / name / "questions.yaml").read_text())
    if isinstance(data, list):
        data = {"questions": data}
    data.setdefault("meta", {})
    return data


def answers_of(q) -> list[str]:
    a = q["answer"]
    return [a] if isinstance(a, str) else list(a)


def display_code(q) -> str | None:
    if q.get("kind") == "variants":
        return q["template"].replace("/*INSERT*/", "// INSERT CODE HERE")
    if q.get("kind") == "script":
        return None
    return q.get("code")


def qdir_name(qid: str) -> str:
    return "Q" + qid.replace("-", "_")


def gen_files(set_name: str, q) -> list[tuple[str, Path]]:
    """Write Java sources for one question. Returns list of (unit label, dir)."""
    base = Q_DIR / set_name / qdir_name(q["id"])
    if base.exists():
        shutil.rmtree(base)
    base.mkdir(parents=True)
    kind = q["kind"]
    units = []

    def write_src(d: Path, src: str, explicit=None):
        d.mkdir(parents=True, exist_ok=True)
        (d / file_name(src, explicit)).write_text(src if src.endswith("\n") else src + "\n")

    if kind in ("output", "compile_error"):
        write_src(base, q["code"], q.get("main"))
        units.append(("main", base))
    elif kind == "variants":
        for letter, ins in q["options"].items():
            ins_code = ins if isinstance(ins, str) else ins["insert"]
            write_src(base / letter, q["template"].replace("/*INSERT*/", ins_code), q.get("main"))
            units.append((letter, base / letter))
    elif kind == "proofs":
        for letter, pr in q["proofs"].items():
            write_src(base / letter, pr["code"], pr.get("main"))
            units.append((letter, base / letter))
    elif kind == "script":
        for rel, content in q["files"].items():
            f = base / rel
            f.parent.mkdir(parents=True, exist_ok=True)
            f.write_text(content if content.endswith("\n") else content + "\n")
        (base / "run.sh").write_text(q["run"])
        units.append(("main", base))
    else:
        raise ValueError(f"{q['id']}: unknown kind {kind}")
    return units


def compile_and_run(d: Path, explicit_main=None, timeout=60):
    """Compile all .java in d (copied to temp) and run main class. Returns dict."""
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        srcs = [f for f in d.glob("*.java")]
        for f in srcs:
            shutil.copy(f, tmp / f.name)
        c = run(["javac", "--release", RELEASE, "-Xlint:none", "-d", "cls", *[f.name for f in srcs]], cwd=tmp)
        res = {"compiled": c.returncode == 0, "javac": c.stderr.replace(str(tmp) + "/", "")}
        if not res["compiled"]:
            res["error_lines"] = sorted({int(m) for m in re.findall(r"^\S+\.java:(\d+): error:", c.stderr, re.M)})
            return res
        src = srcs[0].read_text()
        mc = main_class(src, explicit_main)
        r = run(["java", *JAVA_FLAGS, "-cp", "cls", mc], cwd=tmp, timeout=timeout)
        res.update(stdout=r.stdout, stderr=r.stderr, exit=r.returncode)
        m = re.search(r'Exception in thread "main" ([\w.$]+)', r.stderr)
        res["exception"] = m.group(1) if m else None
        return res


def run_script(d: Path, timeout=180):
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp) / "w"
        shutil.copytree(d, work)
        r = run(["bash", "run.sh"], cwd=work, timeout=timeout, merge=True)
        return {"compiled": True, "stdout": r.stdout, "exit": r.returncode, "stderr": "", "exception": None}


def marker_lines(src: str, markers: list[str]) -> list[int]:
    out = []
    for mk in markers:
        found = [i + 1 for i, ln in enumerate(src.split("\n")) if re.search(r"//\s*" + re.escape(mk) + r"\b", ln)]
        if len(found) != 1:
            raise ValueError(f"marker {mk} found {len(found)} times")
        out.append(found[0])
    return sorted(out)


def check_expectation(res: dict, exp: dict) -> str | None:
    """exp keys: expect (stdout), expect_exception, compile_error, error_markers, src, runs."""
    if exp.get("compile_error"):
        if res["compiled"]:
            return "expected compile error, but it compiled"
        if exp.get("error_markers"):
            want = marker_lines(exp["src"], exp["error_markers"])
            if res["error_lines"] != want:
                return f"compile errors on lines {res['error_lines']}, expected {want}\n{res['javac']}"
        return None
    if not res["compiled"]:
        return "did not compile:\n" + res["javac"]
    if "expect_exception" in exp:
        if res["exception"] is None or not res["exception"].endswith(exp["expect_exception"]):
            return f"expected exception {exp['expect_exception']}, got {res['exception']} (exit {res['exit']})\n{res['stderr'][:500]}"
    elif res["exit"] != 0:
        return f"exit code {res['exit']}\n{res['stderr'][:800]}"
    if "expect" in exp and exp["expect"] is not None:
        if norm(res["stdout"]) != norm(str(exp["expect"])):
            return f"stdout mismatch\n--- got ---\n{res['stdout']}\n--- expected ---\n{exp['expect']}"
    return None


def check_question(set_name: str, q) -> tuple[str, list[str], str]:
    """Returns (id, problems, summary)."""
    problems = []
    kind = q["kind"]
    base = Q_DIR / set_name / qdir_name(q["id"])
    ans = answers_of(q)
    try:
        if kind == "output":
            res = compile_and_run(base, q.get("main"))
            err = check_expectation(res, {"expect": q.get("expect"), **({"expect_exception": q["expect_exception"]} if "expect_exception" in q else {})})
            if err:
                problems.append(err)
            if "expect_exception" not in q and len(ans) == 1:
                opt = q["options"][ans[0]]
                if norm(str(opt)) != norm(str(q.get("expect"))):
                    problems.append(f"answer option {ans[0]} text {opt!r} != expected output {q.get('expect')!r}")
                for k, v in q["options"].items():
                    if k != ans[0] and norm(str(v)) == norm(str(q.get("expect"))):
                        problems.append(f"option {k} has same text as the answer")
            summary = "output confirmed"
        elif kind == "compile_error":
            res = compile_and_run(base, q.get("main"))
            err = check_expectation(res, {"compile_error": True, "error_markers": q.get("error_markers"), "src": q["code"]})
            if err:
                problems.append(err)
            summary = "compile error confirmed" + (f" at {q['error_markers']}" if q.get("error_markers") else "")
        elif kind == "variants":
            crit = q.get("criterion", "compiles")
            good = []
            for letter in q["options"]:
                res = compile_and_run(base / letter, q.get("main"))
                if crit == "compiles":
                    okk = res["compiled"]
                elif crit == "runs":
                    okk = res["compiled"] and res["exit"] == 0
                elif isinstance(crit, dict) and "output" in crit:
                    okk = res["compiled"] and res["exit"] == 0 and norm(res["stdout"]) == norm(str(crit["output"]))
                elif isinstance(crit, dict) and "compile_error" in crit:
                    okk = not res["compiled"]
                else:
                    raise ValueError(f"bad criterion {crit}")
                if okk:
                    good.append(letter)
            if sorted(good) != sorted(ans):
                problems.append(f"variants matching criterion {crit}: {good}, answer says {ans}")
            summary = f"variants: {''.join(good)} satisfy {crit if isinstance(crit, str) else list(crit)[0]}"
        elif kind == "proofs":
            if set(q["proofs"]) != set(q["options"]):
                problems.append("every option needs a proof")
            for letter, pr in q["proofs"].items():
                res = compile_and_run(base / letter, pr.get("main"))
                exp = dict(pr)
                exp["src"] = pr["code"]
                err = check_expectation(res, exp)
                if err:
                    problems.append(f"proof {letter}: {err}")
                holds = pr.get("holds")
                if holds is None:
                    problems.append(f"proof {letter}: missing 'holds' (true/false)")
                elif bool(holds) != (letter in ans):
                    problems.append(f"proof {letter}: holds={holds} but answer set is {ans}")
            summary = "each option proven true/false by a program"
        elif kind == "script":
            res = run_script(base)
            if res["exit"] != 0:
                problems.append(f"run.sh exit {res['exit']}\n{res['stdout'][-1500:]}")
            elif norm(res["stdout"]) != norm(str(q["expect"])):
                problems.append(f"script output mismatch\n--- got ---\n{res['stdout']}\n--- expected ---\n{q['expect']}")
            summary = "script output confirmed"
        else:
            problems.append(f"unknown kind {kind}")
            summary = ""
    except Exception as e:  # noqa: BLE001
        problems.append(f"{type(e).__name__}: {e}")
        summary = ""
    return q["id"], problems, summary


def validate(set_name: str, data: dict) -> list[str]:
    errs = []
    ids = set()
    strict = data["meta"].get("require_wrong", True)
    for q in data["questions"]:
        qid = q.get("id", "?")
        for key in ("id", "level", "topic", "q", "kind", "options", "answer", "why"):
            if key not in q:
                errs.append(f"{qid}: missing {key}")
        if qid in ids:
            errs.append(f"{qid}: duplicate id")
        ids.add(qid)
        if "options" not in q or "answer" not in q:
            continue
        if len(q["options"]) < 4:
            errs.append(f"{qid}: needs at least 4 options")
        for a in answers_of(q):
            if a not in q["options"]:
                errs.append(f"{qid}: answer {a} not in options")
        if q.get("level") not in LEVELS:
            errs.append(f"{qid}: bad level")
        if strict:
            wrong = q.get("wrong", {}) or {}
            for k in q["options"]:
                if k not in answers_of(q) and k not in wrong:
                    errs.append(f"{qid}: no explanation why option {k} is wrong")
    return errs


def distribution(data: dict) -> tuple[dict, list[str]]:
    counts: dict[str, int] = {}
    singles = [q for q in data["questions"] if len(answers_of(q)) == 1]
    for q in singles:
        a = answers_of(q)[0]
        counts[a] = counts.get(a, 0) + 1
    issues = []
    if singles:
        for k, v in counts.items():
            if v / len(singles) > 0.40 and len(singles) >= 8:
                issues.append(f"letter {k} is the answer in {v}/{len(singles)} single-answer questions (>40%)")
        for k in "ABCD":
            if counts.get(k, 0) == 0 and len(singles) >= 8:
                issues.append(f"letter {k} is never the answer")
    return counts, issues


# ---- rendering

def render_option(letter: str, text, style: str) -> str:
    if isinstance(text, dict):
        text = text.get("text") or text.get("insert")
    text = str(text).rstrip("\n")
    if style == "code":
        if "\n" in text:
            body = "\n".join("    " + ln for ln in fence("java" if ";" in text else "text", text).split("\n"))
            return f"- **{letter}.**\n\n{body}\n"
        return f"- **{letter}.** `{text}`" if "`" not in text else f"- **{letter}.** ``{text}``"
    return f"- **{letter}.** {text}"


def opt_style(q) -> str:
    if "opt_style" in q:
        return q["opt_style"]
    return "code" if q["kind"] in ("output", "variants") else "text"


def render_question(q, heading="####") -> str:
    ans = answers_of(q)
    lines = [f"{heading} Câu {q['id']} · {LEVELS[q['level']]} · objective {q['topic']}", ""]
    stem = q["q"].strip()
    if len(ans) > 1:
        stem += f" **(Chọn {len(ans)} đáp án.)**"
    lines += [stem, ""]
    code = display_code(q)
    if q.get("kind") == "script":
        for rel, content in q.get("show", q["files"]).items() if isinstance(q.get("show", q["files"]), dict) else []:
            lang = "java" if rel.endswith(".java") else "text"
            lines += [f"`{rel}`", "", fence(lang, content), ""]
        if q.get("show_cmd"):
            lines += [fence("bash", q["show_cmd"]), ""]
    elif code:
        lines += [fence("java", code), ""]
    style = opt_style(q)
    for k, v in q["options"].items():
        lines.append(render_option(k, v, style))
    lines.append("")
    return "\n".join(lines)


def render_answer(set_name: str, q, summary: str, heading="####") -> str:
    ans = answers_of(q)
    lines = [f"{heading} Câu {q['id']} — Đáp án: **{', '.join(ans)}**", ""]
    lines.append(f"- **Vì sao đúng:** {q['why'].strip()}")
    wrong = q.get("wrong", {}) or {}
    for k in q["options"]:
        if k in ans:
            continue
        if k in wrong:
            lines.append(f"- **{k} sai:** {str(wrong[k]).strip()}")
    rel = f"examples/questions/{set_name}/{qdir_name(q['id'])}/"
    lines.append(f"- *Kiểm chứng:* `{rel}` — {summary} (`python3 tools/book.py questions {set_name}`).")
    lines.append("")
    return "\n".join(lines)


def cmd_questions(sets: list[str]) -> bool:
    if not sets:
        sets = sorted(d.name for d in Q_DIR.iterdir() if (d / "questions.yaml").exists())
    all_ok = True
    for s in sets:
        data = load_set(s)
        errs = validate(s, data)
        units = []
        for q in data["questions"]:
            gen_files(s, q)
        # remove stale question dirs
        valid = {qdir_name(q["id"]) for q in data["questions"]}
        for d in (Q_DIR / s).iterdir():
            if d.is_dir() and d.name.startswith("Q") and d.name not in valid:
                shutil.rmtree(d)
        with cf.ThreadPoolExecutor(WORKERS) as ex:
            results = list(ex.map(lambda q: check_question(s, q), data["questions"]))
        summaries = {}
        n_ok = 0
        for qid, probs, summary in results:
            summaries[qid] = summary
            if probs:
                all_ok = False
                for pr in probs:
                    print(f"  FAIL {s} {qid}: {pr}")
            else:
                n_ok += 1
        counts, dist_issues = distribution(data)
        for e in errs + dist_issues:
            all_ok = False
            print(f"  FAIL {s}: {e}")
        multi = sum(1 for q in data["questions"] if len(answers_of(q)) > 1)
        lv = {k: sum(1 for q in data["questions"] if q.get("level") == k) for k in LEVELS}
        print(f"questions {s}: {n_ok}/{len(data['questions'])} confirmed; "
              f"single-answer letters {dict(sorted(counts.items()))}; multi-answer {multi}; levels {lv}")
        render_set(s, data, summaries)
        (Q_DIR / s / "CHECK_RESULT.txt").write_text(
            f"questions {s}: {n_ok}/{len(data['questions'])} confirmed by tools/book.py\n"
            + "".join(f"{qid}: {'OK' if not probs else 'FAIL'} — {summ}\n" for qid, probs, summ in results))
    return all_ok


def render_set(s: str, data: dict, summaries: dict):
    qs = data["questions"]
    q_md = "\n".join(render_question(q) for q in qs)
    a_md = "\n".join(render_answer(s, q, summaries.get(q["id"], "")) for q in qs)
    if s.startswith("ch"):
        md_files = list(CH_DIR.glob(f"{s}-*.md"))
        if not md_files:
            print(f"  WARN no chapter file for {s}")
            return
        md = md_files[0].read_text()
        md, f1 = replace_block(md, f"<!-- QUESTIONS:{s} -->", "<!-- /QUESTIONS -->", q_md)
        md, f2 = replace_block(md, f"<!-- ANSWERS:{s} -->", "<!-- /ANSWERS -->", a_md)
        if not (f1 and f2):
            print(f"  WARN {s}: QUESTIONS/ANSWERS markers missing")
        md_files[0].write_text(md)
    elif s.startswith("mock"):
        meta = data["meta"]
        n = s.replace("mock", "")
        MOCK_DIR.mkdir(exist_ok=True)
        head = (f"# Đề thi thử số {n} — 1Z0-830 (Java SE 21)\n\n{meta.get('intro', '').strip()}\n\n"
                f"Đáp án và giải thích: [mock-exam-{n}-answers.md](mock-exam-{n}-answers.md)\n\n")
        body = "\n".join(render_question(q, "###") for q in qs)
        (MOCK_DIR / f"mock-exam-{n}.md").write_text(head + body)
        key = " · ".join(f"{q['id']}: {','.join(answers_of(q))}" for q in qs)
        ahead = (f"# Đáp án đề thi thử số {n}\n\nĐề: [mock-exam-{n}.md](mock-exam-{n}.md). "
                 f"Đậu khi đúng ≥ 34/50 câu (68%).\n\n## Bảng đáp án nhanh\n\n{key}\n\n## Giải thích\n\n")
        abody = "\n".join(render_answer(s, q, summaries.get(q["id"], ""), "###") for q in qs)
        topics: dict[str, int] = {}
        for q in qs:
            g = str(q["topic"]).split(".")[0]
            topics[g] = topics.get(g, 0) + 1
        tline = "\n## Phân bố theo nhóm mục tiêu\n\n| Nhóm | Số câu |\n|---|---|\n" + "".join(
            f"| {g} | {c} |\n" for g, c in sorted(topics.items(), key=lambda x: int(x[0])))
        (MOCK_DIR / f"mock-exam-{n}-answers.md").write_text(ahead + abody + tline)


# --------------------------------------------------------------------------- coverage

def cmd_coverage() -> bool:
    obj = yaml.safe_load((ROOT / "tools" / "objectives.yaml").read_text())
    ex_map: dict[str, list[str]] = {}
    for p in sorted(EX_DIR.glob("ch*/Ex*")):
        if p.name.endswith(".out.txt"):
            continue
        src = p.read_text() if p.is_file() else "\n".join(f.read_text() for f in p.rglob("*") if f.is_file())
        for o in set(re.findall(r"objective:\s*([\d.,\s]+)", src)):
            for oid in re.split(r"[,\s]+", o.strip()):
                if oid:
                    ex_map.setdefault(oid.rstrip("."), []).append(f"{p.parent.name}/{p.stem if p.is_file() else p.name}")
    q_map: dict[str, list[str]] = {}
    mock_map: dict[str, list[str]] = {}
    for d in sorted(Q_DIR.iterdir()):
        if not (d / "questions.yaml").exists():
            continue
        for q in load_set(d.name)["questions"]:
            for oid in str(q["topic"]).replace(" ", "").split(","):
                (mock_map if d.name.startswith("mock") else q_map).setdefault(oid, []).append(q["id"])
    rows = []
    empty = []
    for g in obj["groups"]:
        ch = g["chapter"]
        mdf = list(CH_DIR.glob(f"{ch}-*.md"))
        chlink = f"[{ch}](chapters/{mdf[0].name})" if mdf else ch
        for o in g["objectives"]:
            oid = o["id"]
            exs = sorted(set(ex_map.get(oid, [])))
            qs = q_map.get(oid, [])
            ms = mock_map.get(oid, [])
            if not (mdf and exs and qs):
                empty.append(oid)
            rows.append(f"| {oid} | {o['text']} | {chlink} | {', '.join('`'+e+'`' for e in exs) or '—'} | "
                        f"{', '.join(qs) or '—'} | {', '.join(ms) or '—'} |")
    total = sum(len(g["objectives"]) for g in obj["groups"])
    covered = total - len(empty)
    head = f"""# COVERAGE — Mục tiêu thi 1Z0-830 → chương → ví dụ → câu hỏi

> File này được **sinh tự động** bởi `python3 tools/book.py coverage` từ:
> `tools/objectives.yaml` (danh sách mục tiêu), dòng `// objective: x.y` trong từng ví dụ,
> và trường `topic` của từng câu hỏi trong `examples/questions/*/questions.yaml`.
>
> Danh sách mục tiêu lấy từ bảng mục tiêu trong repo eh3rrera/ocpj21-book (ghi là mục tiêu chính thức của Oracle);
> **UNVERIFIED** so với trang Oracle (bị chặn trong sandbox, kiểm tra 2026-09-28). Số thứ tự x.y là của sách này.

**Độ phủ: {covered}/{total} mục tiêu có đủ chương + ví dụ + câu hỏi chương.**

| ID | Mục tiêu (Oracle, tiếng Anh) | Chương | Ví dụ | Câu hỏi chương | Câu hỏi thi thử |
|---|---|---|---|---|---|
"""
    (ROOT / "COVERAGE.md").write_text(head + "\n".join(rows) + "\n")
    print(f"coverage: {covered}/{total} objectives fully covered" + (f"; missing: {empty}" if empty else ""))
    return not empty


# --------------------------------------------------------------------------- main

def main(argv):
    if not argv:
        print(__doc__)
        return 2
    cmd, rest = argv[0], argv[1:]
    ok = True
    if cmd in ("examples", "all"):
        ok &= cmd_examples(rest if cmd == "examples" else [])
    if cmd in ("questions", "all"):
        ok &= cmd_questions(rest if cmd == "questions" else [])
    if cmd in ("coverage", "all"):
        ok &= cmd_coverage()
    print("RESULT:", "OK" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
