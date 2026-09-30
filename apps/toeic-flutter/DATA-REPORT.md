# DATA-REPORT — Dữ liệu của app TOEIC Flutter

Ngày: 2026-09-30. Mọi con số dưới đây lấy từ lần chạy thật các script trong `tools/`
(xem mục 6 "Cách chạy lại"). Dữ liệu lấy từ sách chỉ nằm trong `private-data/` và **không commit**.

## 1. Ý tưởng đơn giản

App Flutter **không trích xuất lại** hai file PDF. Nó dùng lại pipeline của Task 5 (`apps/toeic/`):

```
PDF (2 cuốn) ──(Task 5: extract_books.py + build_dataset.py)──▶ apps/toeic/private-data/dataset.json
                                                                   │  (JSON, schema của Task 5)
                                        tools/build_data.sh        ▼
                          private-data/source/dataset.json ──(+ my-words)──▶ tools/import_dataset.py
                                                                   │
                                                                   ▼
                                    private-data/toeic.db (SQLite, app đọc khi khởi động)
```

Khi `private-data/` rỗng, app dùng bộ mẫu công khai `assets/data/sample.db`
(tạo từ `apps/toeic/src/data/sample/dataset.json` — 16 từ tự viết ở Task 5).

## 2. Nguồn dữ liệu

| Nguồn | Lấy gì | Giấy phép / chỗ lưu |
|---|---|---|
| `apps/toeic/private-data/dataset.json` (Task 5, tạo từ 2 PDF) | từ, loại từ, IPA, nghĩa Việt, họ từ, collocation, chủ đề, mẹo | chỉ học riêng → `private-data/` (git-ignore) |
| `apps/toeic/src/data/sample/dataset.json` | bộ mẫu 16 từ (tự viết ở Task 5) | công khai → `test/fixtures/sample_dataset.json`, `assets/data/sample.db` |
| `apps/toeic/src/content/dialogs.json` | 8 hội thoại nhập vai (tự viết ở Task 5) | công khai → `assets/content/` |
| `apps/toeic/src/content/function-words.json` | nghĩa của từ chức năng (the, do, of…) (tự viết ở Task 5) | công khai → `assets/content/` |
| `apps/toeic/src/data/generic-glosses.json` | định nghĩa dự phòng (WordNet 3.0) cho từ trong nội dung công khai | WordNet 3.0 license → `assets/content/` |
| `apps/toeic/src/features/lookup/irregular.json` | 5.459 dạng bất quy tắc (WordNet exception lists) | WordNet 3.0 license → `assets/content/` |

Định nghĩa tiếng Anh, câu ví dụ, 24 bài đọc và hội thoại đều do Task 5 **tự viết** (không chép sách);
ghi công: thư mục `apps/toeic/` (xem `apps/toeic/DATA-REPORT.md`, mục 4b). Giấy phép WordNet/CMUdict:
`apps/toeic/tools/LICENSES.md`. Chép sang app này bằng `bash tools/sync_from_toeic.sh`.

## 3. Số lượng (lần chạy 2026-09-30)

| Mục | Bộ riêng (`private-data/toeic.db`) | Bộ mẫu (`assets/data/sample.db`) |
|---|---|---|
| Chủ đề (unit) | 24 | 2 |
| Họ từ (word family) | 312 | 9 |
| Dạng từ (word form) | 1.120 | 16 |
| Collocation | 1.296 | 14 |
| Bài đọc / câu hỏi | 24 / 48 | 2 / 4 |
| Định nghĩa WordNet (riêng) | 1.674 | 0 |
| Kích thước file | 880.640 byte | 90.112 byte |

Nội dung công khai (`assets/content/`): 8 hội thoại, 138 từ chức năng, 303 định nghĩa WordNet chung, 5.459 dạng bất quy tắc.

Ghi chú: `apps/toeic/DATA-REPORT.md` ghi 1.664 định nghĩa WordNet riêng; lần chạy pipeline Task 5 hôm nay
in ra **1.674** (dòng `build_dataset.py` bên dưới). Có thể do nội dung công khai của Task 5 đã đổi sau khi viết
báo cáo; các số khác (312 / 1.120 / 1.296 / 24) giống hệt. **UNVERIFIED:** nguyên nhân chính xác của chênh lệch 10.

## 4. Chất lượng dữ liệu — dùng lại số của Task 5

App này nhận **nguyên** dataset của Task 5, nên chất lượng trích xuất giống Task 5
(chi tiết: [apps/toeic/DATA-REPORT.md](../toeic/DATA-REPORT.md)):

- 238 trang (120 + 118), 0 trang không đọc được, 0 trang cần OCR.
- Phủ 100% chỉ mục của sách (1.118 dòng chỉ mục, 0 từ thiếu).
- Kiểm tra tay 50 mục ngẫu nhiên: 1/50 lỗi (2 %) sau khi sửa (thiếu IPA cho "fulfilment").
- 17 dạng từ không có IPA (không có trong CMUdict).
- Kiểm tra "tự viết": 0 câu trùng nguyên văn với sách, 0 định nghĩa giống sách ≥ 0,8.

## 5. Kiểm tra của riêng app này: import không mất dữ liệu (lossless)

**Cách 1 — Python (mỗi lần import):** `tools/import_dataset.py` ghi JSON → SQLite, rồi **đọc ngược**
SQLite → JSON (`export_dataset`) và so sánh **từng trường, đúng thứ tự** với file đầu vào. Khác một chỗ → exit 1.

Output thật (2026-09-30):

