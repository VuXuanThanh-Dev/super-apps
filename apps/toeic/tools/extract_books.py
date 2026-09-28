#!/usr/bin/env python3
"""Extract entries from the two TOEIC 900 PDFs in the repo root.

Output (ALL book-derived, written ONLY to apps/toeic/private-data/):
  private-data/raw/<book>.txt            full text, one block per page
  private-data/extracted/entries.json    parsed word-family entries
  private-data/extracted/index.json      the book index (word -> topic)
  private-data/extracted/page-report.json  per-page text/OCR status

The PDFs have a text layer, so text is read with PyMuPDF. A page whose text
layer is (almost) empty but has images is sent to tesseract OCR (fallback).
Usage:  python3 tools/extract_books.py   (run from apps/toeic/)
Needs:  pip install pymupdf==1.28.2 ; tesseract (only for the OCR fallback)
"""
import json
import os
import re
import subprocess
import sys
import tempfile

import pymupdf

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.dirname(HERE)
REPO = os.path.dirname(os.path.dirname(APP))
OUT = os.path.join(APP, "private-data")
BOOKS = [
    ("tap1", "TOEIC-900-Word-Families-Collocations-Tap1.pdf"),
    ("tap2", "TOEIC-900-Word-Families-Collocations-Tap2.pdf"),
]
POS_TAGS = {"n", "v", "adj", "adv", "prep", "conj", "phr v", "phrv", "pron", "det"}

DARK = 0x1C2230
VI_GREY = 0x4A5263
MUTED = 0x7C8494
EX_GREY = 0x3D4556
WHITE = 0xFFFFFF


def spans_of(page):
    out = []
    for b in page.get_text("dict")["blocks"]:
        for l in b.get("lines", []):
            for s in l["spans"]:
                if not s["text"].strip():
                    continue
                x0, y0, x1, y1 = s["bbox"]
                out.append({
                    "x0": x0, "y0": y0, "x1": x1, "y1": y1,
                    "yc": (y0 + y1) / 2,
                    "font": s["font"], "size": round(s["size"], 1),
                    "color": s["color"], "text": s["text"],
                })
    return out


def join_spans(spans):
    """Join spans in reading order, inserting spaces from x-gaps."""
    spans = [s for line in lines_of(spans) for s in line]
    text = ""
    prev = None
    for s in spans:
        t = s["text"]
        if prev is not None:
            same_line = abs(s["yc"] - prev["yc"]) < 4
            gap = s["x0"] - prev["x1"]
            if not same_line or gap > 1.2:
                if not text.endswith(" ") and not t.startswith(" "):
                    text += " "
        text += t
        prev = s
    return re.sub(r"\s+", " ", text).strip()


def lines_of(spans, tol=3.5):
    """Group spans into visual lines."""
    spans = sorted(spans, key=lambda s: (s["yc"], s["x0"]))
    lines = []
    for s in spans:
        if lines and abs(lines[-1][0]["yc"] - s["yc"]) < tol:
            lines[-1].append(s)
        else:
            lines.append([s])
    return [sorted(l, key=lambda s: s["x0"]) for l in lines]


def is_badge(s):
    return s["color"] == WHITE and s["size"] < 7.5


def is_head(s):
    return s["font"].startswith("Type3") and s["size"] > 13


def heading_y(spans, pattern):
    for s in spans:
        if re.sub(r"\s", "", s["text"]).upper().startswith(pattern) and s["size"] < 8 and s["font"].endswith(("Bold", "SemiBold")):
            return s["y0"]
    return None


def split_forms(words, poss, vi):
    words_l = [w.strip() for w in words.split(" / ") if w.strip()]
    vis = [v.strip() for v in vi.split(" / ")] if vi else []
    out = []
    for i, w in enumerate(words_l):
        if len(words_l) == 1:
            pos = "/".join(poss)  # one word with several parts of speech, e.g. "n | adj"
        else:
            pos = poss[i] if i < len(poss) else (poss[-1] if poss else "")
        v = vis[i] if len(vis) == len(words_l) else vi
        out.append({"word": w, "pos": pos, "vi": v})
    return out


def parse_family(spans, left):
    items = []
    for line in lines_of(spans):
        cur = None
        for s in line:
            dark_word = s["color"] == DARK and "SemiBold" in s["font"] and s["size"] >= 8
            if dark_word and (cur is None or cur["vi"] or cur["pos"]):
                cur = {"x0": s["x0"], "words": s["text"], "pos": [], "vi": "", "extra": ""}
                items.append(cur)
            elif dark_word:
                cur["words"] += s["text"]
            elif is_badge(s):
                if cur is None:
                    continue
                cur["pos"].append(s["text"].strip())
            elif cur is not None:
                if s["color"] == MUTED and s["text"].strip().startswith("("):
                    cur["extra"] += s["text"]
                else:
                    cur["vi"] = (cur["vi"] + " " + s["text"]).strip()
            else:
                # continuation of a wrapped meaning: attach to closest item above
                cand = [it for it in items if it["x0"] <= s["x0"] + 2]
                if cand:
                    it = max(cand, key=lambda it: it["x0"])
                    it["vi"] = (it["vi"] + " " + s["text"]).strip()
    forms = []
    for it in items:
        vi = re.sub(r"\s+", " ", it["vi"]).strip()
        for f in split_forms(re.sub(r"\s+", " ", it["words"]).strip(), it["pos"], vi):
            if it["extra"]:
                f["note"] = it["extra"].strip()
            forms.append(f)
    return forms


