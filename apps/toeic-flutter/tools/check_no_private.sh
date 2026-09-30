#!/usr/bin/env bash
# Proves the app works with private-data/ EMPTY (same idea as Task 5's tools/check-no-private.sh):
#   1. leak check: no book text in committed files (needs the Task 5 extraction; else SKIP)
#   2. move private-data/* away (restored automatically at the end, even on failure)
#   3. flutter pub get (lockfile) -> dart format (check) -> flutter analyze -> flutter test
#   4. flutter build web -> the build contains the sample DB and NO private DB
#   5. optional: headless-Chromium smoke test of that web build (needs global Playwright)
# Usage (from apps/toeic-flutter/): bash tools/check_no_private.sh [--no-smoke]
set -euo pipefail
cd "$(dirname "$0")/.."
APP_DIR="$(pwd)"
export PATH="/opt/flutter/bin:$PATH"
export CI=1   # flutter: no analytics / no interactive prompts

echo "== flutter: $(flutter --version 2>/dev/null | head -1)"
echo "== leak check";  python3 tools/check_no_book_text.py

STASH="$(mktemp -d)"
restore() {
  shopt -s dotglob nullglob
  for f in "$STASH"/*; do mv "$f" "$APP_DIR/private-data/"; done
  rmdir "$STASH"
  echo "== private-data restored: $(ls -A "$APP_DIR/private-data" | tr '\n' ' ')"
}
trap restore EXIT
shopt -s dotglob nullglob
for f in private-data/*; do
  [ "$(basename "$f")" = "README.md" ] || mv "$f" "$STASH/"
done
echo "== private-data now contains: $(ls -A private-data | tr '\n' ' ')"

echo "== pub get";  flutter pub get --enforce-lockfile >/dev/null 2>&1 && echo "OK"
echo "== format";   dart format --output=none --set-exit-if-changed lib test testing | tail -1
echo "== analyze";  flutter analyze 2>&1 | tail -1
flutter analyze >/dev/null 2>&1 || { echo "ANALYZE FAILED"; exit 1; }
echo "== test"
LOG="$(mktemp)"
if ! flutter test --reporter expanded >"$LOG" 2>&1; then tail -40 "$LOG"; echo "TEST FAILED"; exit 1; fi
grep -c "private dataset (only when private-data/toeic.db exists).*Skip" "$LOG" >/dev/null && echo "(private-dataset test skipped, as expected)"
tail -1 "$LOG"; rm -f "$LOG"
echo "== build web (release, no CDN)"
flutter build web --no-web-resources-cdn --release >"$APP_DIR/build-web.log" 2>&1 || { tail -20 "$APP_DIR/build-web.log"; exit 1; }
grep -E "Built build/web" "$APP_DIR/build-web.log"; rm -f "$APP_DIR/build-web.log"
if [ -e build/web/assets/private-data/toeic.db ]; then echo "FAIL: private DB found in the web build"; exit 1; fi
if [ -f build/web/assets/assets/data/sample.db ]; then
  echo "OK: web build contains the sample DB and no private DB"
else
  echo "FAIL: sample DB missing from the web build"; exit 1
fi
if [ "${1:-}" != "--no-smoke" ] && [ -d "$(npm root -g 2>/dev/null)/playwright" ]; then
  echo "== web smoke (headless Chromium)"
  NODE_PATH="$(npm root -g)" node tools/web-smoke.cjs build/web
else
  echo "== web smoke: skipped (needs global playwright, or --no-smoke given)"
fi
echo "== ALL CHECKS PASSED WITH EMPTY private-data"
