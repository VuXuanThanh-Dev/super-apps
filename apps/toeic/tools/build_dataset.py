#!/usr/bin/env python3
"""Build the full app dataset from the extracted book entries.

Inputs
  private-data/extracted/entries.json   (book-derived, from extract_books.py)
  data/authored/definitions/*.txt       (my own simple definitions + examples)
  data/authored/passages.json           (my own reading passages, optional)
  src/content/dialogs.json              (my own roleplay dialogs; for glosses)
  CMUdict (pip package `cmudict`, BSD-style) -> IPA for word forms
  WordNet 3.0 (via nltk data, WordNet license) -> fallback glosses
Outputs (book-derived, so ONLY in private-data/)
  private-data/dataset.json   app dataset (same schema as src/data/sample/dataset.json)
  private-data/toeic.db       SQLite copy of the same data
Usage: python3 tools/build_dataset.py   (run from apps/toeic/)
"""
import glob
import json
import os
import re
import sqlite3
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.dirname(HERE)
PRIV = os.path.join(APP, "private-data")
sys.path.insert(0, HERE)
from ipa import arpabet_to_ipa  # noqa: E402

try:
    import cmudict
    CMU = cmudict.dict()
except ImportError:  # pragma: no cover
    CMU = {}
    print("WARN: cmudict not installed, IPA for word forms will be empty")

try:
    from nltk.corpus import wordnet as wn
    wn.synsets("test")
except Exception:  # pragma: no cover
    wn = None
    print("WARN: WordNet (nltk) not available, no fallback glosses")

DATASET_VERSION = 1
PLURAL_ONLY = re.compile(r"\(pl\)")
STOPWORDS = set(json.load(open(os.path.join(APP, "src", "content", "function-words.json"), encoding="utf-8")).keys()) \
    if os.path.exists(os.path.join(APP, "src", "content", "function-words.json")) else set()


def clean_word(w):
    w = re.sub(r"\((US|UK|ad|specs)\)", "", w)
    w = w.replace("(s)", "").replace("(stock) ", "stock ")
    return re.sub(r"\s+", " ", w).strip()


def ipa_for(word):
    parts = re.split(r"[- ]", word.lower())
    out = []
    for p in parts:
        if not p:
            continue
        if p not in CMU:
            return None
        out.append(arpabet_to_ipa(CMU[p][0]))
    return "/" + " ".join(out) + "/" if out else None


def load_authored():
    defs = {}
    for path in sorted(glob.glob(os.path.join(APP, "data", "authored", "definitions", "*.txt"))):
        for line in open(path, encoding="utf-8"):
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split("|")
            if len(parts) != 4:
                sys.exit(f"bad line in {path}: {line}")
            word, pos, definition, example = parts
            defs.setdefault(word.lower(), {"pos": pos, "definition": definition, "example": example})
    return defs


def singular(word):
    if word.endswith("ies"):
        return word[:-3] + "y"
    if word.endswith("s") and not word.endswith("ss"):
        return word[:-1]
    return word


