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
  if [ -d "$ROOT/$vol/ci" ]; then
    echo "--- yaml (ci/*.yml)"
    python3 -c "import sys,yaml; [yaml.safe_load(open(f)) for f in sys.argv[1:]]; print('yaml OK:', len(sys.argv)-1, 'file')" "$ROOT/$vol"/ci/*.yml
  fi
  echo "--- typecheck";  npx tsc --noEmit
  echo "--- lint";       npx eslint . --max-warnings 0
  echo "--- test";       npx jest --ci
  # Lưu ý: "cmd && echo" KHÔNG làm set -e dừng script khi cmd lỗi, nên kiểm tra rõ ràng.
  echo "--- export web"
  if ! npx expo export --platform web --output-dir .export-web >/tmp/rn-book-export-web.log 2>&1; then
    tail -20 /tmp/rn-book-export-web.log; echo "WEB EXPORT FAILED: $vol"; exit 1
  fi
  echo "web bundle OK"
  echo "--- export ios"
  if ! npx expo export --platform ios --output-dir .export-ios >/tmp/rn-book-export-ios.log 2>&1; then
    tail -20 /tmp/rn-book-export-ios.log; echo "IOS EXPORT FAILED: $vol"; exit 1
  fi
  echo "ios bundle OK"
done
echo "ALL CHECKS PASSED: ${VOLS[*]}"
