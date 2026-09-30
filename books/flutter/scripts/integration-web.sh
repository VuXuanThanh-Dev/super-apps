#!/usr/bin/env bash
# Chạy integration_test của một tập trên Chrome headless bằng `flutter drive` + chromedriver.
# Dùng: bash books/flutter/scripts/integration-web.sh vol2-trung-cap
# Yêu cầu: Chrome/Chromium + chromedriver CÙNG phiên bản, chromedriver chạy ở cổng 4444.
#   Sandbox của sách: Chromium 141.0.7390.37 (Playwright) + chromedriver 141.0.7390.37 tải từ
#   https://storage.googleapis.com/chrome-for-testing-public/141.0.7390.37/linux64/chromedriver-linux64.zip
#   và một script /usr/local/bin/google-chrome gọi Chromium với --no-sandbox.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VOL="${1:-vol2-trung-cap}"
export PATH="/opt/flutter/bin:$PATH"
export CHROME_EXECUTABLE="${CHROME_EXECUTABLE:-/usr/local/bin/google-chrome}"
cd "$ROOT/$VOL/examples"
if ! curl -s http://127.0.0.1:4444/status >/dev/null; then
  CD="${CHROMEDRIVER:-/tmp/cd/chromedriver-linux64/chromedriver}"
  "$CD" --port=4444 >/tmp/chromedriver.log 2>&1 &
  sleep 1
fi
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart \
  -d web-server --browser-name=chrome --headless --no-web-resources-cdn 2>&1 \
  | grep -vE "Woah|superuser|^\s*/$|📎|available\)$|newer versions|pub outdated"
