# PROGRESS

## Done
- M1: STACK.md — Flutter 3.47.5 / Dart 3.13.4, bảng package ghim exact cho cả bộ sách và cho Task 9 (mục 5), cách chạy trên iPhone (mục 4), trích pub.dev + mã nguồn docs chính thức có ngày.
- M2: PLAN.md (có bảng đối chiếu docs chính thức → chương), README, GLOSSARY, Tập 1 Ch.2 "Flutter cho Angular (và React Native) developer".
- M3: Tập 1 — 9 chương, app "Việc Cần Làm": analyze 0 issue, 58 test, build web, smoke web.
- M4: Tập 2 — 8 chương, app "Sổ Từ Vựng" (provider MVVM, sqflite + SQLite Wasm cho web, flutter_tts, flutter_local_notifications, Command/Result): 51 test, build web, smoke web, integration test chạy thật trên Chrome headless.
- M5: Tập 3 — 8 chương, app "Sổ Ghi Chú Bảo Mật" (feature-first + test luật phụ thuộc, PIN, secure storage, MethodChannel Swift/Kotlin, logger + bắt lỗi toàn app) + 2 workflow CI mẫu: 31 test, build web, smoke web.
- M6: 3 PDF trong `dist/` (87 + 65 + 58 trang, 11 sơ đồ Mermaid), kiểm tra dấu OK, link check 0 hỏng (116 bị chặn bởi sandbox), check-all cả 3 tập pass.
- Bằng chứng: `logs/check-all.txt`, `logs/check-vol{1,2,3}.txt`, `logs/integration-web-vol2.txt`, `logs/build-pdf.txt`, `logs/check-pdf-accents.txt`, `logs/check-links.txt`.
- PR #8 (M1–M5) đã được Nobin merge vào main (2026-09-30). M6: PR #10.

## Next (việc còn lại — cần máy thật / tài khoản)
- Chạy 3 app trên iPhone (Mac + Xcode) và Android: NOT RUN trong sandbox.
- Biên dịch code native: AppDelegate.swift / MainActivity.kt (platform channel Tập 3; cấu hình notifications Tập 2).
- Kiểm tra trên thiết bị: đọc to (TTS), thông báo theo lịch, Keychain/Keystore, tự khóa khi vào nền, bản web trên Safari iOS.
- Chạy thật workflow CI mẫu (`vol3-nang-cao/ci/*.yml`) và TestFlight (cần Apple Developer Program).

## Blockers
- Bị chặn (403 / connect rejected) trong sandbox: docs.flutter.dev, api.flutter.dev, dart.dev, www.gstatic.com + fonts.gstatic.com (CDN CanvasKit/font), api.dictionaryapi.dev, jsonplaceholder.typicode.com, docs.github.com, codemagic.io, googlechromelabs.github.io; github.com qua curl.
  Đã thử: curl, WebFetch. Cách vòng: mã nguồn docs trên GitHub (flutter/website @ ab59c614e780e2d6d44f07ae4a96238028f581a5, dart-lang/site-www @ 001b59a9), `--no-web-resources-cdn`, MockClient cho HTTP, chromedriver tải từ storage.googleapis.com.
  Cần từ Nobin (nếu muốn kiểm tra lại): cho phép các host này trong Network access của môi trường.
- Không có Mac / Xcode / iPhone / Android SDK / tài khoản Apple-Google trong sandbox.

## Decisions
- Branch: task-8-flutter. PR #8 (M1–M5, đã merge): https://github.com/VuXuanThanh-Dev/super-apps/pull/8 . M6: nhánh đặt lại lên origin/main (fast-forward, không force-push), PR mới: https://github.com/VuXuanThanh-Dev/super-apps/pull/10
- Theo docs chính thức: provider + ChangeNotifier (MVVM), go_router, sqflite (+ sqflite_common_ffi để test, + sqflite_common_ffi_web cho web — docs gọi là experimental), shared_preferences, Command/Result (mẫu BSD, giữ header).
- Package docs không nêu tên (lựa chọn của sách): flutter_tts, flutter_local_notifications (+ timezone, flutter_timezone), flutter_secure_storage, crypto, mocktail (case study có dùng).
- Ghim exact + commit pubspec.lock; ghim thêm `sqlite3: 3.6.0` cho khớp `web/sqlite3.wasm`. Docs Security khuyên tránh ghim cứng → sách ghi rõ đánh đổi và khuyên `flutter pub outdated` hằng tháng.
- Mỗi tập = 1 dự án Flutter (`flutter create --platforms=ios,android,web --org dev.nobin`), tab Lab mở ví dụ từng chương; `dart format` page_width 120.
- App TOEIC (Task 9) nên theo cấu trúc KẾT HỢP của docs như app Tập 2 (UI theo feature, data theo loại); Tập 3 minh họa feature-first thuần theo đề bài.
- Kiểm tra web: build `--no-web-resources-cdn` + smoke test Chromium (bật semantics); integration test web bằng flutter drive + chromedriver 141.
- Lỗi thật tìm được nhờ test: pump lại app cần UniqueKey; pumpAndSettle treo với animation lặp; MethodChannel chưa mock treo trong testWidgets; Uri.parse chuẩn hóa ".."; tên `matches` trùng matcher của flutter_test; kết quả tìm kiếm cũ về muộn (race) → requestId.
- PDF: pandoc 3.1.3 → HTML (Noto) → Chromium (playwright-core 1.56.1) + mermaid 12.0.0 local (script lấy từ sách React Native).