```
$ SKIP_TASK5_BUILD=1 bash tools/build_data.sh
my-words: 0 file(s), 0 added, 0 updated
{"in": {"source": "private", "topics": 24, "families": 312, "words": 1120, "collocations": 1296, "passages": 24, "questions": 48, "glosses": 1674}, "db": {"source": "private", "topics": 24, "families": 312, "words": 1120, "collocations": 1296, "passages": 24, "questions": 48, "glosses": 1674}, "lossless": true}

$ bash tools/sync_from_toeic.sh
{"in": {"source": "sample", "topics": 2, "families": 9, "words": 16, "collocations": 14, "passages": 2, "questions": 4, "glosses": 0}, "db": {"source": "sample", "topics": 2, "families": 9, "words": 16, "collocations": 14, "passages": 2, "questions": 4, "glosses": 0}, "lossless": true}
synced from ../toeic
```

**Cách 2 — Dart (trong `flutter test`):** `test/data/dataset_service_test.dart` đọc `assets/data/sample.db`
bằng đúng code của app (`DatasetService.readDataset`), xuất `Dataset.toJson()` và so sánh bằng `==` với
`test/fixtures/sample_dataset.json` (bản JSON gốc của Task 5). Test này pass (xem PROGRESS.md).
`test/domain/dictionary_test.dart` còn đọc `private-data/toeic.db` (nếu có) và kiểm tra 312 họ từ,
≥ 1.100 dạng từ và 6 dạng từ → lemma (negotiations → negotiation, complied → comply, …) như Task 5.

**Thêm từ của bạn** (`tools/import_words.py`) cũng qua cùng bước kiểm tra. Ví dụ thật với
`examples/my-words.example.txt` (2 từ, 1 collocation):

```
my-words: 1 file(s), 2 added, 0 updated
{"in": {..., "topics": 25, "families": 314, "words": 1122, "collocations": 1297, ...}, "db": {... giống hệt ...}, "lossless": true}
```

## 6. Schema SQLite (`tools/import_dataset.py`)

| Bảng | Cột chính | Ghi chú |
|---|---|---|
| `meta` | key, value | `version`, `source` (private/sample), `schema` |
| `topics` | code, book, en, vi, ord | |
| `families` | id, headword, topic, book, band850, tip, page, ord | |
| `family_members` | family_id, word_id, pos | thứ tự thành viên (headword đầu tiên) |
| `words` | id, word, lemma, pos, ipa, ipa_source, definition, example, vi, note, topic, book, family, is_head, ord | index `word COLLATE NOCASE` |
| `word_families` | word_id, family_id, pos | một từ có thể thuộc nhiều họ |
| `collocations` | id, family, phrase, vi, example, ord | |
| `passages` / `questions` | … / passage_id, pos, question, options (JSON), answer | |
| `glosses` | word, pos, definition, ord | WordNet |

Cột `ord` giữ đúng thứ tự của JSON, để xuất ngược ra JSON giống hệt.

## 7. Git: private-data

- Repo `VuXuanThanh-Dev/super-apps` là **public** (Task 5 đã kiểm tra bằng GitHub API ngày 2026-09-28).
- `private-data/*` bị git-ignore, chỉ commit `private-data/README.md`.
- `tools/check_no_book_text.py` (cùng cách làm với Task 5) tìm 3.684 chuỗi dài của sách trong mọi file
  được theo dõi hoặc chưa bị ignore của app (kể cả file nhị phân như `sample.db`) và báo lỗi nếu có file nào
  trong `private-data/` (trừ README) bị commit. Output thật: `checked 131 files against 3684 book strings: 0 hit(s)`.
  Kiểm tra ngược: tạo file thử chứa một câu ví dụ của sách → script báo `1 hit(s)` (đã xoá file thử).

## 8. Cách chạy lại

```bash
cd apps/toeic-flutter
pip install -r ../toeic/tools/requirements.txt       # pymupdf, cmudict, nltk (Python 3.11)
python3 -c "import nltk; nltk.download('wordnet')"
bash tools/build_data.sh                              # ~20 giây: Task 5 pipeline + import + lossless check
bash tools/sync_from_toeic.sh                         # nội dung công khai + sample.db (chỉ khi Task 5 đổi)
python3 tools/check_no_book_text.py                   # 0 hit(s)
```

Output thật của bước Task 5 bên trong `build_data.sh` (2026-09-30):

```
entries=312 index_words=1118 pages=238 ocr=0 unreadable=0
{"topics": 24, "families": 312, "words": 1120, "collocations": 1296, "passages": 24, "glosses": 1674, "missing_definition": 0, "missing_ipa": 17, "ipa_book": 310, "ipa_cmudict": 793}
```

## Nguồn tham khảo (Sources)

- Báo cáo dữ liệu Task 5 (trong repo): `apps/toeic/DATA-REPORT.md`, giấy phép: `apps/toeic/tools/LICENSES.md`
- Docs Flutter — Persist data with SQLite (cookbook): https://docs.flutter.dev/cookbook/persistence/sqlite —
  nguồn: https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/persistence/sqlite.md
- Docs Flutter — Persistent storage architecture: SQL: https://docs.flutter.dev/app-architecture/design-patterns/sql —
  nguồn: https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/design-patterns/sql.md
- sqflite (API `writeDatabaseBytes`, đọc trong mã nguồn package 2.4.4 / sqflite_common 2.5.13 sau `flutter pub get`): https://pub.dev/packages/sqflite
- sqflite_common_ffi_web: https://pub.dev/packages/sqflite_common_ffi_web
