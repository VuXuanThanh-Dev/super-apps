#!/usr/bin/env python3
"""List vocabulary candidates from an English text (for TOEIC word lists).

Deterministic helper: it does NOT decide which words are useful; the model does that.
- Tokenises, lowercases, reduces each word to a base form: optional irregular map
  (JSON {"went": "go"}) > simplemma (MIT, `pip install simplemma`, offline) > small suffix rules.
- Drops function words (built-in list), numbers, words shorter than --min-len.
- --known FILE...: words to skip. Accepts .txt (one word per line, or the TOEIC app's
  "word|pos|definition|example" lines) and .json (TOEIC app dataset: words[].word).
- Finds two-word collocation candidates: adjacent content words seen >= --min-bigram times.
- Keeps the first sentence where each lemma appears (for an example / context).
Output: JSON to stdout {"lemmas": [...], "bigrams": [...], "stats": {...}}.
Usage: extract_candidates.py text.txt [--known a.txt b.json] [--irregular irr.json]
                             [--min-len 3] [--min-bigram 2] [--top 60]
"""
import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path

FUNCTION_WORDS = set("""
a about above after again against all also am an and any are as at be because been before being
below between both but by can could did do does doing down during each few for from further had
has have having he her here hers herself him himself his how i if in into is it its itself just
let me more most my myself no nor not now of off on once only or other our ours ourselves out over
own same she should so some such than that the their theirs them themselves then there these they
this those through to too under until up very was we were what when where which while who whom why
will with would you your yours yourself yourselves ok yes please thanks thank dear hi hello regards
mr mrs ms get got one two three first next also may might must shall us via per etc
""".split())
WORD_RE = re.compile(r"[A-Za-z]+(?:['’-][A-Za-z]+)*")
SENT_RE = re.compile(r"(?<=[.!?])\s+")


try:
    import simplemma  # MIT, offline dictionary: pip install simplemma
except ImportError:  # pragma: no cover - fallback path
    simplemma = None


def lemma(w: str, irregular: dict, vocab: set) -> str:
    """Base form. irregular map > simplemma (if installed) > small suffix rules."""
    w = w.lower().replace("’", "'")
    if w.endswith("'s"):
        w = w[:-2]
    if w in irregular:
        return irregular[w]
    if simplemma is not None:
        return simplemma.lemmatize(w, lang="en").lower()
    if w.endswith(("ies", "ied")) and len(w) > 4:
        return w[:-3] + "y"
    if w.endswith(("sses", "xes", "zes", "ches", "shes")):
        return w[:-2]
    if w.endswith("s") and not w.endswith(("ss", "us", "is")) and len(w) > 3:
        return w[:-1]
    for suf in ("ing", "ed"):
        if w.endswith(suf) and len(w) > len(suf) + 2:
            stem = w[: -len(suf)]
            if stem + "e" in vocab:
                return stem + "e"
            if len(stem) > 2 and stem[-1] == stem[-2] and stem[-1] not in "lsz":
                return stem[:-1]
            return stem
    return w


def load_known(paths):
    known = set()
    for p in paths:
        text = Path(p).read_text(encoding="utf-8")
        if p.endswith(".json"):
            data = json.loads(text)
            for wd in data.get("words", []):
                known.add(str(wd.get("word", "")).lower())
        else:
            for line in text.splitlines():
                line = line.strip()
                if line and not line.startswith("#"):
                    known.add(line.split("|")[0].strip().lower())
    return known


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("text")
    ap.add_argument("--known", nargs="*", default=[])
    ap.add_argument("--irregular")
    ap.add_argument("--min-len", type=int, default=3)
    ap.add_argument("--min-bigram", type=int, default=2)
    ap.add_argument("--top", type=int, default=60)
    a = ap.parse_args()
    text = Path(a.text).read_text(encoding="utf-8")
    irregular = json.loads(Path(a.irregular).read_text()) if a.irregular else {}
    known = load_known(a.known)
    tokens = [m.group(0) for m in WORD_RE.finditer(text)]
    surface = {t.lower().replace("’", "'") for t in tokens}
    counts, forms, first_sent = Counter(), {}, {}
    sentences = SENT_RE.split(text.strip())
    bigrams = Counter()
    for sent in sentences:
        prev = None
        for m in WORD_RE.finditer(sent):
            w = m.group(0)
            lw = w.lower()
            if lw in FUNCTION_WORDS or len(lw) < a.min_len:
                prev = None
                continue
            lem = lemma(w, irregular, surface)
            if lem in FUNCTION_WORDS:
                prev = None
                continue
            counts[lem] += 1
            forms.setdefault(lem, set()).add(lw)
            first_sent.setdefault(lem, " ".join(sent.split()))
            if prev:
                bigrams[(prev, lem)] += 1
            prev = lem
    lemmas = [
        {"lemma": l, "count": c, "forms": sorted(forms[l]), "known": l in known,
         "context": first_sent[l][:240]}
        for l, c in counts.most_common()
    ]
    new = [x for x in lemmas if not x["known"]][: a.top]
    bis = [{"phrase": f"{x} {y}", "count": c} for (x, y), c in bigrams.most_common()
           if c >= a.min_bigram][:30]
    out = {"lemmas": new, "bigrams": bis,
           "stats": {"lemmatizer": "simplemma" if simplemma else "rules", "tokens": len(tokens), "distinct_lemmas": len(counts),
                     "known_skipped": sum(1 for x in lemmas if x["known"]), "returned": len(new)}}
    json.dump(out, sys.stdout, ensure_ascii=False, indent=1)
    print()


if __name__ == "__main__":
    main()
