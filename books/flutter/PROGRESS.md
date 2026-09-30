# PROGRESS

## Done
- PLAN.md, .gitignore. PLAN có bảng đối chiếu docs chính thức → chương (yêu cầu mới của Nobin).
- M1: STACK.md (Flutter 3.47.5 / Dart 3.13.4, bảng package ghim cho Task 9, cách chạy trên iPhone). Đã thử `flutter pub get` + analyze + test + build web với toàn bộ package trong một dự án thử.

- M2: README, GLOSSARY, Tập 1 Ch.2 "Flutter cho Angular (và React Native) developer"; dự án `vol1-co-ban/examples` (app Việc Cần Làm + code Ch.1–8): analyze 0 issue, 55 test pass, build web OK, smoke test web OK; `scripts/check-all.sh`, `scripts/web-smoke.mjs`.

## Next
- M3: viết các chương còn lại của Tập 1 (01, 03–09) + README tập.

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
