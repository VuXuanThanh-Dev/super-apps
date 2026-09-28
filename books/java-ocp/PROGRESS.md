# PROGRESS

Branch: `task-2-java-ocp` · PR: https://github.com/VuXuanThanh-Dev/super-apps/pull/2 · Last update: 2026-09-28

## Done

- PLAN.md (goal, TOC, milestones, DoD — all DoD items checked with proof).
- **M1** DECISION.md → exam **1Z0-830 (Java SE 21)**. Facts from search snippets, marked **UNVERIFIED**.
- **M2** SOURCES.md (official links, GitHub repo comparison table, paid books/courses as links only),
  `tools/objectives.yaml` (26 objectives), `tools/book.py` (examples runner + question checker + Markdown renderer +
  COVERAGE generator), `tools/check_links.py`, `tools/run_all.sh`. COVERAGE.md: **26/26** objectives covered.
- **M3** 10 chapters (`chapters/ch01…ch10`), **124 examples** with real output (10–15 per chapter), **200 original
  questions** (20 per chapter, easy/medium/hard, single + "choose 2/3", answers spread A–D), each with answer, why right,
  why each wrong option is wrong. **200/200 confirmed** by the checker.
- **M4** 3 mock exams (`mock/`, 50 questions each, 120 min, answers in separate files) — **150/150 confirmed**;
  10 one-page cheat sheets (`cheatsheets/`); 8-week schedule + 6-week variant (`schedule/schedule.md`);
  GLOSSARY.md; intro chapter `chapters/ch00-gioi-thieu.md` (says honestly no document guarantees a perfect score); README.md.
- **M5** `bash tools/build_pdf.sh` → `dist/java-ocp-handbook.pdf` (210 p.), `dist/java-ocp-mock-exams.pdf` (69 p.),
  `dist/java-ocp-cheatsheets.pdf` (11 p.: cover + 1 page per chapter). 5 Mermaid diagrams render (build fails otherwise).
  pdftotext check of "ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ": **ACCENTS OK** in all 3 PDFs.
- Full check `bash tools/run_all.sh` (output in `tools/run_all_result.txt`): 124/124 examples OK, 350/350 questions
  confirmed, coverage 26/26, links 0 broken (35 blocked by sandbox — `tools/link_check_result.txt`).

## Next

- Nobin: review PR; open the Oracle pages and confirm exam numbers (see Blockers); decide Java 21 vs Java 25 exam.
- Ideas for later are listed in the PR description.

## Blockers

1. **Oracle and other sites blocked in the sandbox** (HTTP 000 / `connect_rejected`, also with the web reader):
   `education.oracle.com`, `docs.oracle.com`, `mylearn.oracle.com`, `dev.java`, `openjdk.org`, `enthuware.com`,
   `www.selikoff.net`, `www.wiley.com`, `ocpj21.javastudyguide.com`, `www.oreilly.com`, `www.pluralsight.com`, `coderanch.com`.
   Tried: curl and the web reader. Worked around: WebSearch snippets (exam facts → **UNVERIFIED**), JDK 21 source on
   `raw.githubusercontent.com/openjdk/jdk21u` and local `src.zip` for Javadoc, running all code.
   **Need from Nobin:** allow `education.oracle.com`, `docs.oracle.com`, `mylearn.oracle.com` (and optionally `openjdk.org`,
   `dev.java`) in the environment Network access, or check DECISION.md numbers yourself.
2. None for code: JDK 21.0.10, pandoc, Chromium (Playwright) and Noto fonts were all available.

## Decisions

- Separate clone in `/home/user/work/task2`; branch `task-2-java-ocp` from `origin/main`; only `books/java-ocp/` touched.
- Exam = 1Z0-830 (Java 21): more time per question (120 min vs 90), no JDBC, modern Java features, 1Z0-829 retiring
  (snippet: 2027-02-28, **UNVERIFIED**), and JDK 21 is available here to verify everything. 1Z0-831 (Java 25) exists
  (~May 2026, **UNVERIFIED**) → question for Nobin.
- All code: JDK 21.0.10, `javac --release 21`, **no preview features**. Examples run with locale `en_US`, TZ `UTC`,
  `JAVA_TOOL_OPTIONS` removed (the sandbox sets it and it prints noise).
- One chapter per objective group (10 chapters); the OOP group is the longest chapter (15 examples).
- Objective IDs x.y are this book's numbering (Oracle does not number sub-objectives); two Oracle rows were split (1.1/1.2, 10.1/10.2).
- Question source of truth: `examples/questions/<set>/questions.yaml`. The tool generates the Java files, compiles/runs them,
  and renders the Markdown. Check kinds: `output` (stdout must equal the correct option), `compile_error` (per-line
  isolation: each marked line alone fails, all fixed compiles), `variants` (every option compiled/run), `proofs` (every
  statement proven true/false by its own program), `script` / `script_variants` (multi-file module/bundle scenarios with
  real `javac`/`java`/`jar`/`jlink`). One GC question uses WeakReference + `System.gc()` under SerialGC (`check_code`).
- Answer letters balanced per set (checker fails if one letter > 40% of single-answer questions).
- Mock exam topic weights: Oracle publishes none (**UNVERIFIED**); my blueprint is in `mock/README.md`.
- Mock exam files hide objective/level (like the real exam); answer files show them.
- PDF pipeline: pandoc → HTML (Noto Serif/Sans/Mono) → Playwright Chromium `page.pdf()`; Mermaid 11.17.2 from npm
  (`tools/pdf/package-lock.json`), rendered in the page before printing. PDFs are committed in `dist/`.
- Concurrency examples/questions were written to be deterministic (join, latches, Future.get); ch08 outputs were checked
  identical over 3 runs. A few outputs depend on JDK behaviour and are labelled so (parallel `reduce` with a wrong identity;
  order of `requires` lines in `--describe-module`).
- Git: `tools/pdf/node_modules` was committed by mistake in the M5 commit; I removed it from this branch's history with
  `git filter-branch` and force-pushed the task branch once (only my own commits were rewritten). It is now in `.gitignore`;
  `tools/build_pdf.sh` runs `npm ci` from `tools/pdf/package-lock.json` when needed.
