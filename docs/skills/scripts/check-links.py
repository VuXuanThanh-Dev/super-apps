#!/usr/bin/env python3
"""Check links in docs/skills/*.md and our own skill files.

- Relative links must point to existing files.
- External links are fetched with curl (HEAD-like GET, 20 s). github.com blob/tree links are
  checked through raw.githubusercontent.com (same file, same commit), because the sandbox proxy
  blocks plain github.com page requests from curl.
- Results: OK, BROKEN (404/410), BLOCKED (403/proxy/connection error: "blocked by sandbox, not broken").
Exit 1 only on broken relative links or real 404/410.
"""
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
SKIP = ("skill-creator", "webapp-testing")  # reused skills: upstream content, not ours


def files():
    fs = glob.glob(f"{ROOT}/docs/skills/*.md") + glob.glob(f"{ROOT}/.claude/skills/*/SKILL.md") \
        + glob.glob(f"{ROOT}/.claude/skills/*/references/*.md")
    return [f for f in fs if not any(s in f for s in SKIP)]


def to_raw(u):
    m = re.match(r"https://github\.com/([^/]+)/([^/]+)/(?:blob|tree)/([^/]+)/(.+)$", u)
    if m:
        path = m.group(4)
        if "/tree/" in u:
            path += "/SKILL.md"
        return f"https://raw.githubusercontent.com/{m.group(1)}/{m.group(2)}/{m.group(3)}/{path}"
    m = re.match(r"https://github\.com/([^/]+)/([^/]+)/?$", u)
    if m:
        return f"https://raw.githubusercontent.com/{m.group(1)}/{m.group(2)}/HEAD/README.md"
    return u


def status(u):
    p = subprocess.run(["curl", "-s", "-o", "/dev/null", "-L", "-w", "%{http_code}", "--max-time", "20", u],
                       capture_output=True, text=True)
    return p.stdout.strip() or "000"


def main():
    bad, ext = [], {}
    for f in files():
        t = open(f, encoding="utf-8").read()
        for m in re.findall(r"\]\(([^)\s]+)\)", t):
            if m.startswith("http"):
                ext.setdefault(m.split("#")[0], f)
            elif not m.startswith("mailto:"):
                p = os.path.normpath(os.path.join(os.path.dirname(f), m.split("#")[0]))
                if not os.path.exists(p):
                    bad.append(f"BROKEN relative {m} in {os.path.relpath(f, ROOT)}")
        for m in re.findall(r"(?<![(\[])(https?://[^\s)`|>\"']+)", t):
            ext.setdefault(m.rstrip(".,;"), f)
    blocked = 0
    for u in sorted(ext):
        if "<" in u or "example.com" in u:
            continue
        code = status(to_raw(u))
        if code.startswith("2"):
            print(f"OK      {code} {u}")
        elif code in ("404", "410"):
            print(f"BROKEN  {code} {u}")
            bad.append(u)
        else:
            print(f"BLOCKED {code} {u}  (blocked by sandbox, not broken)")
            blocked += 1
    for b in bad:
        print(b)
    print(f"\n{len(ext)} external links, {len(bad)} broken, {blocked} blocked by sandbox")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
