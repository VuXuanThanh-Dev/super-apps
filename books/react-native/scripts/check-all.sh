#!/usr/bin/env bash
# Chạy toàn bộ kiểm tra cho mọi app ví dụ của bộ sách:
#   npm ci (nếu chưa cài) → tsc --noEmit → eslint → jest → expo export (web + ios)
# Dùng:  bash books/react-native/scripts/check-all.sh [vol1-co-ban vol2-trung-cap ...]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export EXPO_OFFLINE=1          # sandbox chặn api.expo.dev; Expo CLI dùng dữ liệu có sẵn trong gói expo
export EXPO_NO_TELEMETRY=1
export CI=1

VOLS=("$@")
if [ ${#VOLS[@]} -eq 0 ]; then
  VOLS=()
  for d in "$ROOT"/vol*/examples; do [ -f "$d/package.json" ] && VOLS+=("$(basename "$(dirname "$d")")"); done
fi

for vol in "${VOLS[@]}"; do
  dir="$ROOT/$vol/examples"
  echo "================ $vol ================"
  cd "$dir"
  [ -d node_modules ] || npm ci --no-audit --no-fund
  echo "--- typecheck";  npx tsc --noEmit
  echo "--- lint";       npx eslint .
  echo "--- test";       npx jest --ci
  echo "--- export web"; npx expo export --platform web --output-dir .export-web >/dev/null && echo "web bundle OK"
  echo "--- export ios"; npx expo export --platform ios --output-dir .export-ios >/dev/null && echo "ios bundle OK"
done
echo "ALL CHECKS PASSED: ${VOLS[*]}"
