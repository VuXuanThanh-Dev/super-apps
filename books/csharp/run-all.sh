#!/usr/bin/env bash
# Build + run every example of the 3 volumes, then build and test the final project.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
dotnet --version
for v in vol1-basics vol2-intermediate vol3-advanced; do
  "$ROOT/$v/run-examples.sh"
done
if [[ -d "$ROOT/vol3-advanced/final-project" ]]; then
  cd "$ROOT/vol3-advanced/final-project"
  dotnet build TaskBoard.slnx -nologo -v q
  dotnet test --solution TaskBoard.slnx --no-build
fi
echo "ALL OK"
