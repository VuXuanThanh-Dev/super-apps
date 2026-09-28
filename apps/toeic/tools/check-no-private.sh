#!/usr/bin/env bash
# Proves the app works with private-data/ EMPTY:
#   1. leak check (no book text in committed files)
#   2. move private-data/* away (restored automatically at the end)
#   3. type-check, lint, tests, and an iOS JS bundle (expo export) with the sample data
set -euo pipefail
cd "$(dirname "$0")/.."
APP_DIR="$(pwd)"

if [ -f private-data/extracted/entries.json ]; then
  python3 tools/check_no_book_text.py
fi

STASH="$(mktemp -d)"
restore() {
  shopt -s dotglob nullglob
  for f in "$STASH"/*; do mv "$f" "$APP_DIR/private-data/"; done
  rmdir "$STASH"
  echo "== private-data restored"
}
trap restore EXIT
shopt -s dotglob nullglob
for f in private-data/*; do
  [ "$(basename "$f")" = "README.md" ] || mv "$f" "$STASH/"
done
echo "== private-data now contains: $(ls -A private-data | tr '\n' ' ')"

echo "== tsc";    npx tsc --noEmit
echo "== eslint"; npx eslint .
echo "== jest";   npx jest --silent
echo "== expo export (ios bundle, sample data)"
OUT="$(mktemp -d)"
CI=1 npx expo export --platform ios --no-bytecode --output-dir "$OUT" > "$OUT.log" 2>&1 || { tail -30 "$OUT.log"; exit 1; }
BUNDLE="$(ls "$OUT"/_expo/static/js/ios/*.js)"
echo "bundle: $(du -h "$BUNDLE" | cut -f1)"
if grep -q 'source:"private"\|"source":"private"\|Contracts & Negotiations' "$BUNDLE"; then
  echo "FAIL: private data found in bundle"; exit 1
fi
if grep -q 'Office Basics' "$BUNDLE"; then
  echo "OK: bundle contains the sample dataset and no private data"
else
  echo "FAIL: sample dataset not found in bundle"; exit 1
fi
rm -rf "$OUT" "$OUT.log"
echo "== ALL CHECKS PASSED WITH EMPTY private-data"
