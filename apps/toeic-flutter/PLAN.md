# PLAN — App TOEIC bằng Flutter (Task 9)

## Mục tiêu (Goal)
Làm lại app học TOEIC của Task 5 (`apps/toeic/`, React Native) bằng **Flutter**, cùng tính năng,
dựa trên hai cuốn sách ở gốc repo (*TOEIC 900 — Word Families & Collocations*, Tập 1 + Tập 2).
Tính năng lõi: **chạm vào bất kỳ từ nào** trên mọi màn hình chữ để xem nghĩa, **offline**.

Nguyên tắc:
- Dùng đúng stack và phiên bản ghim trong `books/flutter/STACK.md` (Flutter 3.47.5 / Dart 3.13.4,
  provider, go_router, sqflite (+ ffi web), shared_preferences, flutter_tts, flutter_local_notifications…).
- Bám sát docs chính thức (docs.flutter.dev — đọc qua mã nguồn `flutter/website` ở commit cố định):
  kiến trúc MVVM (View + ViewModel), Repository + Service, Command + Result, DI bằng provider,
  go_router, fake khi test, cookbook SQLite.
- Dữ liệu lấy từ sách chỉ nằm trong `apps/toeic-flutter/private-data/` (git-ignore, repo public).
  App phải build, test và chạy được khi thư mục này rỗng (dùng bộ dữ liệu mẫu nhỏ).
- Dùng lại công việc của Task 5: pipeline dữ liệu, nội dung tự viết (định nghĩa, ví dụ, bài đọc,
  hội thoại), bảng từ bất quy tắc, test case của lemmatizer (port 1:1 sang Dart).

## Mục lục (các file trong `apps/toeic-flutter/`)
- `PLAN.md` — kế hoạch này
- `PROGRESS.md` — Done / Next / Blockers / Decisions (cập nhật sau mỗi milestone)
- `DATA-REPORT.md` — số lượng dữ liệu, kiểm tra import không mất dữ liệu (lossless)
- `README.md` — chạy trên iPhone / Android / web, thêm từ, xoá private-data
- `tools/` — script import dữ liệu (JSON của Task 5 → SQLite), kiểm tra, smoke test web
- `assets/` — dữ liệu mẫu (sample.db) + nội dung công khai lấy từ Task 5 (có ghi công)
- `private-data/` — dữ liệu từ sách (git-ignore; tạo lại bằng `bash tools/build_data.sh`)
- `lib/` — mã app theo cấu trúc của case study chính thức: `ui/<feature>/`, `data/`, `domain/`,
  `config/`, `routing/`, `utils/`
- `test/`, `testing/fakes/` — unit test + widget test, fake dùng chung

## Milestones
- **M0 — Plan**: file này, nhánh `task-9-toeic-flutter`.
- **M1 — Data**: script import dataset của Task 5 (JSON) → SQLite cho Flutter
  (`tools/import_dataset.py`), bộ mẫu `assets/data/sample.db` (+ test), kiểm tra lossless
  (xuất ngược SQLite → JSON và so sánh), `DATA-REPORT.md`.
- **M2 — Chạm để tra từ**: tokenizer + lemmatizer (port từ Task 5, test 1:1), từ điển offline
  (từ trong sách → từ chức năng → WordNet → "not found"), popup (định nghĩa, nghĩa tiếng Việt,
  IPA, TTS, họ từ, collocation, ví dụ, "Save to my list"), widget `TappableText` dùng ở mọi màn hình chữ.
- **M3 — Tính năng 1–8** (theo thứ tự, mỗi cái có test): 1 từ vựng theo unit/chủ đề + tìm kiếm;
  2 flashcard lặp lại ngắt quãng (SM-2 như Task 5); 3 quiz (nghĩa, điền chỗ trống, dạng từ,
  nối collocation, nghe); 4 bài đọc; 5 hội thoại nhập vai; 6 từ đã lưu + nhắc hằng ngày
  (thông báo cục bộ); 7 thống kê tiến độ; 8 chế độ tối (dark mode).
- **M4 — Chất lượng**: analysis chặt (flutter_lints + strict-casts/strict-raw-types…), cấu trúc
  theo feature, `flutter analyze` 0 issue, `flutter test` pass, `flutter build web` OK,
  script kiểm tra với private-data rỗng, script kiểm tra không commit chữ trong sách,
  smoke test bản web bằng Chromium headless (chạm từ → popup; flashcard; thống kê; dark mode).
- **M5 — README**: chạy trên iPhone (Mac + Xcode + Apple ID miễn phí; hoặc bản web trên Safari/PWA),
  Android, web; thêm từ (định dạng + lệnh import); xoá private-data trước khi public.

## Definition of Done (chép từ task)
- [x] Data import + DATA-REPORT.md
- [x] All book-derived content only in apps/toeic-flutter/private-data/ (not committed)
- [x] App runs with private-data empty
- [x] Tap-to-define works on every text screen, offline, with word forms
- [x] Features 1–8 done and tested
- [x] analyze, tests and web build pass
- [x] README complete
