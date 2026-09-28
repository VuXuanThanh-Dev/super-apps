# TOEIC 900 — study app (Expo + React Native)

A private study app for the two books in the repo root
(*TOEIC 900 — Word Families & Collocations*, Tập 1 + Tập 2).

**Simple idea:** every word on every screen can be tapped. A popup shows the
meaning (English + Vietnamese), IPA, a speaker button, the word family, the
collocations and an example — all offline.

**Example:** in a reading passage you tap *“negotiations”* → the popup opens
*negotiation (n)*, shows “negotiations → negotiation”, the family
*negotiate · negotiator · negotiable* and collocations like
*under negotiation*. Tap **☆ Save to my list** to review it later.

## Features

| # | Feature | Where |
|---|---|---|
| ★ | Tap any word → popup (definition, Vietnamese, IPA, text-to-speech, family, collocations, example, save). Word forms map to the lemma (*ran → run*, *companies → company*, *company's*, *don't*). Unknown words say “not found”. | every text screen |
| 1 | Vocabulary by unit/topic + search (English or Vietnamese, with or without accents) | tab **Words** |
| 2 | Flashcards with spaced repetition (SM-2) | tab **Practice** |
| 3 | Quizzes: meaning, fill in the blank, word family form, collocation matching, listening | tab **Practice** |
| 4 | Short TOEIC-style reading passages (one per unit, with questions) | tab **Read** |
| 5 | Roleplay dialogs (office, meetings, email, phone) — hide your lines and practice | tab **Read** |
| 6 | Saved words + daily review reminder (local notification) | tab **Saved** |
| 7 | Progress: words learned, streak, due cards, last 7 days, weak words | tab **Home** |
| 8 | Dark mode (System / Light / Dark) | Home → Settings |

### Why SM-2 (not FSRS)?
SM-2 is small (about 20 lines), easy to understand and to test, and needs no
training data. FSRS schedules a bit better, but it needs 17+ model weights that
should be fitted to your own review history; with one learner and a few
hundred cards, SM-2 is good enough and fully predictable. The scheduler is in
`src/features/flashcards/sm2.ts`, so FSRS can replace it later (see “Ideas for later” in the PR).

## Versions (pinned, checked 2026-09-28)

| Tool | Version |
|---|---|
| Node.js / npm | 22.22.2 / 10.9.7 |
| Expo SDK | **57** (`expo` 57.0.25 = npm `latest`) |
| React Native / React | 0.86.3 / 19.2.3 |
| expo-router / expo-sqlite / expo-speech / expo-notifications | 57.0.23 / 57.0.3 / 57.0.3 / 57.0.21 |
| TypeScript | 6.0.3 (`strict: true`, `noUncheckedIndexedAccess`) |
| Jest / jest-expo / Testing Library RN | 29.7.0 / 57.0.5 / 14.0.1 |
| ESLint / eslint-config-expo | 9.39.5 / 57.0.2 |
| Python (data tools) | 3.11, pymupdf 1.28.2, cmudict 1.1.3, nltk 3.10.3 |

**Expo Go and SDK 57:** web search results (2026-09-28) say the App Store
Expo Go supports SDK 57 and that SDK 57 projects need you to be logged in to
the same Expo account in the CLI and in Expo Go. **UNVERIFIED** — expo.dev and
docs.expo.dev are blocked in the build sandbox, so I could not open the pages.

## Run on iPhone with Expo Go (step by step)

You need a computer (Windows/macOS/Linux) and the iPhone on the **same Wi-Fi**.

