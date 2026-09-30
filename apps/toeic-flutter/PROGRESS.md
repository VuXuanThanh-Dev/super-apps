# PROGRESS — App TOEIC Flutter (Task 9)

Nhánh: `task-9-toeic-flutter` · PR: https://github.com/VuXuanThanh-Dev/super-apps/pull/9 · Cập nhật: 2026-09-30

## Done
- M0: PLAN.md, PR nháp #9.
- M1 Data: `tools/import_dataset.py` (JSON Task 5 → SQLite, kiểm tra lossless bằng xuất ngược),
  `tools/build_data.sh` (chạy 2 bước riêng của pipeline Task 5 + import), `tools/sync_from_toeic.sh`
  (nội dung công khai + `assets/data/sample.db`), `tools/import_words.py` (thêm từ, dùng lại parser Task 5),
  `tools/check_no_book_text.py` (0 hit), DATA-REPORT.md. Test Dart: sample.db đọc ngược == JSON gốc.
- Khung app (Flutter 3.47.5, pin theo STACK.md) + code M2/M3 đã viết.
- M2 Chạm để tra từ: tokenizer + lemmatizer port 1:1 (test case giống hệt Task 5), từ điển offline, popup
  (định nghĩa, nghĩa Việt, IPA, TTS, họ từ, collocation, ví dụ, Save, Back khi chạm từ trong popup),
  `TappableText` (TextSpan + TapGestureRecognizer). Widget test: `test/ui/lookup_test.dart`,
  `test/ui/tap_everywhere_test.dart` (mọi từ trong bài đọc, câu hỏi, đáp án, hội thoại, trang từ, mẹo, flashcard).

- M3 Tính năng 1–8 (mỗi cái có test): 1 từ vựng + tìm kiếm, 2 flashcard SM-2, 3 quiz (5 loại), 4 bài đọc,
  5 hội thoại nhập vai, 6 từ đã lưu + nhắc hằng ngày (flutter_local_notifications), 7 thống kê, 8 dark mode.
  Test: `test/ui/view_models_test.dart` (ViewModel + fake, theo docs), `test/ui/features_test.dart`
  (widget test cả app). Tổng: 141 test pass. Tap trượt trong test = lỗi (`test/flutter_test_config.dart`).
  Lỗi thật tìm được nhờ test: dropdown tràn chữ (sửa `isExpanded`), spinner quiz không tắt (màn hình giờ nghe cả
  Command `load`), Home/Saved bỏ lỡ cập nhật khi dữ liệu đổi trong lúc đang tải (thêm cờ `_dirty`).

- M4 Chất lượng: analysis chặt (flutter_lints 6 + strict-casts/strict-inference/strict-raw-types + vài luật),
  `flutter analyze` 0 issue, 141 test pass (+1 skip khi private-data rỗng), `flutter build web` OK.
  `tools/check_no_private.sh`: leak check → dời private-data → pub get → format → analyze → test → build web
  → kiểm tra bản web có sample.db, không có toeic.db → smoke test Chromium. Log: `logs/check-no-private.txt`.
  Smoke test (`tools/web-smoke.cjs`): Home stats, chạm từ → popup, flashcard, đếm review, dark mode — PASS
  với cả dữ liệu mẫu (ảnh `logs/screenshots/`) và dữ liệu đầy đủ (`logs/web-smoke-private.txt`).
  Cấu hình native: Android desugaring + receiver thông báo, iOS delegate thông báo (theo README package).
  Lỗi thật tìm được nhờ smoke test: trên web, máy chủ trả index.html cho file không tồn tại → app mở
  "private-data/toeic.db" giả và crash. Sửa: chọn asset theo AssetManifest + kiểm tra header SQLite (có test).

- M5 README: chạy trên iPhone (Cách A Mac + Xcode + Apple ID miễn phí theo docs "Set up iOS development";
  Cách B web trên Safari/Add to Home Screen, có ghi rõ giới hạn; Cách C TestFlight), Android, web; tạo dữ liệu;
  thêm từ; xoá private-data. Link checker `tools/check_links.py` → `logs/check-links.txt` (0 link hỏng;
  docs.flutter.dev bị chặn — đã kiểm tra file nguồn tương ứng trên raw.githubusercontent.com).

## Next (không bắt buộc)
- Chạy thật trên iPhone (Mac + Xcode) và Android — NOT RUN trong sandbox.
- Integration test (`integration_test`) chạy bằng `flutter drive` trên Chrome.

## Blockers
- Không có iPhone/Mac/Android SDK trong sandbox → **Chạy trên iPhone/Android: NOT RUN** (chỉ có web + test).
- docs.flutter.dev, api.flutter.dev, dart.dev bị chặn → đọc mã nguồn docs ở repo flutter/website (commit
  ab59c614…). Cần từ Nobin: cho phép các host này trong Network access nếu muốn kiểm tra trực tiếp.

## Decisions
- Cấu trúc thư mục theo case study chính thức (`ui/<feature>/{view_models,widgets}`, `data/`, `domain/`,
  `config/`, `routing/`, `utils/`, `testing/fakes/`) — docs gọi đây là kết hợp "by feature" (UI) và "by type" (data).
- Dataset = file SQLite đóng gói làm asset (`private-data/toeic.db` nếu có, không thì `assets/data/sample.db`);
  khi mở app ghi ra file bằng `writeDatabaseBytes`, đọc hết vào RAM (1.120 từ) → tra từ đồng bộ, offline.
- Dữ liệu người dùng = SQLite riêng `toeic_user.db` (khoá = chữ thường của từ, giống Task 5); cài đặt =
  shared_preferences (giống app mẫu Tập 2).
- Không chạy `apps/toeic/tools/build_data.sh` (nó ghi đè file đã commit của Task 5); chỉ chạy
  `extract_books.py` + `build_dataset.py` (chỉ ghi vào `apps/toeic/private-data/`, bị git-ignore).
- Đóng gói font Noto Sans (OFL) để chữ Việt + IPA hiện đúng khi offline (web không tải font từ CDN).
- Giữ SM-2 như Task 5 (đơn giản, test được, không cần dữ liệu huấn luyện).
- Đáp án bài đọc: chữ của đáp án là TappableText (tra được), nút A–D để trả lời (giống Task 5: mọi từ chạm được).
- Smoke test đặt locale `en-US` cho Chromium: sandbox không có biến LANG nên Chromium báo "en-US@posix",
  Flutter web từ chối locale này ("Incorrect locale information provided"). Trình duyệt thật không bị.
- Smoke test chạm nút "Dark" bằng toạ độ chuột (page.mouse) vì một node semantics rỗng che màn hình Settings
  trên web; locator.click() của Playwright bị từ chối. **UNVERIFIED:** nguyên nhân node đó (có thể do route
  transition của go_router/Navigator trên web); không ảnh hưởng người dùng chạm bằng ngón tay.
