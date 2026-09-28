#!/usr/bin/env python3
"""Build src/features/lookup/irregular.json from the WordNet 3.0 exception lists
(verb.exc, noun.exc, adj.exc). WordNet license: see tools/LICENSES.md.
Maps an irregular form to its base form, e.g. "ran" -> "run", "children" -> "child"."""
import json
import os

import nltk

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    root = nltk.data.find("corpora/wordnet")
    out = {}
    for name in ("verb.exc", "noun.exc", "adj.exc"):
        path = os.path.join(str(root), name)
        for line in open(path, encoding="utf-8"):
            parts = line.split()
            if len(parts) < 2:
                continue
            form, base = parts[0], parts[1]
            if "_" in form or "_" in base or form == base or not form.isalpha():
                continue
            out.setdefault(form, base)
    dst = os.path.join(APP, "src", "features", "lookup", "irregular.json")
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    with open(dst, "w", encoding="utf-8") as fh:
        json.dump(dict(sorted(out.items())), fh, separators=(",", ":"))
    print(f"{len(out)} irregular forms -> {dst}")


if __name__ == "__main__":
    main()
