#!/usr/bin/env python3
"""Leak check: make sure no book text is committed outside private-data/.

Takes long, distinctive strings from the book extraction (collocation examples,
sample sentences, tips, English definitions and Vietnamese meanings of 20+ chars)
and searches every git-tracked file of apps/toeic (except private-data/) for them.
Exit code 1 if anything is found. Needs private-data/extracted/entries.json."""
import json
import os
import subprocess
import sys

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
src = os.path.join(APP, "private-data", "extracted", "entries.json")
if not os.path.exists(src):
    print("SKIP: private-data/extracted/entries.json not found (run tools/extract_books.py)")
    sys.exit(0)
entries = json.load(open(src, encoding="utf-8"))
needles = set()
for e in entries:
    for s in [e["enBook"], e["sample"]["en"], e["sample"]["vi"], e["tip"], e["vi"]]:
        if s and len(s) >= 20:
            needles.add(s)
    for c in e["collocations"]:
        for s in [c["example"], c["vi"]]:
            if s and len(s) >= 20:
                needles.add(s)
    for f in e["family"]:
        if f.get("vi") and len(f["vi"]) >= 20:
            needles.add(f["vi"])
files = subprocess.run(["git", "ls-files", "."], cwd=APP, capture_output=True, text=True, check=True).stdout.split()
files += subprocess.run(["git", "ls-files", "--others", "--exclude-standard", "."], cwd=APP, capture_output=True, text=True, check=True).stdout.split()
hits = []
for rel in files:
    if rel.startswith("private-data/") or rel.endswith((".png", ".ttf", ".jpg", ".lock")) or rel == "package-lock.json":
        continue
    try:
        text = open(os.path.join(APP, rel), encoding="utf-8").read()
    except (UnicodeDecodeError, FileNotFoundError):
        continue
    for n in needles:
        if n in text:
            hits.append((rel, n[:80]))
print(f"checked {len(files)} files against {len(needles)} book strings: {len(hits)} hit(s)")
for rel, n in hits[:50]:
    print(f"  {rel}: {n}")
sys.exit(1 if hits else 0)
