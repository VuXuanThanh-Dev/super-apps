# PROGRESS

## Done
- PLAN.md
- M1: DECISION.md → chọn **1Z0-830 (Java SE 21)**.
- M2: SOURCES.md, tools/objectives.yaml, tools/book.py (examples + questions checker + coverage), tools/check_links.py, tools/run_all.sh. COVERAGE.md is generated and grows with each chapter.
- M3: ch01 (13 ex), ch02 (13 ex), ch03 (15 ex), ch04 (12 ex); 20 questions each, all confirmed by `python3 tools/book.py questions`.

## Next
- M3: ch02 … ch10 (one commit per chapter).

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