def parse_collocations(spans, page_mid):
    cols = [[s for s in spans if s["x0"] < page_mid], [s for s in spans if s["x0"] >= page_mid]]
    out = []
    for col in cols:
        if not col:
            continue
        left = min(s["x0"] for s in col)
        cur = None
        for line in lines_of(col):
            for s in line:
                phrase_like = (s["color"] == DARK and "SemiBold" in s["font"]) or (s["color"] == MUTED and s["size"] >= 8.3 and "Italic" in s["font"])
                example_like = s["size"] <= 8.1 and (s["color"] == EX_GREY or s["font"].startswith("Type3"))
                starts = phrase_like and s["color"] == DARK and abs(s["x0"] - left) < 3
                if starts and (cur is None or cur["ex"]):
                    cur = {"phrase": [], "vi": [], "ex": []}
                    out.append(cur)
                if cur is None:
                    continue
                if example_like:
                    cur["ex"].append(s)
                elif phrase_like and not cur["vi"]:
                    cur["phrase"].append(s)
                else:
                    cur["vi"].append(s)
    res = []
    for c in out:
        res.append({
            "phrase": join_spans(c["phrase"]),
            "vi": join_spans(c["vi"]),
            "example": join_spans(c["ex"]),
        })
    return res


def parse_entry(spans, page_mid):
    heads = [s for s in spans if is_head(s)]
    y_head = min(s["yc"] for s in heads)
    head_line = [s for s in spans if abs(s["yc"] - y_head) < 7]
    headword = join_spans([s for s in head_line if is_head(s)]).replace(" ", "")
    pos = [s["text"].strip() for s in head_line if is_badge(s)]
    band = any("850" in s["text"] or "★" in s["text"] for s in head_line)
    ipa = join_spans([s for s in head_line if not is_head(s) and not is_badge(s) and "850" not in s["text"] and "★" not in s["text"]])
    y_fam = heading_y(spans, "HỌTỪ")
    y_col = heading_y(spans, "COLLOCATION")
    y_sam = heading_y(spans, "CÂUMẪU")
    y_tip = None
    for s in spans:
        if s["text"].strip() in ("MẸO", "BẪY TOEIC") or re.sub(r"\s", "", s["text"]) in ("MẸO", "BẪYTOEIC"):
            if is_badge(s) or s["size"] < 7.5:
                y_tip = s["y0"] if y_tip is None else min(y_tip, s["y0"])
    end = max(s["y1"] for s in spans) + 1
    def between(a, b):
        return [s for s in spans if a is not None and s["y0"] >= a - 0.5 and s["y0"] < (b if b is not None else end)]
    meaning = [s for s in spans if s["yc"] > y_head + 7 and (y_fam is None or s["y0"] < y_fam - 0.5)]
    vi = join_spans([s for s in meaning if "SemiBold" in s["font"] and s["size"] >= 9])
    en = join_spans([s for s in meaning if not ("SemiBold" in s["font"] and s["size"] >= 9)])
    fam_spans = [s for s in between(y_fam, y_col or y_sam) if not re.sub(r"\s", "", s["text"]).startswith(("HỌTỪ",)) and s["text"].strip() != "word family"]
    col_spans = [s for s in between(y_col, y_sam) if not re.sub(r"\s", "", s["text"]).startswith("COLLOCATION") and s["text"].strip() != "cụm hay dùng + ví dụ"]
    sam_spans = [s for s in between(y_sam, y_tip - 2.5 if y_tip else None) if not re.sub(r"\s", "", s["text"]).startswith("CÂUMẪU")]
    tip_spans = [s for s in between(y_tip - 2.5 if y_tip else None, None) if not (is_badge(s) or s["size"] < 7.5)]
    sample = {"en": "", "ipa": "", "vi": ""}
    if sam_spans:
        ipa_s = [s for s in sam_spans if s["font"].startswith("DejaVu") and s["text"].strip().startswith("/") or (s["font"].startswith("DejaVu") and s["size"] < 8.5)]
        y_ipa = min((s["y0"] for s in ipa_s), default=None)
        vi_s = [s for s in sam_spans if "Italic" in s["font"]]
        sample["en"] = join_spans([s for s in sam_spans if (y_ipa is None or s["y0"] < y_ipa - 1) and "Italic" not in s["font"]])
        sample["ipa"] = join_spans(ipa_s)
        sample["vi"] = join_spans(vi_s)
    return {
        "headword": headword,
        "pos": pos,
        "ipa": ipa,
        "band850": band,
        "vi": vi,
        "enBook": en,
        "family": parse_family(fam_spans, 50),
        "collocations": parse_collocations(col_spans, page_mid),
        "sample": sample,
        "tip": join_spans(tip_spans),
    }


