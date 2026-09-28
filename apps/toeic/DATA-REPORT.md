# DATA-REPORT — TOEIC 900 dataset

Date: 2026-09-28. All numbers below come from real runs of the scripts in
`tools/` (see "How to reproduce"). The dataset itself is book-derived, so it
lives only in `private-data/` and is **not committed** (see "Git decision").

## 1. Sources

| Source | What we take | License |
|---|---|---|
| `TOEIC-900-Word-Families-Collocations-Tap1.pdf` (120 pages) | headwords, POS, IPA of headwords, Vietnamese meanings, word families, collocations (+ their examples), topic/unit, tips | private study only → `private-data/` |
| `TOEIC-900-Word-Families-Collocations-Tap2.pdf` (118 pages) | same | private study only → `private-data/` |
| `data/authored/definitions/*.txt` | simple English definition + example sentence for every word form (1,120 lines) | written by me for this app (not copied or translated from the books) |
| `data/authored/passages.txt` | 24 TOEIC-style reading passages (1 per topic) with 48 questions | written by me for this app |
| CMUdict 1.1.3 | IPA for word forms without book IPA | BSD-style (see `tools/LICENSES.md`) |
| WordNet 3.0 | irregular forms (lemmatizer) + fallback glosses for other words | WordNet 3.0 license (see `tools/LICENSES.md`) |

## 2. Extraction

- Both PDFs have a real text layer (fonts BeVietnamPro, DejaVuSans and some
  Type3 glyphs for headwords). Text is read with PyMuPDF 1.28.2, using font,
  size, colour and position of each text span to find the fields
  (headword = large Type3 glyphs, POS = small white badges, IPA = DejaVuSans,
  Vietnamese = SemiBold, family / collocation / sample / tip sections by their
  headings, 2 columns split at the page middle).
- OCR fallback (tesseract) exists in `tools/extract_books.py` for pages with
  (almost) no text but with images. It was **not needed**: 0 pages.
- Every page was checked (`private-data/extracted/page-report.json`):

| Book | Pages | Text layer OK | OCR used | Unreadable |
|---|---|---|---|---|
| Tập 1 | 120 | 120 | 0 | 0 |
| Tập 2 | 118 | 118 | 0 | 0 |

  Pages with little text (< 200 chars) are section title pages, not problems:
  Tập 1 p3, p8, p13, p115; Tập 2 p3, p6, p11, p108, p112.
- Problems found and fixed while building the parser:
  1. Headword glyphs are raised/lowered by 2 pt (Type3 font), which broke the
     letter order ("itinerary" came out as "tnrryiiea"). Fixed by grouping
     spans into lines with a tolerance instead of rounding y.
  2. A tip badge starts 1 pt lower than its text, so 113 tips were empty. Fixed.
  3. Family forms with two parts of speech (e.g. "representative n | adj")
     kept only the first POS (18 forms). Fixed.
  4. CMUdict → IPA put the stress mark after an r-coloured vowel
     ("dərˈekʃən"). Fixed ("dəˈrekʃən").

## 3. Counts

| Item | Tập 1 | Tập 2 | Total | Book says |
|---|---|---|---|---|
| Topics (units) | 12 (T01–T12) | 12 (T13–T24) | 24 | 12 + 12 |
| Word families (headwords) | 156 | 156 | 312 | 156 + 156 |
| Word forms (unique words) | 530 | 590 | 1,120 | index: 530 + 590 |
| Collocations (with example) | 595 | 701 | 1,296 | 595 + 701 |
| Headwords marked ★ band 850+ | | | 32 | |
| Reading passages (mine) | | | 24 (48 questions) | |
| Fallback glosses (WordNet) | | | 1,664 (private) + 303 (public) | |

Coverage check against the book index ("Chỉ mục", 1,118 index lines parsed):
every index word is in the dataset (0 missing).

Field completeness (1,120 word forms):

| Field | Filled | Missing |
|---|---|---|
| word, lemma, POS, book, unit (topic) | 1,120 | 0 |
| Vietnamese meaning (from the book) | 1,120 | 0 |
| simple English definition (mine) | 1,120 | 0 |
| example sentence (mine) | 1,120 | 0 |
| IPA | 1,103 (310 book, 793 CMUdict) | 17 (not in CMUdict: capably, fulfilment, consignee, consignor, influencer, courteously, discourteous, promptness, transactional, sustainably, renewables, orientate, proficiently, skilful, luxuriously, hygienic, unhygienic) |
| word family link | 1,120 | 0 |
| collocations | every family has 2–5 (4 families: 2, 53: 3, 146: 4, 109: 5) | 0 families without collocations |

## 4. Manual check of 50 random entries

Method: `python3 tools/manual_check.py 50 20260928` picks 50 random word
forms (fixed seed) and prints each field next to the text of the PDF page it
came from. I compared word, POS, IPA, Vietnamese, topic, family, and checked
that my definition and example fit the Vietnamese meaning.

| Run | Errors | Error rate | Details |
|---|---|---|---|
| First check | 4 / 50 | 8 % | #21 representative: POS "n" (book: n, adj) · #32 commercial: POS "adj" (book: adj, n), my definition missed the noun meaning · #7 direction: wrong IPA stress position · #35 fulfilment: no IPA |
| After fixes (parser POS fix, IPA fix, 20 definitions rewritten for 2-POS words) | 1 / 50 | 2 % | #35 fulfilment: no IPA (not in CMUdict) |

Not counted as errors (style only): CMUdict gives "i" for unstressed final
"-y" and sometimes a secondary stress the book would not show.

## 5. Git decision (private-data)

- The repo `VuXuanThanh-Dev/super-apps` is **public** (checked with the GitHub
  API on 2026-09-28: `"private": false, "visibility": "public"`).
- So `private-data/` is **git-ignored** (only its README is committed).
  Committed instead: the extraction scripts and my own writing
  (definitions, examples, passages, dialogs), which contain no book text.
- To get the full dataset on a new machine: `bash tools/build_data.sh`
  (about 30 s). The PDFs are in the repo root.

## 6. How to reproduce

```bash
cd apps/toeic
pip install -r tools/requirements.txt
python3 -c "import nltk; nltk.download('wordnet')"
bash tools/build_data.sh
python3 tools/manual_check.py 50 20260928
```

Real output of the last run:

```
entries=312 index_words=1118 pages=238 ocr=0 unreadable=0
{"topics": 24, "families": 312, "words": 1120, "collocations": 1296, "passages": 24, "glosses": 1664, "missing_definition": 0, "missing_ipa": 17, "ipa_book": 310, "ipa_cmudict": 793}
```

## Nguồn tham khảo (Sources)

- CMUdict repository: https://github.com/cmusphinx/cmudict (opened 2026-09-28)
- WordNet 3.0 license: LICENSE file in the nltk `wordnet` data package,
  downloaded from https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/wordnet.zip
  (wordnet.princeton.edu is blocked by the sandbox)
- PyMuPDF on PyPI: https://pypi.org/project/PyMuPDF/
