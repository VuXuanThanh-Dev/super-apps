# PROGRESS — TOEIC app (Task 5)

Branch: `task-5-toeic-app`

## Done
- M0: PLAN.md.
- M1 (dataset): extraction script `tools/extract_books.py`, build script
  `tools/build_dataset.py`, my own definitions/examples (1,120) and 24 passages,
  public sample dataset, WordNet irregular forms, DATA-REPORT.md.
  Counts: 312 families, 1,120 word forms, 1,296 collocations, 0 unreadable pages,
  manual check 1/50 errors (2 %) after fixes.

## Next
- M2: tap-to-define (tokenizer, lemmatizer, popup, tests).

## Blockers
- docs.expo.dev, wordnet.princeton.edu blocked (sandbox). Used npm / package files instead.
- `npx expo install` cannot reach api.expo.dev (403) → used versions from
  `node_modules/expo/bundledNativeModules.json` with plain `npm install`.

## Decisions
- Repo is public → `private-data/` is git-ignored; regenerate with `bash tools/build_data.sh`.
- My own writing (definitions, examples, passages, dialogs) is committed outside
  private-data: it is not taken from the books.
- Vietnamese meanings come from the books (so they are private); definitions and
  examples are mine (task rule: "write your own definitions and examples").
- IPA: book IPA for headwords, CMUdict → IPA for other forms (17 forms have none).
- Expo SDK 57 (npm `expo` latest = 57.0.25, checked 2026-09-28).
