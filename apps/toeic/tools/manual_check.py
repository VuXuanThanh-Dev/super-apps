#!/usr/bin/env python3
"""Print N random dataset entries next to the matching PDF page text, for a manual check.
Output goes to private-data/manual-check-sample.txt (book text!). Usage: python3 tools/manual_check.py [N] [seed]"""
import json
import os
import random
import sys

import pymupdf

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.dirname(os.path.dirname(APP))
n = int(sys.argv[1]) if len(sys.argv) > 1 else 50
seed = int(sys.argv[2]) if len(sys.argv) > 2 else 20260928
d = json.load(open(os.path.join(APP, "private-data", "dataset.json"), encoding="utf-8"))
fam = {f["id"]: f for f in d["families"]}
docs = {"tap1": pymupdf.open(os.path.join(REPO, "TOEIC-900-Word-Families-Collocations-Tap1.pdf")),
        "tap2": pymupdf.open(os.path.join(REPO, "TOEIC-900-Word-Families-Collocations-Tap2.pdf"))}
random.seed(seed)
out = []
for i, w in enumerate(random.sample(d["words"], n), 1):
    f = fam[w["family"]]
    lines = docs[w["book"]][f["page"] - 1].get_text().splitlines()
    idx = [k for k, l in enumerate(lines) if l.strip().startswith(w["word"].split()[0])]
    ctx = " | ".join(lines[idx[0]:idx[0] + 3]) if idx else "NOT FOUND ON PAGE"
    out.append(f"{i}. {w['word']} [{w['pos']}] ipa={w['ipa']} ({w['ipaSource']}) vi={w['vi']} topic={w['topic']} head={f['headword']} p{f['page']}\n"
               f"   def={w['definition']}\n   ex={w['example']}\n   PDF: {ctx[:200]}")
text = "\n".join(out)
open(os.path.join(APP, "private-data", "manual-check-sample.txt"), "w", encoding="utf-8").write(text + "\n")
print(text)
