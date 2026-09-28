---
name: handbook-chapter-writer
description: Write or restructure one chapter of Nobin's Vietnamese technical handbooks (Java OCP, React Native, C#) with the fixed structure Mục tiêu → Giải thích đơn giản → Ví dụ → Đi sâu → Lỗi và bẫy thường gặp → Tóm tắt → Bài tập (có lời giải) → Nguồn tham khảo, Vietnamese text with English terms explained on first use, runnable examples in examples/, and GLOSSARY.md updates. Use when asked to write, draft, rewrite or check a book/handbook chapter ("viết chương", "chapter"). Not for README, ADR, wiki or general bilingual docs (docs-writer agent), not for building the PDF (vietnamese-pdf-builder) and not for OCP practice questions (ocp-question-writer).
---

# Handbook chapter writer

Sách dạy theo thứ tự: **ý tưởng đơn giản → ví dụ thật → chi tiết sâu**. Người đọc: lập trình viên
Việt Nam, tiếng Anh khoảng TOEIC 600.

## Steps

1. **Đọc bối cảnh sách**: `PLAN.md`, `GLOSSARY.md`, chương trước/sau, file phiên bản công cụ
   (`STACK.md`, `global.json`, README). Không đổi phiên bản đã ghim.
2. **Nghiên cứu**: chỉ nguồn chính thức (docs, spec, repo GitHub của dự án). Ghi ngày mở.
   Không mở được (bị chặn) → nêu nguồn gốc bằng GitHub mirror hoặc ghi **UNVERIFIED**.
   Không chép/dịch sách hay khoá học trả phí; diễn đạt lại bằng lời của mình, trích dẫn ngắn.
3. **Viết theo khung** [assets/chapter-template.md](assets/chapter-template.md). Quy tắc viết:
   [references/style.md](references/style.md) (câu ngắn, thuật ngữ, bảng lỗi, bài tập).
4. **Code**: mỗi ví dụ là một file đầy đủ trong `examples/chNN/` cạnh chương, chạy bằng script
   chung của sách. Output dán vào chương là **output thật** — dùng runner của sách hoặc skill
   `code-sample-runner`. Không chạy được → ghi "NOT RUN" + Blocker.
5. **GLOSSARY.md**: thêm mỗi thuật ngữ mới (English — tiếng Việt — 1 câu giải thích — chương).
6. **Kiểm tra cấu trúc**:
   ```bash
   python3 ${CLAUDE_SKILL_DIR}/scripts/check_chapter.py chapters/chNN-*.md
   ```
   Sửa đến khi `OK`. Sau đó chạy link checker của sách cho mục "Nguồn tham khảo".

## Expected output

- `chapters/chNN-<slug>.md` theo đúng 8 mục; `examples/chNN/*` chạy được; `GLOSSARY.md` cập nhật.
- Báo cáo ngắn: mục tiêu đã phủ, lệnh đã chạy + output thật của `check_chapter.py` và runner,
  mục UNVERIFIED.

## Quality checklist

- [ ] `check_chapter.py` → `OK`.
- [ ] Mỗi thuật ngữ tiếng Anh được giải thích tiếng Việt ở lần đầu, ví dụ "luồng dữ liệu (stream)".
- [ ] Ví dụ đầu tiên đơn giản, chạy được; phần "Đi sâu" mới có trường hợp biên.
- [ ] Bảng "Lỗi và bẫy thường gặp" có ít nhất 3 dòng, mỗi dòng có cách sửa.
- [ ] Mỗi bài tập có lời giải; lời giải có code thì code đã chạy.
- [ ] "Nguồn tham khảo" chỉ gồm link đã thực sự mở; fact dễ thay đổi có "(kiểm tra YYYY-MM-DD)".
