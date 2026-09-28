#!/usr/bin/env python3
"""Check a PDF for Vietnamese accents and embedded Noto fonts.

Usage: check-pdf.py book.pdf [--source a.md b.md ...] [--require-all]
- Runs `pdftotext -enc UTF-8` and normalises both texts to NFC.
- Test characters: ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ.
  Every test character that appears in the sources must appear in the PDF text.
  --require-all: all 10 must appear in the PDF (use with assets/accent-test.md).
- Runs `pdffonts`: at least one embedded Noto font, and no Type 3 fallback font.
- Prints a table and exits 1 on any failure.
"""
import argparse
import subprocess
import sys
import unicodedata

CHARS = "ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ".split()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf")
    ap.add_argument("--source", nargs="*", default=[])
    ap.add_argument("--require-all", action="store_true")
    a = ap.parse_args()
    text = subprocess.run(["pdftotext", "-enc", "UTF-8", a.pdf, "-"], check=True,
                          capture_output=True, text=True).stdout
    text = unicodedata.normalize("NFC", text)
    src = unicodedata.normalize("NFC", "".join(open(f, encoding="utf-8").read() for f in a.source))
    fails = []
    print("char  in_source  in_pdf")
    for c in CHARS:
        s, p = src.count(c), text.count(c)
        bad = (s > 0 and p == 0) or (a.require_all and p == 0)
        print(f"{c:4}  {s:9}  {p:6}  {'FAIL' if bad else 'ok'}")
        if bad:
            fails.append(f"missing '{c}' in PDF text")
    fonts = subprocess.run(["pdffonts", a.pdf], check=True, capture_output=True, text=True).stdout
    lines = fonts.splitlines()[2:]
    noto = [l.split()[0] for l in lines if "Noto" in l]
    emb_ok = all(" yes " in l for l in lines if "Noto" in l)
    type3 = [l for l in lines if "Type 3" in l]
    print("fonts:", ", ".join(sorted(set(noto))) or "(no Noto font)")
    if not noto:
        fails.append("no Noto font in PDF")
    if not emb_ok:
        fails.append("a Noto font is not embedded")
    if type3:
        fails.append("Type 3 font found (fallback glyphs)")
    pages = subprocess.run(["pdfinfo", a.pdf], check=True, capture_output=True, text=True).stdout
    print(next((l for l in pages.splitlines() if l.startswith("Pages:")), "Pages: ?"))
    for f in fails:
        print("FAIL:", f)
    print("RESULT:", "PASS" if not fails else "FAIL")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
