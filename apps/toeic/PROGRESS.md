# PROGRESS — TOEIC app (Task 5)

Branch: `task-5-toeic-app` · Last update: 2026-09-28

## Done
- M0: PLAN.md.
- M1 Dataset: `tools/extract_books.py` (PyMuPDF, OCR fallback not needed),
  `tools/build_dataset.py` (JSON + SQLite), my own definitions/examples (1,120)
  and 24 passages, public sample dataset, DATA-REPORT.md.
  312 families · 1,120 word forms · 1,296 collocations · 0 unreadable pages ·
  manual check 1/50 errors (2 %) after fixes · leak check 0 hits.
- M2 Tap-to-define: tokenizer, lemmatizer (WordNet irregular forms + rules,
  possessives, contractions), offline dictionary (book words → function words →
  WordNet glosses → "not found"), popup with IPA, TTS, family, collocations,
  example, save. Tests for irregular forms, punctuation, capitals, apostrophes.
- M3 Features 1–8 (each with tests): vocabulary + search, SM-2 flashcards,
  5 quiz types, reading passages, roleplay dialogs, saved words + daily local
  reminder, stats (learned, streak, due, weak words, 7 days), dark mode.
- M4 Expo SDK 57 + TypeScript strict + expo-router (src/app) + expo-sqlite,
  feature folders. tsc / eslint / jest (133 tests) pass.
  `npm run check:no-private` passes with private-data empty (incl. iOS bundle).
  Extra: web export + headless Chromium smoke test PASS.
- M5 README: iPhone + Expo Go steps, add words (`tools/import_words.py`),
  remove private data.

## Next (ideas, not required)
- Run on a real iPhone with Expo Go (NOT RUN here).
- IPA for 17 forms missing in CMUdict.

## Blockers
- No iPhone in the sandbox → "Expo Go on iPhone: NOT RUN".
- Blocked hosts: docs.expo.dev, expo.dev, wordnet.princeton.edu,
  super-memory.com. Need from Nobin: allow them in environment Network access
  (only to verify facts; nothing is broken).
- `npx expo install` / expo-doctor cannot reach api.expo.dev / React Native
  Directory (403) → versions taken from `node_modules/expo/bundledNativeModules.json`;
  expo-doctor: 19/21 checks pass, 2 fail only because of the network.

## Decisions
- Repo is public → `private-data/` git-ignored; regenerate with `bash tools/build_data.sh`.
- My own writing (definitions, examples, passages, dialogs) is committed outside
  private-data. Checked with `tools/check_no_book_text.py` (0 exact hits) and
  `tools/check_similarity.py` (0 definitions ≥ 0.8 similar to the book).
- Vietnamese meanings, collocations, headword IPA come from the books (private).
- Extra IPA: CMUdict (BSD-style); irregular forms + fallback glosses: WordNet 3.0.
- SM-2 instead of FSRS (simple, testable, no training data) — see README.
- Dataset = bundled JSON (read-only, in memory); user data = SQLite on the phone.
- Metro resolves `@toeic/dataset` to private-data/dataset.json if it exists,
  else the sample; Jest always uses the sample.
- Expo SDK 57 (npm latest 57.0.25). Expo Go support for SDK 57: UNVERIFIED
  (search snippets only).
