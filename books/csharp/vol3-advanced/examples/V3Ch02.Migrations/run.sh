#!/usr/bin/env bash
# EF Core migrations of the final project, using the local tool manifest (dotnet-tools.json).
set -euo pipefail
cd ../../final-project
dotnet tool restore >/dev/null
EF="dotnet ef --project src/TaskBoard.Infrastructure --startup-project src/TaskBoard.Api"
echo '$ dotnet ef migrations list'
$EF migrations list 2>&1 | grep -v -E '^(Build started|Build succeeded)'
echo '$ dotnet ef migrations has-pending-model-changes'
$EF migrations has-pending-model-changes 2>&1 | grep -v -E '^(Build started|Build succeeded)'
echo '$ dotnet ef migrations script (first 14 lines)'
$EF migrations script 2>&1 | grep -v -E '^(Build started|Build succeeded)' | head -14
