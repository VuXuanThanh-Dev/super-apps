#!/usr/bin/env python3
"""Convert data/authored/passages.txt (easy to edit) to data/authored/passages.json."""
import json
import os
import sys

APP = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def parse(text):
    passages, cur, q = [], None, None
    for raw in text.splitlines():
        line = raw.rstrip()
        if not line or line.startswith("# "):
            continue
        if line.startswith("## "):
            pid, topic, title = [x.strip() for x in line[3:].split("|")]
            cur = {"id": pid, "topic": topic, "title": title, "text": "", "questions": []}
            passages.append(cur)
            q = None
        elif line.startswith("Q: "):
            q = {"question": line[3:], "options": [], "answer": -1}
            cur["questions"].append(q)
        elif q is not None and line[:2] in ("- ", "* "):
            if line.startswith("* "):
                q["answer"] = len(q["options"])
            q["options"].append(line[2:])
        else:
            cur["text"] = (cur["text"] + "\n" + line).strip()
    for p in passages:
        for q in p["questions"]:
            if q["answer"] < 0 or len(q["options"]) != 4:
                sys.exit(f"bad question in {p['id']}: {q['question']}")
    return passages


if __name__ == "__main__":
    src = sys.argv[1] if len(sys.argv) > 1 else os.path.join(APP, "data", "authored", "passages.txt")
    dst = sys.argv[2] if len(sys.argv) > 2 else os.path.join(APP, "data", "authored", "passages.json")
    ps = parse(open(src, encoding="utf-8").read())
    json.dump(ps, open(dst, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"{len(ps)} passages -> {dst}")
