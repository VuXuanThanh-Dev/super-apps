# PROGRESS — Task 4 (C# book series)

Branch: `task-4-csharp` · PR: https://github.com/VuXuanThanh-Dev/super-apps/pull/1 (draft)

## Done
- M1: `STACK.md`, `global.json` (SDK 10.0.112, rollForward latestFeature, MTP test runner),
  `Directory.Build.props`, `.gitignore`.

## Next
- M2: volume outlines (README per volume) + tools (`tools/embed.py`, `run-examples.sh`).

## Blockers
- learn.microsoft.com blocked (403). Workaround: dotnet/docs, dotnet/core, dotnet/csharplang on GitHub.
  Need from Nobin: allow `learn.microsoft.com` in environment Network access (optional).
- xunit.net blocked (403). Workaround: xunit/xunit GitHub repo. Need: allow `xunit.net` (optional).

## Decisions
- .NET 10 LTS + C# 14 (not .NET 11 preview). Why: LTS, supported to 2028-11-14.
- Pin SDK 10.0.112 (the installed one) with `rollForward: latestFeature`, so readers with
  10.0.4xx also work, but never roll to 11.0 or preview.
- Use Microsoft.Testing.Platform in global.json: .NET 10 SDK refuses VSTest mode with xunit.v3 (seen here).
- Code and output in chapters are injected from real files by `tools/embed.py` so they always match.
