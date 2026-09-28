# PROGRESS

## Done
- PLAN.md
- M1: DECISION.md → chọn **1Z0-830 (Java SE 21)**.
- M2: SOURCES.md, tools/objectives.yaml, tools/book.py (examples + questions checker + coverage), tools/check_links.py, tools/run_all.sh. COVERAGE.md is generated and grows with each chapter.
- M3: ch01 (13 examples, 20 q), ch02 (13 examples, 20 q) — all questions confirmed by tools/book.py.

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
