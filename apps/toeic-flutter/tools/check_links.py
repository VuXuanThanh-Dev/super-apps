#!/usr/bin/env python3
"""Link checker for the Markdown files of this app (README, DATA-REPORT, PLAN, PROGRESS, private-data/README).

- github.com/<owner>/<repo>/blob/<ref>/<path> links are checked through raw.githubusercontent.com
  (github.com itself is blocked for curl in the build sandbox).
- Hosts blocked by the sandbox (docs.flutter.dev, dart.dev, ...) are reported as BLOCKED, not as broken.
- Relative links are checked on disk.
Usage (from apps/toeic-flutter/): python3 tools/check_links.py
"""
import glob
import os
import re
import subprocess
import sys

BLOCKED = ("docs.flutter.dev", "api.flutter.dev", "dart.dev")
FILES = ["README.md", "DATA-REPORT.md", "PLAN.md", "PROGRESS.md", "private-data/README.md"]
URL = re.compile(r"https?://[^\s)>\]`'\"]+")
REL = re.compile(r"\]\((?!https?://|#)([^)\s]+)\)")


def http_ok(url):
    r = subprocess.run(["curl", "-sS", "-o", "/dev/null", "-L", "-w", "%{http_code}", "--max-time", "20", url],
                       capture_output=True, text=True)
    return r.stdout.strip()


def main():
    bad, blocked, ok = [], [], 0
    seen = set()
    for f in FILES:
        if not os.path.exists(f):
            continue
        text = open(f, encoding="utf-8").read()
        for rel in REL.findall(text):
            path = os.path.normpath(os.path.join(os.path.dirname(f), rel.split("#")[0]))
            if os.path.exists(path):
                ok += 1
            else:
                bad.append((f, rel, "missing file"))
        for url in URL.findall(text):
            url = url.rstrip(".,;:")
            if "<" in url:  # placeholder such as http://<IP-máy-tính>:8080
                continue
            if url.endswith(".git"):
                url = url[:-4]
            if url in seen:
                continue
            seen.add(url)
            host = url.split("/")[2]
            if host.endswith(BLOCKED):
                blocked.append(url)
                continue
            check = url
            m = re.match(r"https://github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)", url)
            if m:
                check = "https://raw.githubusercontent.com/%s/%s/%s/%s" % m.groups()
            elif host == "github.com":
                check = "https://api.github.com/repos/" + "/".join(url.split("/")[3:5])
            code = http_ok(check)
            if code.startswith("2"):
                ok += 1
            elif code in ("403", "000"):
                blocked.append(f"{url} (HTTP {code})")
            else:
                bad.append((f, url, f"HTTP {code}"))
    print(f"OK: {ok}  BLOCKED by sandbox (not checked): {len(blocked)}  BROKEN: {len(bad)}")
    for b in blocked:
        print("  blocked:", b)
    for f, u, why in bad:
        print(f"  BROKEN in {f}: {u} ({why})")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
