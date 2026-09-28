# private-data/ — book-derived data (NOT in git)

Everything in this folder comes from the two books in the repo root
(`TOEIC-900-Word-Families-Collocations-Tap1.pdf`, `...-Tap2.pdf`).
It is for Nobin's private study only.

- This folder is **git-ignored** (only this README is committed), because the
  GitHub repo is public (checked 2026-09-28).
- The app works without it: it then uses the small hand-written sample in
  `src/data/sample/dataset.json`.

## Regenerate (about 30 seconds)

```bash
cd apps/toeic
pip install -r tools/requirements.txt
python3 -c "import nltk; nltk.download('wordnet')"
bash tools/build_data.sh
```

## Files created here

| File | What |
|---|---|
| `raw/tap1.txt`, `raw/tap2.txt` | full text of every page (PyMuPDF text layer) |
| `extracted/entries.json` | parsed entries: headword, POS, IPA, Vietnamese, family, collocations, sample sentence, tip |
| `extracted/index.json` | the book index (word → topic), used for a coverage check |
| `extracted/page-report.json` | per-page status: text / ocr / unreadable |
| `dataset.json` | the app dataset (loaded by Metro instead of the sample) |
| `toeic.db` | the same data as SQLite |
| `build-stats.json` | counts, missing IPA list |
| `manual-check-sample.txt` | the 50 random entries used for the manual check |

## Remove before going public

Delete this folder's content (keep this README) — see the main README,
section "Remove private data".
