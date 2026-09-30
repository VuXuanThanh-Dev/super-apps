# PROGRESS

## Done
- PLAN.md, .gitignore. PLAN có bảng đối chiếu docs chính thức → chương (yêu cầu mới của Nobin).
- M1: STACK.md (Flutter 3.47.5 / Dart 3.13.4, bảng package ghim cho Task 9, cách chạy trên iPhone). Đã thử `flutter pub get` + analyze + test + build web với toàn bộ package trong một dự án thử.

- M2: README, GLOSSARY, Tập 1 Ch.2 "Flutter cho Angular (và React Native) developer"; dự án `vol1-co-ban/examples` (app Việc Cần Làm + code Ch.1–8): analyze 0 issue, 55 test pass, build web OK, smoke test web OK; `scripts/check-all.sh`, `scripts/web-smoke.mjs`.

- M3: Tập 1 — 9 chương + README tập; app "Việc Cần Làm": analyze 0 issue, 58 test, build web OK, smoke web OK (`logs/check-vol1.txt`).

- M4: Tập 2 — 8 chương + README; app "Sổ Từ Vựng" (provider MVVM, sqflite + web Wasm, TTS, local notifications, Command/Result): analyze 0 issue, 51 test, build web OK, smoke web OK (SQLite Wasm chạy), integration test chạy thật trên Chrome headless (`logs/check-vol2.txt`, `logs/integration-web-vol2.txt`).

## Next
- M5: Tập 3 — dự án `vol3-nang-cao/examples` (app "Sổ Ghi Chú Bảo Mật": feature-first, PIN, secure storage, platform channel, monitoring) + 8 chương + ci/.

## Blockers
- Bị chặn: docs.flutter.dev, api.flutter.dev, dart.dev, www.gstatic.com (CDN CanvasKit), docs.github.com, codemagic.io. Cách vòng: mã nguồn docs trên GitHub (commit ghim), `--no-web-resources-cdn`.
- Không có Mac/Xcode/iPhone/Android SDK → chạy trên thiết bị: NOT RUN.

## Decisions
- Branch: task-8-flutter (dựa trên origin/main).
- Cấu trúc giống `books/react-native/`: 3 tập, mỗi tập 1 dự án Flutter trong `examples/`.
- Theo docs chính thức: provider + ChangeNotifier (MVVM), go_router, sqflite (+ffi để test, +ffi_web cho web), shared_preferences.
- Package docs không nêu tên: flutter_tts, flutter_local_notifications (+timezone, flutter_timezone), flutter_secure_storage, crypto, sqflite_common_ffi_web.
- Nguồn docs: flutter/website @ ab59c614e780e2d6d44f07ae4a96238028f581a5 (CC BY 3.0 / BSD); dart-lang/site-www @ 001b59a9 (CC BY 4.0 / BSD-3).
- PR nháp: https://github.com/VuXuanThanh-Dev/super-apps/pull/8
- Tập 1: store truyền qua constructor (chưa dùng provider — để Tập 2 dạy); theme mode giữ trong bộ nhớ (lưu bền ở Tập 2).
- Code dùng `dart format` page_width 120 (analysis_options.yaml) để đoạn code trong sách gọn; check-all kiểm tra format.
- Smoke test web: bật semantics của Flutter web rồi tìm chữ trong DOM (Chromium headless 390×844); tài nguyên ngoài bị sandbox chặn (fonts.gstatic.com) chỉ là cảnh báo.
- Tập 2: ghim thêm `sqlite3: 3.6.0` để khớp `web/sqlite3.wasm` do `sqflite_common_ffi_web:setup` tải (bản sqlite3-3.6.0); import có điều kiện cho web.
- Result/Command lấy theo mẫu chính thức (BSD, giữ header bản quyền).
- Dùng tham số có tên private (Dart 3.12) trong ViewModel theo gợi ý lint `prefer_initializing_formals`.
- Integration test web: chromedriver 141.0.7390.37 tải từ storage.googleapis.com (Chrome for Testing), script `scripts/integration-web.sh`; trên thiết bị: NOT RUN.
- Cấu hình native cho notifications (AppDelegate, Gradle desugaring, receivers) thêm theo README package — build iOS/Android NOT RUN.