def parse_toc(doc):
    topics = []
    for pno in range(1, 4):
        for line in doc[pno].get_text().splitlines():
            pass
        text = doc[pno].get_text()
        for m in re.finditer(r"(T\d\d) · (.+?) — (.+?)\n(\d+)\n", text, re.S):
            topics.append({"code": m.group(1), "en": m.group(2).strip(), "vi": re.sub(r"\s+", " ", m.group(3)).strip(), "page": int(m.group(4))})
        if topics:
            break
    return topics


def ocr_page(page):
    pix = page.get_pixmap(dpi=300)
    with tempfile.TemporaryDirectory() as td:
        png = os.path.join(td, "p.png")
        pix.save(png)
        r = subprocess.run(["tesseract", png, "-", "-l", "eng"], capture_output=True, text=True)
        return r.stdout


def parse_index(doc):
    """Read the book index ("Chỉ mục") pages: word followed by topic code."""
    words = {}
    inside = False
    for page in doc:
        t = page.get_text()
        if "Chỉ mục (" in t[:200]:
            inside = True
        elif inside and ("Nguồn tham khảo" in t[:200]):
            break
        if not inside:
            continue
        tokens = [x.strip() for x in t.splitlines() if x.strip()]
        for i, tok in enumerate(tokens[:-1]):
            if re.fullmatch(r"T\d\d", tokens[i + 1]) and re.fullmatch(r"[a-z(][a-z\-'() ]*", tok):
                words[tok] = tokens[i + 1]
    return words


def main():
    os.makedirs(os.path.join(OUT, "raw"), exist_ok=True)
    os.makedirs(os.path.join(OUT, "extracted"), exist_ok=True)
    entries, index, report = [], {}, []
    for book_id, fname in BOOKS:
        path = os.path.join(REPO, fname)
        if not os.path.exists(path):
            sys.exit(f"missing {path}")
        doc = pymupdf.open(path)
        toc = parse_toc(doc)
        raw = []
        for i, page in enumerate(doc):
            t = page.get_text()
            status = "text"
            if len(t.strip()) < 50 and page.get_images():
                t = ocr_page(page)
                status = "ocr"
            if len(t.strip()) < 20:
                status = "unreadable"
            report.append({"book": book_id, "page": i + 1, "chars": len(t.strip()), "status": status})
            raw.append(f"=== {book_id} page {i + 1} ===\n{t}")
        with open(os.path.join(OUT, "raw", f"{book_id}.txt"), "w", encoding="utf-8") as fh:
            fh.write("\n".join(raw))
        # topic pages: printed page p == doc[p]
        for ti, tp in enumerate(toc):
            start = tp["page"]
            stop = toc[ti + 1]["page"] if ti + 1 < len(toc) else start + 9
            for pno in range(start, min(stop, len(doc))):
                page = doc[pno]
                spans = [s for s in spans_of(page) if s["y0"] < page.rect.height - 30]
                heads = sorted({round(s["yc"]) for s in spans if is_head(s)})
                # group head spans on same line
                starts = []
                for y in heads:
                    if not starts or y - starts[-1] > 8:
                        starts.append(y)
                practice = [s["y0"] for s in spans if s["text"].strip().startswith("Luyện tập")]
                page_end = min(practice) - 2 if practice else page.rect.height
                for k, y in enumerate(starts):
                    y_from = y - 10
                    y_to = starts[k + 1] - 10 if k + 1 < len(starts) else page_end
                    region = [s for s in spans if y_from <= s["yc"] < y_to]
                    if not any(is_badge(s) and abs(s["yc"] - y) < 8 for s in region):
                        continue  # topic opening page / section title, not an entry
                    e = parse_entry(region, page.rect.width / 2)
                    e.update({"book": book_id, "topic": tp["code"], "topicEn": tp["en"], "topicVi": tp["vi"], "page": pno + 1})
                    entries.append(e)
        for w, code in parse_index(doc).items():
            index.setdefault(w, code)
    with open(os.path.join(OUT, "extracted", "entries.json"), "w", encoding="utf-8") as fh:
        json.dump(entries, fh, ensure_ascii=False, indent=1)
    with open(os.path.join(OUT, "extracted", "index.json"), "w", encoding="utf-8") as fh:
        json.dump(index, fh, ensure_ascii=False, indent=1, sort_keys=True)
    with open(os.path.join(OUT, "extracted", "page-report.json"), "w", encoding="utf-8") as fh:
        json.dump(report, fh, indent=1)
    print(f"entries={len(entries)} index_words={len(index)} pages={len(report)} "
          f"ocr={sum(r['status']=='ocr' for r in report)} unreadable={sum(r['status']=='unreadable' for r in report)}")


if __name__ == "__main__":
    main()
