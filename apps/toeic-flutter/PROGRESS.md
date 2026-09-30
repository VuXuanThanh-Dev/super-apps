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

## Next
- M3: test view model + widget cho tính năng 1–8.
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
