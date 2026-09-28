#!/usr/bin/env bash
# Build the final project and run all its tests (unit + integration + architecture).
set -euo pipefail
cd ../../final-project
echo '$ dotnet build TaskBoard.slnx'
dotnet build TaskBoard.slnx -nologo -v q 2>&1 | grep -E "Warning\(s\)|Error\(s\)"
echo '$ dotnet test --solution TaskBoard.slnx --output Detailed'
dotnet test --solution TaskBoard.slnx --no-build --output Detailed 2>&1 | grep -v '^  from .*\.dll' | grep -v '^\[+'
