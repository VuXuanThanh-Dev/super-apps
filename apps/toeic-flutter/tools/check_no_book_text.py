#!/usr/bin/env python3
"""Leak check: make sure no book text is committed in apps/toeic-flutter (the repo is PUBLIC).

Same approach as Task 5 (apps/toeic/tools/check_no_book_text.py): take long, distinctive strings
from the book extraction (collocation examples, sample sentences, tips, English definitions and
Vietnamese meanings of 20+ chars) and search every git-tracked or not-ignored file of this app
for them. Binary files (e.g. assets/data/sample.db) are searched too: SQLite stores text as UTF-8.
Also fails if any file under private-data/ other than README.md is tracked by git.

Needs the Task 5 extraction: apps/toeic/private-data/extracted/entries.json
(run `bash tools/build_data.sh` first). Without it: SKIP (exit 0).
Usage (from apps/toeic-flutter/): python3 tools/check_no_book_text.py
"""
import json
import os
import subprocess
import sys

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(APP, "..", "toeic", "private-data", "extracted", "entries.json")


def git_files(*args):
    out = subprocess.run(["git", "ls-files", *args, "."], cwd=APP, capture_output=True, text=True, check=True)
    return [f for f in out.stdout.split("\n") if f]


def main():
    tracked = git_files()
    bad = [f for f in tracked if f.startswith("private-data/") and f != "private-data/README.md"]
    if bad:
        print("FAIL: private-data files are tracked by git:", bad)
        return 1
    if not os.path.exists(SRC):
        print("SKIP: ../toeic/private-data/extracted/entries.json not found (run tools/build_data.sh)")
        return 0
    entries = json.load(open(SRC, encoding="utf-8"))
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
    files = tracked + git_files("--others", "--exclude-standard")
    hits, checked = [], 0
    for rel in files:
        if rel.startswith("private-data/") or rel.endswith((".png", ".jpg", ".ttf", ".wasm", ".lock")):
            continue
        path = os.path.join(APP, rel)
        if not os.path.isfile(path):
            continue
        text = open(path, "rb").read().decode("utf-8", errors="ignore")
        checked += 1
        for n in needles:
            if n in text:
                hits.append((rel, n[:80]))
    print(f"checked {checked} files against {len(needles)} book strings: {len(hits)} hit(s)")
    for rel, n in hits[:50]:
        print(f"  {rel}: {n}")
    return 1 if hits else 0


if __name__ == "__main__":
    sys.exit(main())
