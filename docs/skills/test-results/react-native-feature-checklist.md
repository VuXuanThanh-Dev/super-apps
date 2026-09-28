# Test result — `react-native-feature-checklist`

- Kết quả: **PASS — Skill tool triggered**
- Loại test: **real** (headless CLI `claude -p`, stream-json), chạy lúc 2026-09-28T15:08:11Z
- CLI: `2.1.283` · thư mục test mới, có đủ 10 skill của repo
  (`angular-review-checklist, code-sample-runner, csharp-review-checklist, handbook-chapter-writer, ocp-question-writer, react-native-feature-checklist, skill-creator, vietnamese-pdf-builder, vocabulary-extractor, webapp-testing`) + 33 skill có sẵn của môi trường (built-in/plugin, ví dụ `anthropic-skills:pdf`)
- Fixture: `test-fixtures/react-native-feature-checklist`
- Kết thúc: `success`, 11 turns, 76 s

## Prompt
```text
I want to add a 'Saved words' screen to this Expo app (list of saved words, stored offline). Give me the plan: which files to create, the steps, and what to check. Do not write the code yet.
```

## Bằng chứng kích hoạt (tool_use "Skill" trong stream)
```json
[
 {
  "id": "toolu_01TGjAumTWbw9JGoiz7pawZG",
  "input": {
   "skill": "react-native-feature-checklist",
   "args": "Add a 'Saved words' screen: list of saved words, stored offline (Expo/Expo Router app). Produce a plan only (files to create, steps, checks) — do not write code yet."
  }
 }
]
```

Thứ tự tool đã gọi: `Skill → Bash → Read → Read → Read → Bash → Bash → Read → Bash`

## File thay đổi trong thư mục test
```text
(none)
```

## Câu trả lời cuối của Claude (nguyên văn)
Confirmed this is a minimal fixture repo (single "fixture" commit), so I'll flag the missing scaffolding as pre-checks rather than assuming it's intentional. Here's the plan.

## 0. What I checked first (Step 1 of the checklist)

- **Pinned versions** (`package.json`): Expo 57.0.25, expo-router 57.0.23, react-native 0.86.3, react 19.2.3, typescript 6.0.3, jest-expo 57.0.5, @testing-library/react-native 14.0.1. No `STACK.md` in this repo — I will not bump any of these.
- **Existing structure**: `src/app/_layout.tsx` (`<Stack />`), `src/app/index.tsx` (placeholder Home), `src/features/words/types.ts` already exports `Word = { id, word, pos, definition }`.
- **Offline storage candidate**: `expo-sqlite@57.0.5` is already a dependency but unused anywhere — matches checklist rule RN-SD2 (offline data → local DB behind a repository). No new package install needed.
- **Gaps to resolve before this feature can be verified** (not part of the feature itself, but block Step 4): no `tsconfig.json`, no `app.json`/`babel.config.js`, no `scripts` block in `package.json` (no `lint`/`test`). `tsc --noEmit` and `jest` won't run until these exist. Flag this to you before starting — either these were trimmed for the fixture, or they need to be added first.

## 1. Five-line spec

- User taps "Saved words" and sees the list of words they previously saved, most recent first.
- Data in: nothing (reads from local DB). Data out: none (read/delete only from this screen).
- States: loading (first read), empty ("No saved words yet"), error (DB read failed + Retry), success (list).
- Offline: fully offline, no network calls; list survives app restart (SQLite-backed).
- Done when: list renders saved words from disk, a saved word can be removed and disappears immediately, and it works after killing/reopening the app with no network.

## 2. Files to create

**Route** (thin, in `src/app`):
- `src/app/saved-words.tsx` — default-export screen, just renders `<SavedWordsScreen />` from the feature folder (RN-RT1/RT4).

**Feature folder** (`src/features/words/`, RN-FD1):
- `types.ts` — *edit*, not create: reuse existing `Word` type, no new fields needed.
- `savedWordsStorage.ts` — thin `expo-sqlite` wrapper (open/create table, get/insert/delete rows). Only this file touches `expo-sqlite` directly.
- `savedWordsRepository.ts` — pure-ish logic layer (`listSavedWords()`, `saveWord(word)`, `removeSavedWord(id)`) built against a small storage *interface*, so tests can swap in an in-memory fake instead of touching real SQLite (RN-TS3).
- `useSavedWords.ts` — hook exposing `{ status: 'loading'|'empty'|'error'|'success', words, remove, retry }`.
- `SavedWordsScreen.tsx` — actual UI: `FlatList` + loading/empty/error/success rendering.
- `SavedWordItem.tsx` — one row (word/pos/definition + a "Remove" `Pressable`).
- `__tests__/savedWordsRepository.test.ts` — unit tests against the in-memory fake storage (add, remove, list-empty, list-after-save).
- `__tests__/SavedWordsScreen.test.tsx` — render test (empty state, list with items) + one interaction test (press Remove → item disappears), with the repository/hook mocked at the boundary.

No new shared `src/components` needed — only one screen uses this UI right now (RN-FD2 says shared code only when actually shared).

## 3. Steps

1. Resolve the scaffolding gaps above (or confirm with you they're intentionally out of scope for this task).
2. Add `savedWordsStorage.ts` (SQLite table `saved_words(id, word, pos, definition, saved_at)`) and `savedWordsRepository.ts` behind an interface.
3. Add `useSavedWords.ts` hook wiring loading/empty/error/success to the repository.
4. Build `SavedWordItem.tsx` then `SavedWordsScreen.tsx` (FlatList, `keyExtractor={item => item.id}`, pull-to-refresh optional, Retry button on error).
5. Wire the thin route `src/app/saved-words.tsx`.
6. Write repository unit tests against the fake storage, then screen render/interaction tests.
7. Run the Verify step below.

## 4. Checklist to walk (per skill's reference table)

| Code | Check |
|---|---|
| RN-RT1/RT4 | `saved-words.tsx` is route-only, no logic |
| RN-FD1/FD2 | Logic lives in `src/features/words`, nothing shared prematurely |
| RN-PK1/PK2 | No new install; `expo-sqlite` is Expo-Go-compatible already |
| RN-SD2/SD3 | SQLite behind repository; repository logic is pure, testable without RN |
| RN-UI1/UI2 | loading/empty/error/success states; `FlatList` with stable `keyExtractor` |
| RN-AX1/AX2 | Remove button is `Pressable` + `accessibilityRole="button"` + `accessibilityLabel` (e.g. "Remove {word} from saved words"); no `allowFontScaling={false}` |
| RN-TS1-3 | jest-expo + RNTL tests; mock only at repository boundary |
| RN-VF1/VF2 | real `tsc`/lint/jest output; `expo start` on Expo Go/web if possible |

## 5. Checks to run before calling it done

- `npx tsc --noEmit`
- `npx expo lint` (or add a `lint` script first — none exists yet)
- `npx jest src/features/words`
- `npx expo start` → open on Expo Go/web, save a word, kill and reopen the app to confirm it persists offline. If no device/simulator is available in this environment, mark this explicitly as **NOT RUN** rather than claiming it works.

Want me to go ahead and implement this (starting with resolving the missing `tsconfig.json`/`app.json`/scripts), or do you want to fix the scaffolding gaps yourself first?
