# PROGRESS

## Done
- PLAN.md
- M1: DECISION.md → chọn **1Z0-830 (Java SE 21)**.
- M2: SOURCES.md, tools/objectives.yaml, tools/book.py (examples + questions checker + coverage), tools/check_links.py, tools/run_all.sh. COVERAGE.md is generated and grows with each chapter.
- M3 DONE: 10 chapters (ch01–ch10), 124 examples with real output, 200 original questions, 200/200 confirmed by `python3 tools/book.py questions`. COVERAGE.md: 26/26 objectives.
- M5 DONE: `bash tools/build_pdf.sh` → dist/java-ocp-handbook.pdf (210 p.), dist/java-ocp-mock-exams.pdf (69 p.), dist/java-ocp-cheatsheets.pdf (11 p., 1 page per chapter). 5 Mermaid diagrams render (script fails otherwise). pdftotext accent check: ACCENTS OK for all 3 PDFs.
- Full check `bash tools/run_all.sh` (2026-09-28, output saved in tools/run_all_result.txt): 124/124 examples OK, 350/350 questions confirmed, coverage 26/26, links: 0 broken (35 blocked by sandbox, see tools/link_check_result.txt).
- M4 DONE: 3 mock exams (mock/, 150 questions, 150/150 confirmed), 10 cheat sheets (cheatsheets/), 8-week + 6-week schedule (schedule/), GLOSSARY.md, intro chapter ch00, README.md.

## Next
- Final: update PR description, final report.

## Blockers
- Oracle pages blocked in sandbox (403 / connect_rejected): `education.oracle.com`, `docs.oracle.com`,
  `mylearn.oracle.com`, `dev.java`. Tried: curl + WebFetch. Exam facts come from WebSearch snippets only
  → marked **UNVERIFIED**. **Need from Nobin:** allow these hosts in environment Network access,
  or open the pages and confirm the numbers in DECISION.md.

## Decisions
- Work in a separate clone, branch `task-2-java-ocp` (from origin/main).
- Exam = 1Z0-830 (Java 21). Reasons in DECISION.md. 1Z0-831 (Java 25) exists → question for Nobin.
- All code: JDK 21.0.10, `javac --release 21`, no preview features.
- Examples run with fixed locale en_US and TZ=UTC so outputs are reproducible.
- Question format: one YAML per chapter (`examples/questions/chNN/questions.yaml`) = single source of truth.
  The tool generates Java files, compiles/runs them, and renders Markdown. Check kinds: output, compile_error
  (with per-line isolation check), variants (each option compiled/run), proofs (each statement proven by a program), script.
- GC question (03-01) is checked with WeakReference + System.gc() under SerialGC (`check_code`).