1. Install **Node.js 22** on the computer (https://nodejs.org).
2. On the iPhone, install **Expo Go** from the App Store and open it.
   Sign in (or create a free Expo account).
3. On the computer:
   ```bash
   git clone https://github.com/VuXuanThanh-Dev/super-apps.git
   cd super-apps/apps/toeic
   npm ci
   npx expo login          # same account as in Expo Go (needed for SDK 57, UNVERIFIED)
   ```
4. (Optional but recommended) build the full private dataset from the books —
   see the next section. Without it the app runs with a small sample (16 words).
5. Start the dev server:
   ```bash
   npx expo start
   ```
   A QR code appears in the terminal.
6. On the iPhone open the **Camera** app, point it at the QR code and tap the
   banner “Open in Expo Go”. The app loads (first time: ~30 s).
7. If the phone cannot connect (office Wi-Fi, VPN…), use
   `npx expo start --tunnel` and scan again.
8. After changing the dataset, restart with a clean cache: `npx expo start -c`.

Notes
- Everything works offline after the app is loaded (dictionary, SQLite, TTS).
- Text-to-speech uses the iPhone voices. If there is no sound, check the silent
  switch and Settings → Accessibility → Spoken Content → Voices (English).
- The daily reminder asks for notification permission the first time you turn it on.
- Status in this PR: **Expo Go on iPhone: NOT RUN** (no iPhone in the build
  sandbox). What was run: type-check, lint, 133 Jest tests,
  `npx expo export --platform ios` (the iOS JavaScript bundle builds), and a
  headless-Chromium smoke test of the web build (`tools/web-smoke.js`: tap a
  word → popup, flashcard, stats, dark mode — all PASS).

## Build the private dataset (from the two PDFs)

```bash
cd apps/toeic
pip install -r tools/requirements.txt
python3 -c "import nltk; nltk.download('wordnet')"
bash tools/build_data.sh
```

This writes `private-data/dataset.json` and `private-data/toeic.db`
(312 word families, 1,120 word forms, 1,296 collocations, 24 units).
Metro picks `private-data/dataset.json` automatically if it exists, otherwise
`src/data/sample/dataset.json` (see `metro.config.js`). Details and quality
numbers: [DATA-REPORT.md](DATA-REPORT.md).

## Add more words

1. Create a text file, one word per line, fields separated by `|`:
   ```
   word|pos|simple English definition|example sentence|Vietnamese|topic (optional)|collocations (optional)
   ```
   Collocations: `phrase = nghĩa = example`, several separated by `;`.
   Example file: [`examples/my-words.example.txt`](examples/my-words.example.txt)
   ```
   deadline|n|the last day or time to finish something|The deadline for the report is Friday.|hạn chót|MY|meet a deadline = kịp hạn chót = We worked late to meet the deadline.
   ```
2. Import it:
   ```bash
   python3 tools/import_words.py my-words.txt
   ```
   The file is copied to `private-data/my-words/` and merged into
   `private-data/dataset.json` (new words go to the unit **MY · My words**
   unless you give a topic code). Running `tools/build_data.sh` again keeps them.
3. Restart: `npx expo start -c`.

To change a definition or example of a book word, edit
`data/authored/definitions/Txx.txt` (`word|pos|definition|example`) and run
`python3 tools/build_dataset.py`.

## Remove private data before going public

The GitHub repo is public, so `private-data/` is already **git-ignored**
(only its README is committed). Before you publish the app itself
(App Store, a web build, a zip…):

1. Delete the book-derived files:
   ```bash
   cd apps/toeic
   find private-data -mindepth 1 ! -name README.md -exec rm -rf {} +
   ```
2. Prove the app still works and no book text is left:
   ```bash
   npm run check:no-private
   ```
   It moves `private-data/*` away, runs tsc + ESLint + Jest, builds an iOS
   bundle and checks that the bundle contains the sample and no private data.
   With the book extraction present it also runs `tools/check_no_book_text.py`
   (searches all committed files for 3,684 book sentences — must be 0 hits).
3. Also think about the repo root: the two PDFs themselves are in the repo.
   Remove them if the repo becomes a real public project.

What is **not** book-derived (safe to keep): the app code, the sample dataset,
the roleplay dialogs, `data/authored/*` (my own definitions, examples and
passages), CMUdict/WordNet data (open licenses, see `tools/LICENSES.md`).

## Project structure

```
apps/toeic/
  src/app/                expo-router routes (thin files)
    (tabs)/               Home · Words · Practice · Read · Saved
    topic/[code] word/[id] passage/[id] dialog/[id] flashcards quiz settings
  src/features/           one folder per feature (screen + logic + tests)
    lookup/               tokenizer, lemmatizer, dictionary, TappableText, popup
    vocabulary/ flashcards/ quiz/ reading/ dialogs/ saved/ stats/ theme/ practice/
  src/storage/            UserStore: SQLite (expo-sqlite) + in-memory (tests)
  src/data/               types, indexes, sample dataset, generic WordNet glosses
  src/content/            roleplay dialogs, common function words (my writing)
  data/authored/          my definitions/examples (1,120) and passages (24)
  tools/                  Python data tools + check scripts
  private-data/           book-derived data (git-ignored)
```

Data flow: dataset JSON (bundled, read-only) → in-memory indexes →
dictionary / lists / quizzes. User data (saved words, SM-2 cards, answers,
daily activity, settings) → SQLite `toeic-user.db` on the phone.

## Checks

```bash
npm run typecheck          # tsc --noEmit (strict)
npm run lint               # eslint (eslint-config-expo)
npm test                   # jest (jest-expo), uses the sample dataset
npm run check:no-private   # all of the above with private-data/ empty + iOS bundle
# optional, extra evidence: web build in headless Chromium (needs Playwright)
CI=1 npx expo export --platform web --output-dir /tmp/toeic-web
NODE_PATH=$(npm root -g) node tools/web-smoke.js /tmp/toeic-web
```

## Nguồn tham khảo (Sources)

- Expo SDK version: `npm view expo dist-tags` (2026-09-28): `latest` = 57.0.25
- Compatible package versions: `node_modules/expo/bundledNativeModules.json` (expo 57.0.25)
- Expo Go + SDK 57 (search results only, pages blocked): https://expo.dev/changelog/expo-go-57-login ,
  https://expo.dev/changelog/sdk-57 — **UNVERIFIED**
- SM-2 algorithm steps (1 day, 6 days, EF formula, EF ≥ 1.3, failed card restarts without changing EF): https://github.com/cnnrhill/sm-2 (explanation of Wozniak's SM-2; super-memory.com is blocked in the sandbox)
- CMUdict: https://github.com/cmusphinx/cmudict
- WordNet 3.0 license: see `tools/LICENSES.md`
