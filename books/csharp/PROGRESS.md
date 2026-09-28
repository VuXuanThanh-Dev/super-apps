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

## Next
- M5: Vol 3 + final Web API project (tests, Dockerfile, README).

## Blockers
- learn.microsoft.com blocked (403). Workaround: dotnet/docs, dotnet/core, dotnet/csharplang on GitHub.
  Need from Nobin: allow `learn.microsoft.com` in environment Network access (optional).
- xunit.net blocked (403). Workaround: xunit/xunit GitHub repo. Need: allow `xunit.net` (optional).

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
- Code and output in chapters are injected from real files by `tools/embed.py` so they always match.
