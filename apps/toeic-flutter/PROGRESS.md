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

## Next
- M4: script check với private-data rỗng, build web, smoke test Chromium.
- M5: README.

## Blockers
- (chưa có)

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
