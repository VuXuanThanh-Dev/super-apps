#!/usr/bin/env bash
# Chạy toàn bộ kiểm tra cho mọi app ví dụ của bộ sách Flutter:
#   flutter pub get (--enforce-lockfile) → dart format (kiểm tra) → flutter analyze → flutter test
#   → flutter build web → smoke test bản web trong Chromium headless (nếu có scripts/node_modules)
# Dùng:  bash books/flutter/scripts/check-all.sh [vol1-co-ban vol2-trung-cap ...]
# Yêu cầu: Flutter 3.47.5 (sandbox: /opt/flutter/bin), Node 22 cho smoke test.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="/opt/flutter/bin:$PATH"
export CI=1

VOLS=("$@")
if [ ${#VOLS[@]} -eq 0 ]; then
  for d in "$ROOT"/vol*/examples; do [ -f "$d/pubspec.yaml" ] && VOLS+=("$(basename "$(dirname "$d")")"); done
fi

# Chữ phải thấy trên màn hình đầu tiên của bản web (smoke test).
smoke_texts() {
  case "$1" in
    vol1-co-ban) echo "Việc cần làm|Còn 3 việc chưa xong" ;;
    vol2-trung-cap) echo "Sổ Từ Vựng|negotiate" ;;
    vol3-nang-cao) echo "Sổ Ghi Chú Bảo Mật|Tạo mã PIN" ;;
  esac
}

flutter --version 2>/dev/null | head -1
for vol in "${VOLS[@]}"; do
  dir="$ROOT/$vol/examples"
  echo "================ $vol ================"
  cd "$dir"
  if [ -d "$ROOT/$vol/ci" ]; then
    echo "--- yaml (ci/*.yml)"
    python3 -c "import sys,yaml; [yaml.safe_load(open(f)) for f in sys.argv[1:]]; print('yaml OK:', len(sys.argv)-1, 'file')" "$ROOT/$vol"/ci/*.yml
  fi
  echo "--- pub get"
  flutter pub get --enforce-lockfile >/tmp/flutter-book-pub.log 2>&1 || { tail -20 /tmp/flutter-book-pub.log; echo "PUB GET FAILED: $vol"; exit 1; }
  grep -E "Got dependencies|No dependencies changed|Changed [0-9]+ dependenc" /tmp/flutter-book-pub.log | tail -1 || true
  echo "--- format";   dart format --output=none --set-exit-if-changed lib test $( [ -d integration_test ] && echo integration_test ) 2>&1 | tail -1
  echo "--- analyze";  flutter analyze 2>&1 | tail -1
  flutter analyze >/dev/null 2>&1 || { echo "ANALYZE FAILED: $vol"; exit 1; }
  echo "--- test"
  if ! flutter test --reporter expanded >/tmp/flutter-book-test.log 2>&1; then
    tail -40 /tmp/flutter-book-test.log; echo "TEST FAILED: $vol"; exit 1
  fi
  tail -1 /tmp/flutter-book-test.log
  echo "--- build web"
  if ! flutter build web --no-web-resources-cdn --release >/tmp/flutter-book-web.log 2>&1; then
    tail -20 /tmp/flutter-book-web.log; echo "WEB BUILD FAILED: $vol"; exit 1
  fi
  grep -E "Built build/web" /tmp/flutter-book-web.log
  if [ -d "$ROOT/scripts/node_modules/playwright-core" ]; then
    echo "--- web smoke (Chromium headless)"
    IFS='|' read -r -a texts <<<"$(smoke_texts "$vol")"
    node "$ROOT/scripts/web-smoke.mjs" "$dir/build/web" "${texts[@]}"
  else
    echo "--- web smoke: bỏ qua (chạy 'cd books/flutter/scripts && npm ci' để bật)"
  fi
done
echo "ALL CHECKS PASSED: ${VOLS[*]}"
