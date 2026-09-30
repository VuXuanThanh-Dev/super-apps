#!/usr/bin/env python3
"""Import a Task 5 dataset (JSON) into the SQLite file the Flutter app reads.

Input : a dataset.json with the schema of apps/toeic (src/data/types.ts):
        apps/toeic/private-data/dataset.json (book-derived, private) or
        apps/toeic/src/data/sample/dataset.json (public sample).
Output: one SQLite file, e.g. private-data/toeic.db or assets/data/sample.db.

Lossless check: after writing, the script reads the SQLite file back into JSON
(`export_dataset`) and compares it with the input, field by field. Any
difference -> exit code 1. Counts are printed as JSON.

Usage (from apps/toeic-flutter/):
    python3 tools/import_dataset.py <dataset.json> <out.db>
    python3 tools/import_dataset.py --export <db> <out.json>   # SQLite -> JSON
Only Python 3 standard library (json, sqlite3).
"""
import json
import os
import sqlite3
import sys

SCHEMA_VERSION = 1

SCHEMA = """
PRAGMA user_version = %d;
CREATE TABLE meta (key TEXT PRIMARY KEY NOT NULL, value TEXT NOT NULL);
CREATE TABLE topics (code TEXT PRIMARY KEY NOT NULL, book TEXT NOT NULL, en TEXT NOT NULL, vi TEXT NOT NULL,
  ord INTEGER NOT NULL);
CREATE TABLE families (id TEXT PRIMARY KEY NOT NULL, headword TEXT NOT NULL, topic TEXT NOT NULL,
  book TEXT NOT NULL, band850 INTEGER NOT NULL, tip TEXT, page INTEGER, ord INTEGER NOT NULL);
CREATE TABLE family_members (family_id TEXT NOT NULL, word_id TEXT NOT NULL, pos INTEGER NOT NULL,
  PRIMARY KEY (family_id, pos));
CREATE TABLE words (id TEXT PRIMARY KEY NOT NULL, word TEXT NOT NULL, lemma TEXT NOT NULL, pos TEXT NOT NULL,
  ipa TEXT, ipa_source TEXT, definition TEXT, example TEXT, vi TEXT, note TEXT, topic TEXT NOT NULL,
  book TEXT NOT NULL, family TEXT NOT NULL, is_head INTEGER NOT NULL, ord INTEGER NOT NULL);
CREATE INDEX idx_words_word ON words (word COLLATE NOCASE);
CREATE TABLE word_families (word_id TEXT NOT NULL, family_id TEXT NOT NULL, pos INTEGER NOT NULL,
  PRIMARY KEY (word_id, pos));
CREATE TABLE collocations (id TEXT PRIMARY KEY NOT NULL, family TEXT NOT NULL, phrase TEXT NOT NULL,
  vi TEXT NOT NULL, example TEXT NOT NULL, ord INTEGER NOT NULL);
CREATE TABLE passages (id TEXT PRIMARY KEY NOT NULL, topic TEXT NOT NULL, title TEXT NOT NULL,
  text TEXT NOT NULL, ord INTEGER NOT NULL);
CREATE TABLE questions (passage_id TEXT NOT NULL, pos INTEGER NOT NULL, question TEXT NOT NULL,
  options TEXT NOT NULL, answer INTEGER NOT NULL, PRIMARY KEY (passage_id, pos));
CREATE TABLE glosses (word TEXT PRIMARY KEY NOT NULL, pos TEXT NOT NULL, definition TEXT NOT NULL,
  ord INTEGER NOT NULL);
""" % SCHEMA_VERSION


def import_dataset(ds, out_path):
    if os.path.exists(out_path):
        os.remove(out_path)
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    con = sqlite3.connect(out_path)
    con.executescript(SCHEMA)
    with con:
        con.executemany("INSERT INTO meta VALUES (?, ?)", [
            ("version", str(ds["version"])),
            ("source", ds["source"]),
            ("schema", str(SCHEMA_VERSION)),
        ])
        con.executemany("INSERT INTO topics VALUES (?, ?, ?, ?, ?)",
                        [(t["code"], t["book"], t["en"], t["vi"], i) for i, t in enumerate(ds["topics"])])
        con.executemany("INSERT INTO families VALUES (?, ?, ?, ?, ?, ?, ?, ?)", [
            (f["id"], f["headword"], f["topic"], f["book"], 1 if f["band850"] else 0, f["tip"], f["page"], i)
            for i, f in enumerate(ds["families"])])
        con.executemany("INSERT INTO family_members VALUES (?, ?, ?)",
                        [(f["id"], m, j) for f in ds["families"] for j, m in enumerate(f["members"])])
        con.executemany("INSERT INTO words VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [
            (w["id"], w["word"], w["lemma"], w["pos"], w["ipa"], w["ipaSource"], w["definition"], w["example"],
             w["vi"], w["note"], w["topic"], w["book"], w["family"], 1 if w["isHead"] else 0, i)
            for i, w in enumerate(ds["words"])])
        con.executemany("INSERT INTO word_families VALUES (?, ?, ?)",
                        [(w["id"], fid, j) for w in ds["words"] for j, fid in enumerate(w["families"])])
        con.executemany("INSERT INTO collocations VALUES (?, ?, ?, ?, ?, ?)", [
            (c["id"], c["family"], c["phrase"], c["vi"], c["example"], i) for i, c in enumerate(ds["collocations"])])
        con.executemany("INSERT INTO passages VALUES (?, ?, ?, ?, ?)", [
            (p["id"], p["topic"], p["title"], p["text"], i) for i, p in enumerate(ds["passages"])])
        con.executemany("INSERT INTO questions VALUES (?, ?, ?, ?, ?)", [
            (p["id"], j, q["question"], json.dumps(q["options"], ensure_ascii=False), q["answer"])
            for p in ds["passages"] for j, q in enumerate(p["questions"])])
        con.executemany("INSERT INTO glosses VALUES (?, ?, ?, ?)", [
            (k, g["pos"], g["definition"], i) for i, (k, g) in enumerate(ds["glosses"].items())])
    con.execute("VACUUM")
    con.close()


