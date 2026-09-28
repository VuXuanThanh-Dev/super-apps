---
name: vocabulary-extractor
description: Extract TOEIC-useful English vocabulary from a text Nobin gives (work email, meeting notes, article, passage) - base forms, word families, collocations, part of speech, a simple English definition written fresh, a Vietnamese meaning and an example - and output it in the TOEIC app's authored format (word|pos|simple definition|example) plus a review table. Use when asked to pull out, list or prepare new words, word families or collocations from English text, or to add words to the TOEIC app ("lấy từ vựng", "trích từ mới"). Not for roleplay or speaking practice (english-coach agent), not for writing English docs or PR text, and not for bulk-extracting copyrighted books into committed files.
compatibility: Python 3.10+. Optional but recommended - pip install simplemma (MIT, offline lemmatizer).
---

# Vocabulary extractor

Script chỉ **liệt kê ứng viên** (đếm, gộp dạng từ, loại từ đã biết). Việc **chọn từ hữu ích cho
TOEIC** và **viết định nghĩa** là việc của model, theo tiêu chí bên dưới.

## Steps

1. **Kiểm tra nguồn văn bản.** Văn bản của Nobin hoặc có license mở → dùng được.
   Nội dung lấy từ sách có bản quyền → kết quả chỉ để trong `apps/toeic/private-data/`
   (git-ignored), không commit ở chỗ khác.
2. **Lấy ứng viên**:
   ```bash
   python3 ${CLAUDE_SKILL_DIR}/scripts/extract_candidates.py input.txt \
     --known apps/toeic/data/authored/definitions/*.txt --top 60 > /tmp/candidates.json
   ```
   `--known` nhận file `.txt` (một từ/dòng hoặc dòng `word|pos|…` của app) và `dataset.json`
   → bỏ từ app đã có. `stats.lemmatizer` cho biết dùng `simplemma` hay luật đơn giản.
3. **Chọn 10–30 từ** theo [references/selection.md](references/selection.md): ưu tiên từ công việc
   văn phòng/kinh doanh hay gặp trong TOEIC, bỏ tên riêng, từ quá cơ bản, từ hiếm.
   Gom theo **họ từ (word family)**: schedule (v/n) → rescheduled…; thêm collocation thật sự xuất hiện
   trong văn bản (`bigrams`) hoặc rất phổ biến.
4. **Viết mục từ**: định nghĩa tiếng Anh đơn giản **tự viết** (≤ 15 từ, từ vựng dễ hơn từ được giải
   thích), nghĩa tiếng Việt ngắn, ví dụ lấy từ câu `context` (của Nobin) hoặc tự viết.
5. **Kiểm tra** theo checklist, rồi lưu file theo mẫu ở Expected output.

## Expected output

1. `new-words.txt` — đúng định dạng file `data/authored/definitions/*.txt` của app:
   ```
   # word|pos|simple definition|example  (original writing)
   renovation|n|work that repairs and improves a building|The office renovation will start next month.
   ```
2. Bảng review (Markdown) cho Nobin:

   | Từ | Loại | Nghĩa (vi) | Họ từ | Collocation | Ví dụ |
   |---|---|---|---|---|---|
   | renovation | n | sự cải tạo, sửa sang | renovate (v) | office renovation | … |

3. Một dòng thống kê thật từ script: `stats` (tokens, distinct_lemmas, known_skipped, returned).

## Quality checklist

- [ ] Mỗi dòng `new-words.txt` có đúng 4 trường, phân cách `|`, không có `|` trong nội dung.
- [ ] Không trùng từ đã có trong app (đã chạy với `--known`).
- [ ] Định nghĩa tự viết, không chép từ điển; nghĩa tiếng Việt ngắn gọn, đúng loại từ.
- [ ] Ví dụ đúng ngữ pháp, dùng đúng loại từ ghi ở cột pos.
- [ ] Không có tên riêng, số, từ chức năng; nguồn có bản quyền → chỉ lưu trong private-data.
