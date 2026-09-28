# PLAN — TOEIC super-app (Task 5)

## Goal
A React Native (Expo) app for Nobin's private English study, built on the two
books in the repo root (TOEIC 900 Word Families & Collocations, Tập 1 + Tập 2).
Core feature: tap any word on any text screen to see its meaning, offline.

## Table of contents (files in apps/toeic/)
- PLAN.md — this plan
- PROGRESS.md — Done / Next / Blockers / Decisions (updated after each milestone)
- DATA-REPORT.md — dataset counts, unreadable pages, manual error check
- README.md — run on iPhone, add words, remove private-data
- tools/ — extraction + dataset build scripts (Python) and checks
- data/authored/ — definitions and examples I wrote myself (not from the books)
- private-data/ — ALL book-derived content (git-ignored, regenerate with tools/)
- src/ — app code (feature folders), app/ — expo-router routes

## Milestones
- M0 — Plan (this file), workspace, branch `task-5-toeic-app`.
- M1 — Dataset: extract text from both PDFs (check every page, OCR if needed),
  parse entries (headword, POS, IPA, family, collocations, unit/topic), add my
  own simple definitions + examples + Vietnamese, add IPA/forms from
  open-licensed dictionaries (CMUdict, WordNet), build SQLite + JSON,
  DATA-REPORT.md with counts, unreadable pages, 50-entry manual check.
- M2 — Tap-to-define: tokenizer + lemmatizer (irregular forms, punctuation,
  capitals, apostrophes), popup (definition, vi, IPA, TTS, family,
  collocations, example, save), unit tests.
- M3 — Features in order: 1 vocabulary by unit/topic + search, 2 flashcards
  with spaced repetition, 3 quizzes (meaning, blank, word form, collocation,
  listening), 4 reading passages, 5 roleplay dialogs, 6 saved words + daily
  reminder, 7 progress stats, 8 dark mode. Each tested.
- M4 — Tech/quality: Expo + TypeScript strict, expo-router, expo-sqlite,
  feature folders; tsc, eslint, jest (jest-expo) pass; "runs with empty
  private-data" check script.
- M5 — README: run on iPhone with Expo Go, add words (format + import command),
  remove private-data before going public.

## Definition of Done (copied from the task)
- [ ] Dataset and DATA-REPORT.md (counts, unreadable pages, error rate)
- [ ] All book-derived content only in apps/toeic/private-data/
- [ ] App runs with private-data empty
- [ ] Tap-to-define works on every text screen, offline, with word forms
- [ ] Features 1–8 done and tested
- [ ] Type-check, lint, and tests pass
- [ ] README complete
