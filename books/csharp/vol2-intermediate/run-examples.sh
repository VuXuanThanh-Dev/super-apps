#!/usr/bin/env bash
# Build + run all examples of this volume, then inject code/output into chapters.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/tools/run-examples.sh" vol2-intermediate
python3 "$ROOT/tools/embed.py" vol2-intermediate
