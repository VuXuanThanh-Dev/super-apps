#!/usr/bin/env bash
# Build and run every example project of one volume.
# Usage: tools/run-examples.sh vol1-basics
# - Builds all projects under <vol>/examples (via a generated .slnx).
# - Runs each console project with `dotnet run --no-build` and each *.Tests
#   project with `dotnet test --no-build`.
# - Saves the real output to <project>/output.txt (absolute repo path is
#   replaced by <repo> so the text is the same on every machine).
# Special files inside a project folder:
#   run.args  -> arguments passed to the program (one line)
#   .norun    -> build only, do not run (the chapter explains why)
# Folders without a .csproj but with a run.sh are run with bash (output.txt too).
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"      # books/csharp
VOL="${1:?usage: run-examples.sh <volume-folder>}"
EX="$HERE/$VOL/examples"
REPO="$(cd "$HERE/../.." && pwd)"
cd "$EX"

mapfile -t PROJS < <(find . -name '*.csproj' -not -path '*/bin/*' -not -path '*/obj/*' | sort)
echo "== $VOL: ${#PROJS[@]} projects"

# Generate a solution so one `dotnet build` builds everything in parallel.
rm -f Examples.slnx
dotnet new sln --format slnx -n Examples >/dev/null
dotnet sln Examples.slnx add "${PROJS[@]}" >/dev/null
dotnet build Examples.slnx -nologo -v q -clp:NoSummary
fail=0
for p in "${PROJS[@]}"; do
  dir="$(dirname "$p")"; name="$(basename "$dir")"
  if [[ -f "$dir/.norun" ]]; then echo "-- $name (build only)"; continue; fi
  args=""; [[ -f "$dir/run.args" ]] && args="$(cat "$dir/run.args")"
  set +e
  if [[ "$name" == *.Tests ]]; then
    # --output Detailed lists every test; the repeated "  from <dll>" lines are removed.
    out="$(dotnet test --project "$p" --no-build --output Detailed 2>&1 | grep -v '^  from .*\.dll'; exit "${PIPESTATUS[0]}")"; code=$?
  else
    # shellcheck disable=SC2086
    out="$(cd "$dir" && dotnet run --no-build -- $args 2>&1)"; code=$?
  fi
  set -e
  printf '%s\n' "$out" | sed "s#$REPO#<repo>#g" > "$dir/output.txt"
  if [[ $code -ne 0 ]]; then echo "!! $name FAILED (exit $code)"; cat "$dir/output.txt"; fail=1
  else echo "ok $name"; fi
done
rm -f Examples.slnx

# Non-project examples: any folder with a run.sh (file-based apps, Java, TypeScript).
while IFS= read -r script; do
  dir="$(dirname "$script")"; name="$(basename "$dir")"
  [[ -n "$(find "$dir" -maxdepth 1 -name '*.csproj')" ]] && continue
  set +e; out="$(cd "$dir" && bash ./run.sh 2>&1)"; code=$?; set -e
  printf '%s\n' "$out" | sed "s#$REPO#<repo>#g" > "$dir/output.txt"
  if [[ $code -ne 0 ]]; then echo "!! $name FAILED (exit $code)"; cat "$dir/output.txt"; fail=1
  else echo "ok $name (run.sh)"; fi
done < <(find . -name run.sh -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/node_modules/*' | sort)
exit $fail
