#!/usr/bin/env python3
"""Check that a Vietnamese handbook chapter follows the required structure.

Required level-2 sections, in this order (extra sections allowed in between):
  Mục tiêu → Giải thích đơn giản → Ví dụ → Đi sâu → Lỗi và bẫy thường gặp → Tóm tắt
  → Bài tập (có lời giải) → Nguồn tham khảo
Also checks:
  - exactly one level-1 title;
  - "Bài tập" has at least one exercise and a solution (a line containing "Lời giải");
  - "Nguồn tham khảo" is the last section and has at least one http(s) link;
  - no TODO/TBD/lorem left in the text.
Usage: check_chapter.py chapter.md [...]   Exit 1 on any problem.
"""
import re
import sys
import unicodedata

REQUIRED = ["Mục tiêu", "Giải thích đơn giản", "Ví dụ", "Đi sâu", "Lỗi và bẫy thường gặp",
            "Tóm tắt", "Bài tập", "Nguồn tham khảo"]


def key(s):
    s = unicodedata.normalize("NFC", s).strip().lower()
    return re.sub(r"^\d+(\.\d+)*[.)]?\s*", "", s)  # allow "1. Mục tiêu"


def check(path):
    text = unicodedata.normalize("NFC", open(path, encoding="utf-8").read())
    text_nocode = re.sub(r"^```.*?^```", "", text, flags=re.S | re.M)
    probs = []
    h1 = re.findall(r"^# (.+)$", text_nocode, re.M)
    if len(h1) != 1:
        probs.append(f"expected 1 level-1 title, found {len(h1)}")
    h2 = [(m.start(), key(m.group(1))) for m in re.finditer(r"^## (.+)$", text_nocode, re.M)]
    pos = 0
    found = {}
    for req in REQUIRED:
        k = req.lower()
        idx = next((i for i in range(pos, len(h2)) if h2[i][1].startswith(k)), None)
        if idx is None:
            probs.append(f"missing or out-of-order section '## {req}'")
        else:
            found[req] = idx
            pos = idx + 1
    def body(req):
        if req not in found:
            return ""
        i = found[req]
        end = h2[i + 1][0] if i + 1 < len(h2) else len(text_nocode)
        return text_nocode[h2[i][0]:end]
    ex = body("Bài tập")
    if ex and "lời giải" not in ex.lower():
        probs.append("'Bài tập' has no 'Lời giải'")
    src = body("Nguồn tham khảo")
    if src:
        if found["Nguồn tham khảo"] != len(h2) - 1:
            probs.append("'Nguồn tham khảo' must be the last section")
        if not re.search(r"https?://", src):
            probs.append("'Nguồn tham khảo' has no link")
    if re.search(r"\b(TODO|TBD|lorem ipsum)\b", text_nocode, re.I):
        probs.append("placeholder text (TODO/TBD/lorem) found")
    return probs


def main():
    bad = 0
    for p in sys.argv[1:]:
        probs = check(p)
        print(("OK   " if not probs else "FAIL ") + p)
        for x in probs:
            print("   - " + x)
        bad += bool(probs)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
