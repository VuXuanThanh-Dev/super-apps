#!/usr/bin/env python3
"""Compare my definitions (data/authored) with the book's English definitions.
Lists pairs with similarity >= threshold (default 0.8). Needs private-data/extracted/entries.json."""
import difflib
import glob
import json
import os
import sys

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
threshold = float(sys.argv[1]) if len(sys.argv) > 1 else 0.8
src = os.path.join(APP, "private-data", "extracted", "entries.json")
if not os.path.exists(src):
    print("SKIP: no private-data/extracted/entries.json")
    sys.exit(0)
book = {e["headword"].lower(): e["enBook"] for e in json.load(open(src, encoding="utf-8"))}
mine = {}
for p in glob.glob(os.path.join(APP, "data", "authored", "definitions", "*.txt")):
    for line in open(p, encoding="utf-8"):
        parts = line.strip().split("|")
        if len(parts) == 4:
            mine[parts[0]] = parts[2]
flag = []
for w, b in book.items():
    m = mine.get(w)
    if m and b:
        r = difflib.SequenceMatcher(None, m.lower(), b.lower()).ratio()
        if r >= threshold:
            flag.append((round(r, 2), w))
print(f"{len(flag)} of {len(book)} headword definitions have similarity >= {threshold}")
for f in sorted(flag, reverse=True):
    print(" ", f)
sys.exit(1 if flag else 0)