def export_dataset(db_path):
    """Read the SQLite file back into the Task 5 JSON schema (same order)."""
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row
    q = lambda sql, *a: con.execute(sql, a).fetchall()  # noqa: E731
    meta = {r["key"]: r["value"] for r in q("SELECT * FROM meta")}
    members, word_fams, questions = {}, {}, {}
    for r in q("SELECT * FROM family_members ORDER BY family_id, pos"):
        members.setdefault(r["family_id"], []).append(r["word_id"])
    for r in q("SELECT * FROM word_families ORDER BY word_id, pos"):
        word_fams.setdefault(r["word_id"], []).append(r["family_id"])
    for r in q("SELECT * FROM questions ORDER BY passage_id, pos"):
        questions.setdefault(r["passage_id"], []).append(
            {"question": r["question"], "options": json.loads(r["options"]), "answer": r["answer"]})
    ds = {
        "version": int(meta["version"]),
        "source": meta["source"],
        "topics": [{"code": r["code"], "book": r["book"], "en": r["en"], "vi": r["vi"]}
                   for r in q("SELECT * FROM topics ORDER BY ord")],
        "families": [{"id": r["id"], "headword": r["headword"], "topic": r["topic"], "book": r["book"],
                      "band850": bool(r["band850"]), "members": members.get(r["id"], []), "tip": r["tip"],
                      "page": r["page"]} for r in q("SELECT * FROM families ORDER BY ord")],
        "words": [{"id": r["id"], "word": r["word"], "lemma": r["lemma"], "pos": r["pos"], "ipa": r["ipa"],
                   "ipaSource": r["ipa_source"], "definition": r["definition"], "example": r["example"],
                   "vi": r["vi"], "note": r["note"], "topic": r["topic"], "book": r["book"], "family": r["family"],
                   "families": word_fams.get(r["id"], []), "isHead": bool(r["is_head"])}
                  for r in q("SELECT * FROM words ORDER BY ord")],
        "collocations": [{"id": r["id"], "family": r["family"], "phrase": r["phrase"], "vi": r["vi"],
                          "example": r["example"]} for r in q("SELECT * FROM collocations ORDER BY ord")],
        "passages": [{"id": r["id"], "topic": r["topic"], "title": r["title"], "text": r["text"],
                      "questions": questions.get(r["id"], [])} for r in q("SELECT * FROM passages ORDER BY ord")],
        "glosses": {r["word"]: {"pos": r["pos"], "definition": r["definition"]}
                    for r in q("SELECT * FROM glosses ORDER BY ord")},
    }
    con.close()
    return ds


def counts(ds):
    return {
        "source": ds["source"],
        "topics": len(ds["topics"]),
        "families": len(ds["families"]),
        "words": len(ds["words"]),
        "collocations": len(ds["collocations"]),
        "passages": len(ds["passages"]),
        "questions": sum(len(p["questions"]) for p in ds["passages"]),
        "glosses": len(ds["glosses"]),
    }


def first_difference(a, b, path="$"):
    if type(a) is not type(b):
        return f"{path}: type {type(a).__name__} != {type(b).__name__}"
    if isinstance(a, dict):
        if list(a.keys()) != list(b.keys()) and set(a.keys()) != set(b.keys()):
            return f"{path}: keys {sorted(set(a) ^ set(b))}"
        for k in a:
            d = first_difference(a[k], b[k], f"{path}.{k}")
            if d:
                return d
        return None
    if isinstance(a, list):
        if len(a) != len(b):
            return f"{path}: length {len(a)} != {len(b)}"
        for i, (x, y) in enumerate(zip(a, b)):
            d = first_difference(x, y, f"{path}[{i}]")
            if d:
                return d
        return None
    return None if a == b else f"{path}: {a!r} != {b!r}"


def main(argv):
    if len(argv) == 4 and argv[1] == "--export":
        ds = export_dataset(argv[2])
        with open(argv[3], "w", encoding="utf-8") as fh:
            json.dump(ds, fh, ensure_ascii=False, indent=1)
        print(json.dumps(counts(ds)))
        return 0
    if len(argv) != 3:
        print(__doc__)
        return 2
    src, out = argv[1], argv[2]
    with open(src, encoding="utf-8") as fh:
        ds = json.load(fh)
    import_dataset(ds, out)
    back = export_dataset(out)
    diff = first_difference(ds, back)
    c_in, c_out = counts(ds), counts(back)
    print(json.dumps({"in": c_in, "db": c_out, "lossless": diff is None and ds == back and c_in == c_out}, ensure_ascii=False))
    if diff or ds != back:
        print("NOT LOSSLESS:", diff or "values differ")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
