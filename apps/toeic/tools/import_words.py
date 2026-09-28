#!/usr/bin/env python3
"""Add your own words to the app.

File format (UTF-8 text, one word per line, fields separated by "|"):
    word|pos|simple English definition|example sentence|Vietnamese meaning|topic code (optional)|collocations (optional)
collocations = "phrase = nghĩa = example" items separated by ";"
Lines starting with # are comments. Example:
    deadline|n|the last day or time to finish something|The deadline for the report is Friday.|hạn chót|MY|meet a deadline = kịp hạn chót = We worked late to meet the deadline.

Usage (from apps/toeic/):
    python3 tools/import_words.py my-words.txt
The file is copied to private-data/my-words/ and merged into private-data/dataset.json
(created from the sample dataset if it does not exist). build_dataset.py merges
private-data/my-words/*.txt again every time it runs, so your words are kept.
Restart Metro with `npx expo start -c` afterwards so the app picks up the new dataset.
"""
import glob
import json
import os
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.dirname(HERE)
PRIV = os.path.join(APP, "private-data")
MY_DIR = os.path.join(PRIV, "my-words")
MY_TOPIC = {"code": "MY", "book": "mine", "en": "My words", "vi": "Từ của tôi"}


def parse_file(path):
    rows = []
    for n, raw in enumerate(open(path, encoding="utf-8"), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = [p.strip() for p in line.split("|")]
        if len(parts) < 5:
            raise ValueError(f"{path}:{n}: need at least 5 fields (word|pos|definition|example|vi)")
        word, pos, definition, example, vi = parts[:5]
        if not word:
            raise ValueError(f"{path}:{n}: empty word")
        topic = parts[5] if len(parts) > 5 and parts[5] else "MY"
        cols = []
        if len(parts) > 6 and parts[6]:
            for item in parts[6].split(";"):
                bits = [b.strip() for b in item.split("=")]
                if len(bits) != 3:
                    raise ValueError(f"{path}:{n}: collocation must be 'phrase = nghĩa = example'")
                cols.append({"phrase": bits[0], "vi": bits[1], "example": bits[2]})
        rows.append({"word": word, "pos": pos, "definition": definition, "example": example, "vi": vi,
                     "topic": topic, "collocations": cols})
    return rows


def _ipa(word):
    try:
        sys.path.insert(0, HERE)
        from build_dataset import ipa_for
        return ipa_for(word)
    except Exception:
        return None


def merge(ds, rows):
    """Add or update rows in the dataset (in place). Returns (added, updated)."""
    topics = {t["code"] for t in ds["topics"]}
    by_word = {w["word"].lower(): w for w in ds["words"]}
    added = updated = 0
    for r in rows:
        if r["topic"] not in topics:
            ds["topics"].append(dict(MY_TOPIC) if r["topic"] == "MY" else
                                {"code": r["topic"], "book": "mine", "en": r["topic"], "vi": r["topic"]})
            topics.add(r["topic"])
        key = r["word"].lower()
        if key in by_word:
            w = by_word[key]
            w.update({k: r[k] for k in ("definition", "example", "vi") if r[k]})
            updated += 1
            fam_id = w["family"]
        else:
            fam_id = f"mf{len(ds['families']) + 1}"
            wid = f"mw{len(ds['words']) + 1}"
            ipa = _ipa(r["word"])
            w = {"id": wid, "word": r["word"], "lemma": key, "pos": r["pos"], "ipa": ipa,
                 "ipaSource": "cmudict" if ipa else None, "definition": r["definition"], "example": r["example"],
                 "vi": r["vi"], "note": None, "topic": r["topic"], "book": "mine", "family": fam_id,
                 "families": [fam_id], "isHead": True}
            ds["words"].append(w)
            ds["families"].append({"id": fam_id, "headword": r["word"], "topic": r["topic"], "book": "mine",
                                   "band850": False, "members": [wid], "tip": None, "page": None})
            by_word[key] = w
            added += 1
        for c in r["collocations"]:
            if not any(x["family"] == fam_id and x["phrase"] == c["phrase"] for x in ds["collocations"]):
                ds["collocations"].append({"id": f"mc{len(ds['collocations']) + 1}", "family": fam_id, **c})
    return added, updated


def merge_all_my_words(ds):
    added = updated = 0
    for path in sorted(glob.glob(os.path.join(MY_DIR, "*.txt"))):
        a, u = merge(ds, parse_file(path))
        added, updated = added + a, updated + u
    return added, updated


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    src = sys.argv[1]
    rows = parse_file(src)  # validate before copying
    os.makedirs(MY_DIR, exist_ok=True)
    dst = os.path.join(MY_DIR, os.path.basename(src))
    if os.path.abspath(src) != os.path.abspath(dst):
        shutil.copyfile(src, dst)
    ds_path = os.path.join(PRIV, "dataset.json")
    if os.path.exists(ds_path):
        ds = json.load(open(ds_path, encoding="utf-8"))
    else:
        ds = json.load(open(os.path.join(APP, "src", "data", "sample", "dataset.json"), encoding="utf-8"))
        ds["source"] = "private"
    added, updated = merge(ds, rows)
    with open(ds_path, "w", encoding="utf-8") as fh:
        json.dump(ds, fh, ensure_ascii=False, separators=(",", ":"))
    print(f"{len(rows)} line(s) read: {added} added, {updated} updated -> {ds_path}")


if __name__ == "__main__":
    main()
