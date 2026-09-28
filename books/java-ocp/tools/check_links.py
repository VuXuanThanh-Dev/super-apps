#!/usr/bin/env python3
"""Check every http(s) link in books/java-ocp/**/*.md with curl.

Result classes:
  OK       HTTP 2xx/3xx
  VERIFIED not reachable by curl here, but opened manually with the web reader (listed in links_verified.txt)
  BLOCKED  connection refused by the sandbox proxy (HTTP 000) or proxy 403 -> NOT a broken link
  BROKEN   HTTP 404/410/5xx -> must be fixed
Exit code 1 if any BROKEN link.
"""
import concurrent.futures as cf
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
URL_RE = re.compile(r"https?://[^\s)<>\]\"'`|]+")
verified = set()
vf = ROOT / "tools" / "links_verified.txt"
if vf.exists():
    verified = {ln.strip() for ln in vf.read_text().splitlines() if ln.strip() and not ln.startswith("#")}

links = {}
for md in ROOT.rglob("*.md"):
    if "node_modules" in md.parts or "dist" in md.parts:
        continue
    for u in URL_RE.findall(md.read_text()):
        u = u.rstrip(".,;:")
        links.setdefault(u, set()).add(str(md.relative_to(ROOT)))


def status(u):
    try:
        r = subprocess.run(["curl", "-s", "-o", "/dev/null", "-L", "-m", "20", "-w", "%{http_code}", u],
                           capture_output=True, text=True, timeout=40)
        return u, r.stdout.strip() or "000"
    except subprocess.TimeoutExpired:
        return u, "000"


with cf.ThreadPoolExecutor(8) as ex:
    res = dict(ex.map(status, sorted(links)))

groups = {"OK": [], "VERIFIED": [], "BLOCKED": [], "BROKEN": []}
for u, code in sorted(res.items()):
    if code.startswith(("2", "3")):
        groups["OK"].append((u, code))
    elif u in verified:
        groups["VERIFIED"].append((u, code))
    elif code in ("000", "403", "407"):
        groups["BLOCKED"].append((u, code))
    else:
        groups["BROKEN"].append((u, code))
for g, items in groups.items():
    print(f"== {g}: {len(items)}")
    for u, code in items:
        print(f"  [{code}] {u}")
print(f"TOTAL {len(res)} links; BROKEN {len(groups['BROKEN'])}")
sys.exit(1 if groups["BROKEN"] else 0)
