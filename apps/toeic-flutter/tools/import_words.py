#!/usr/bin/env python3
"""Add your own words to the Flutter app (same text format as Task 5).

File format (UTF-8, one word per line, fields separated by "|"):
    word|pos|simple English definition|example sentence|Vietnamese meaning|topic code (optional)|collocations (optional)
collocations = "phrase = nghĩa = example" items separated by ";". Lines starting with # are comments.
Example: examples/my-words.example.txt

Usage (from apps/toeic-flutter/):
    python3 tools/import_words.py my-words.txt   # validate, copy to private-data/my-words/, rebuild DB
    python3 tools/import_words.py --rebuild      # only rebuild private-data/toeic.db

How it works: the parser and merge rules are REUSED from Task 5
(apps/toeic/tools/import_words.py: parse_file + merge), so both apps accept the same files.
Base dataset = private-data/source/dataset.json (from tools/build_data.sh); if it does not exist,
the public sample (test/fixtures/sample_dataset.json) is used as the base. Every rebuild merges
ALL files in private-data/my-words/ again, so your words are kept. Output: private-data/toeic.db.
Then restart the app (a full restart, not hot reload) so it loads the new database.
"""
import json
import os
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.dirname(HERE)
PRIV = os.path.join(APP, "private-data")
MY_DIR = os.path.join(PRIV, "my-words")
BASE = os.path.join(PRIV, "source", "dataset.json")
SAMPLE = os.path.join(APP, "test", "fixtures", "sample_dataset.json")
OUT_DB = os.path.join(PRIV, "toeic.db")

sys.path.insert(0, os.path.join(APP, "..", "toeic", "tools"))
from import_words import merge, parse_file  # noqa: E402  (Task 5 code, reused)

sys.path.insert(0, HERE)
from import_dataset import main as import_main  # noqa: E402


def rebuild():
    if os.path.exists(BASE):
        ds = json.load(open(BASE, encoding="utf-8"))
    else:
        ds = json.load(open(SAMPLE, encoding="utf-8"))
        ds["source"] = "private"
    added = updated = 0
    files = sorted(f for f in os.listdir(MY_DIR) if f.endswith(".txt")) if os.path.isdir(MY_DIR) else []
    for name in files:
        a, u = merge(ds, parse_file(os.path.join(MY_DIR, name)))
        added, updated = added + a, updated + u
    merged = os.path.join(PRIV, "source", "dataset-merged.json")
    os.makedirs(os.path.dirname(merged), exist_ok=True)
    with open(merged, "w", encoding="utf-8") as fh:
        json.dump(ds, fh, ensure_ascii=False, separators=(",", ":"))
    print(f"my-words: {len(files)} file(s), {added} added, {updated} updated")
    return import_main(["import_dataset.py", merged, OUT_DB])


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    if sys.argv[1] != "--rebuild":
        src = sys.argv[1]
        rows = parse_file(src)  # validate before copying
        os.makedirs(MY_DIR, exist_ok=True)
        dst = os.path.join(MY_DIR, os.path.basename(src))
        if os.path.abspath(src) != os.path.abspath(dst):
            shutil.copyfile(src, dst)
        print(f"{len(rows)} line(s) OK -> {dst}")
    sys.exit(rebuild())


if __name__ == "__main__":
    main()