def main():
    src = os.path.join(PRIV, "extracted", "entries.json")
    if not os.path.exists(src):
        sys.exit("Run tools/extract_books.py first (private-data/extracted/entries.json missing)")
    entries = json.load(open(src, encoding="utf-8"))
    authored = load_authored()
    topics, families, words, collocations = {}, [], {}, []
    missing_def, ipa_missing = [], []

    def add_word(word, pos, vi, fam_id, topic, book, is_head, ipa=None, ipa_src=None, note=None):
        key = word.lower()
        if key in words:
            w = words[key]
            if fam_id not in w["families"]:
                w["families"].append(fam_id)
            return w["id"]
        a = authored.get(key)
        if a is None:
            missing_def.append(word)
        if ipa is None:
            ipa = ipa_for(word)
            ipa_src = "cmudict" if ipa else None
        if ipa is None:
            ipa_missing.append(word)
        lemma = singular(key) if PLURAL_ONLY.search(pos or "") else key
        wid = f"w{len(words) + 1}"
        words[key] = {
            "id": wid, "word": word, "lemma": lemma, "pos": pos, "ipa": ipa, "ipaSource": ipa_src,
            "definition": a["definition"] if a else None,
            "example": a["example"] if a else None,
            "vi": vi or None, "note": note, "topic": topic, "book": book,
            "family": fam_id, "families": [fam_id], "isHead": is_head,
        }
        return wid

    for e in entries:
        topics.setdefault(e["topic"], {"code": e["topic"], "book": e["book"], "en": e["topicEn"], "vi": e["topicVi"]})
        fam_id = f"f{len(families) + 1}"
        members = []
        ipa = e["ipa"] or None
        members.append(add_word(e["headword"], "/".join(e["pos"]), e["vi"], fam_id, e["topic"], e["book"], True,
                                ipa=ipa, ipa_src="book" if ipa else None))
        for f in e["family"]:
            w = clean_word(f["word"])
            if not w or w.startswith("-"):
                w = w.lstrip("-")
            members.append(add_word(w, f["pos"], f["vi"], fam_id, e["topic"], e["book"], False, note=f.get("note")))
        for c in e["collocations"]:
            collocations.append({"id": f"c{len(collocations) + 1}", "family": fam_id, "phrase": c["phrase"],
                                 "vi": c["vi"], "example": c["example"]})
        families.append({"id": fam_id, "headword": e["headword"], "topic": e["topic"], "book": e["book"],
                         "band850": e["band850"], "members": list(dict.fromkeys(members)), "tip": e["tip"] or None,
                         "page": e["page"]})

    passages_path = os.path.join(APP, "data", "authored", "passages.json")
    passages = json.load(open(passages_path, encoding="utf-8")) if os.path.exists(passages_path) else []

    # WordNet fallback glosses for every other word the app can show
    texts = [w["example"] or "" for w in words.values()] + [c["example"] for c in collocations]
    for p in passages:
        texts.append(p["text"])
        for q in p.get("questions", []):
            texts.append(q["question"])
            texts.extend(q["options"])
    dpath = os.path.join(APP, "src", "content", "dialogs.json")
    if os.path.exists(dpath):
        for d in json.load(open(dpath, encoding="utf-8")):
            texts.extend(line["text"] for line in d["lines"])
    glosses = {}
    if wn is not None:
        known = set(words) | {w["lemma"] for w in words.values()}
        for t in texts:
            for tok in re.findall(r"[A-Za-z]+(?:'[A-Za-z]+)?", t):
                low = tok.lower()
                if low in known or low in glosses or low in STOPWORDS or "'" in low:
                    continue
                base = wn.morphy(low) or low
                if base in known:
                    continue
                syns = wn.synsets(base)
                if not syns:
                    continue
                # most frequent sense for this lemma (SemCor counts), first sense on ties
                s = max(syns, key=lambda syn: sum(l.count() for l in syn.lemmas() if l.name().lower() == base))
                glosses[base] = {"pos": {"n": "n", "v": "v", "a": "adj", "s": "adj", "r": "adv"}[s.pos()],
                                 "definition": s.definition()}

    dataset = {
        "version": DATASET_VERSION,
        "source": "private",
        "topics": sorted(topics.values(), key=lambda t: t["code"]),
        "families": families,
        "words": list(words.values()),
        "collocations": collocations,
        "passages": passages,
        "glosses": glosses,
    }
    with open(os.path.join(PRIV, "dataset.json"), "w", encoding="utf-8") as fh:
        json.dump(dataset, fh, ensure_ascii=False, separators=(",", ":"))
    write_sqlite(dataset, os.path.join(PRIV, "toeic.db"))
    stats = {
        "topics": len(topics), "families": len(families), "words": len(words),
        "collocations": len(collocations), "passages": len(passages), "glosses": len(glosses),
        "missing_definition": missing_def, "missing_ipa": ipa_missing,
        "ipa_book": sum(1 for w in words.values() if w["ipaSource"] == "book"),
        "ipa_cmudict": sum(1 for w in words.values() if w["ipaSource"] == "cmudict"),
    }
    with open(os.path.join(PRIV, "build-stats.json"), "w", encoding="utf-8") as fh:
        json.dump(stats, fh, ensure_ascii=False, indent=1)
    print(json.dumps({k: (v if not isinstance(v, list) else len(v)) for k, v in stats.items()}))
    if missing_def:
        print("missing definitions:", missing_def)
    if ipa_missing:
        print("missing IPA:", ipa_missing)


def write_sqlite(ds, path):
    if os.path.exists(path):
        os.remove(path)
    con = sqlite3.connect(path)
    con.executescript("""
    CREATE TABLE topics(code TEXT PRIMARY KEY, book TEXT, en TEXT, vi TEXT);
    CREATE TABLE families(id TEXT PRIMARY KEY, headword TEXT, topic TEXT, book TEXT, band850 INTEGER, tip TEXT, page INTEGER);
    CREATE TABLE words(id TEXT PRIMARY KEY, word TEXT UNIQUE, lemma TEXT, pos TEXT, ipa TEXT, ipa_source TEXT,
      definition TEXT, example TEXT, vi TEXT, note TEXT, topic TEXT, book TEXT, family TEXT, is_head INTEGER);
    CREATE TABLE family_members(family TEXT, word_id TEXT, PRIMARY KEY(family, word_id));
    CREATE TABLE collocations(id TEXT PRIMARY KEY, family TEXT, phrase TEXT, vi TEXT, example TEXT);
    CREATE TABLE passages(id TEXT PRIMARY KEY, topic TEXT, title TEXT, text TEXT, questions_json TEXT);
    CREATE TABLE glosses(word TEXT PRIMARY KEY, pos TEXT, definition TEXT);
    CREATE INDEX idx_words_lemma ON words(lemma);
    CREATE INDEX idx_words_topic ON words(topic);
    """)
    con.executemany("INSERT INTO topics VALUES(?,?,?,?)", [(t["code"], t["book"], t["en"], t["vi"]) for t in ds["topics"]])
    con.executemany("INSERT INTO families VALUES(?,?,?,?,?,?,?)",
                    [(f["id"], f["headword"], f["topic"], f["book"], int(f["band850"]), f["tip"], f["page"]) for f in ds["families"]])
    con.executemany("INSERT INTO words VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                    [(w["id"], w["word"], w["lemma"], w["pos"], w["ipa"], w["ipaSource"], w["definition"], w["example"],
                      w["vi"], w["note"], w["topic"], w["book"], w["family"], int(w["isHead"])) for w in ds["words"]])
    con.executemany("INSERT INTO family_members VALUES(?,?)", [(f["id"], m) for f in ds["families"] for m in f["members"]])
    con.executemany("INSERT INTO collocations VALUES(?,?,?,?,?)",
                    [(c["id"], c["family"], c["phrase"], c["vi"], c["example"]) for c in ds["collocations"]])
    con.executemany("INSERT INTO passages VALUES(?,?,?,?,?)",
                    [(p["id"], p["topic"], p["title"], p["text"], json.dumps(p.get("questions", []), ensure_ascii=False)) for p in ds["passages"]])
    con.executemany("INSERT INTO glosses VALUES(?,?,?)", [(k, v["pos"], v["definition"]) for k, v in ds["glosses"].items()])
    con.commit()
    con.close()


if __name__ == "__main__":
    main()
