# PROGRESS — Task 4 (C# book series)

Branch: `task-4-csharp` · PR: https://github.com/VuXuanThanh-Dev/super-apps/pull/1 (draft)

## Done
- M1: `STACK.md`, `global.json` (SDK 10.0.112, rollForward latestFeature, MTP test runner),
  `Directory.Build.props`, `.gitignore`.

- M2: volume outlines (`vol*/README.md`), `tools/run-examples.sh`, `tools/embed.py`, `run-all.sh`.
- M3: Vol 1 — 7 chapters (incl. ch.7 "C# cho Java và TypeScript developer"), 16 C# projects +
  Java/TS/file-based examples, all run OK (`./vol1-basics/run-examples.sh`). GLOSSARY.md.

- M4: Vol 2 — 7 chapters, 14 projects (2 xUnit v3 test projects, 17 tests), all pass
  (`./vol2-intermediate/run-examples.sh`).

- M5: Vol 3 — 7 chapters + `final-project/` TaskBoard API (4 src + 2 test projects, 28 tests pass,
  EF Core migrations, Dockerfile). Docker build + run + compose RUN OK here (with CA secret, see ch.7).
  BenchmarkDotNet ShortRun RUN (real numbers, noisy shared VM — noted in ch.3).

- M6: `tools/build-pdf.sh` (pandoc → HTML → Playwright Chromium, Mermaid rendered) → `dist/*.pdf`
  (50 / 48 / 62 pages); pdftotext accent check OK for ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ in all 3.
  `tools/check-links.py`: 132 URLs, 0 broken, report in `tools/link-report.txt`.
- Full re-run `./run-all.sh` (with CA_BUNDLE) → ALL OK, 28/28 final-project tests.

## Next
- Nothing required. Ideas for later are in the PR.

## How to re-verify
```bash
cd books/csharp
CA_BUNDLE=/root/.ccr/ca-bundle.crt ./run-all.sh   # CA_BUNDLE only needed behind the sandbox proxy
(cd tools/pdf && npm ci) && ./tools/build-pdf.sh
python3 tools/check-links.py
```

## Blockers
- learn.microsoft.com blocked (403). Workaround: dotnet/docs, dotnet/core, dotnet/csharplang on GitHub.
  Need from Nobin: allow `learn.microsoft.com` in environment Network access (optional).
- xunit.net blocked (403). Workaround: xunit/xunit GitHub repo. Need: allow `xunit.net` (optional).

- Docker build in this sandbox needs the proxy CA: solved with an optional BuildKit secret
  `ca_bundle` + `--network host` (Dockerfile stays clean for normal users). Run with
  `CA_BUNDLE=/root/.ccr/ca-bundle.crt ./vol3-advanced/run-examples.sh`.

## Decisions
- .NET 10 LTS + C# 14 (not .NET 11 preview). Why: LTS, supported to 2028-11-14.
- Pin SDK 10.0.112 (the installed one) with `rollForward: latestFeature`, so readers with
  10.0.4xx also work, but never roll to 11.0 or preview.
- Use Microsoft.Testing.Platform in global.json: .NET 10 SDK refuses VSTest mode with xunit.v3 (seen here).
- Exercise solutions are runnable projects (`ChNN.Solutions`) with real output.
- Very short syntax fragments (1–3 lines) in "Đi sâu" are not separate programs; each idea
  is also shown in a runnable example.
- Test output uses `dotnet test --output Detailed`; repeated "  from <dll>" lines are removed
  by the script (documented in chapter 6).
- Slug exercise project sets `InvariantGlobalization=false` (Normalize needs ICU) — kept as a
  real "trap" in chapter 6.
- Final project is self-contained (own global.json + Directory.Build.props) so the Docker context is that folder.
- EF Core: migrations (dotnet-ef 10.0.12 local tool) + `Database.Migrate()` at startup; SQLite in-memory for integration tests.
- Code and output in chapters are injected from real files by `tools/embed.py` so they always match.
