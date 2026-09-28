---
name: ocp-question-writer
description: Write ORIGINAL Java OCP (1Z0-830, Java SE 21) practice questions in Vietnamese in the questions.yaml format, and prove every answer by compiling and running the code with JDK 21 (javac --release 21). Use when asked to create, fix or review OCP/Java certification practice questions, quizzes, mock exams or "câu hỏi trắc nghiệm Java". Not for explaining Java theory or writing chapter text (use handbook-chapter-writer), not for Spring/backend code (java-spring-backend agent), and never for copying or recreating real exam questions or dumps.
compatibility: Needs JDK 21+ (javac, java), Python 3.10+ with PyYAML.
---

# OCP question writer

Mỗi câu hỏi là **một chương trình Java thật**. Đáp án chỉ được chấp nhận khi máy đã biên dịch
và chạy, và kết quả khớp đáp án. Không bao giờ "đoán" output.

## Steps

1. **Chọn mục tiêu thi (objective)**. Trong sách OCP của repo (`books/java-ocp/`) dùng
   `COVERAGE.md` / `tools/objectives.yaml`. Danh sách mục tiêu chính thức của Oracle không mở được
   từ sandbox → ghi **UNVERIFIED** nếu nêu số câu, thời gian, điểm đậu.
2. **Viết câu hỏi gốc** theo schema trong [references/format.md](references/format.md):
   một "bẫy" rõ ràng (autoboxing cache, numeric promotion, pattern matching, sealed, record,
   virtual threads, sequenced collections, …), code ngắn (≤ 25 dòng), ≥ 4 lựa chọn,
   mỗi lựa chọn sai có lời giải thích riêng trong `wrong`.
   Chọn `kind`: `output` (in ra gì / exception), `compile_error` (dòng nào lỗi, đánh dấu `// L1`),
   `variants` (chèn đoạn nào thì compile/chạy được).
3. **Xác minh** — bắt buộc, không bỏ qua:
   - Trong sách OCP: `python3 tools/book.py questions <set>` (script của sách).
   - Ở nơi khác: `python3 ${CLAUDE_SKILL_DIR}/scripts/verify_questions.py <file>.yaml`.
   Nếu một câu FAIL: sửa **câu hỏi hoặc đáp án** theo kết quả thật, chạy lại tới khi PASS.
4. **Cân bằng đáp án**: vị trí đáp án đúng rải đều A/B/C/D; không có lựa chọn trùng nghĩa.
5. **Viết lời giải** (`why`) bằng tiếng Việt, thuật ngữ giữ tiếng Anh, theo thứ tự:
   ý chính → áp vào code → quy tắc tổng quát.

## Expected output

- File `questions.yaml` (hoặc thêm vào file của chương) theo schema.
- Dán **output thật** của script, ví dụ:
  ```
  PASS S-01: output 'small circle, square 3' confirmed
  PASS S-02: compile error on lines [7] confirmed

  2/2 questions verified with javac 21.0.10 --release 21
  ```
- Nếu không có JDK: ghi "NOT RUN" + Blocker, không đưa câu hỏi chưa xác minh vào sách.

## Quality checklist

- [ ] 100% câu PASS với JDK 21; phiên bản javac được ghi trong báo cáo.
- [ ] Câu hỏi do mình viết; không chép/dịch sách, khoá học, đề thi thật hay "dump".
- [ ] Mỗi câu 1 bẫy chính; code không phụ thuộc giờ máy, locale, thứ tự HashMap, hay số luồng.
- [ ] `wrong` giải thích từng lựa chọn sai; `why` ≤ 5 câu.
- [ ] Mức độ easy/medium/hard hợp lý; đáp án rải đều.

Ví dụ đầy đủ đã xác minh: [assets/sample-questions.yaml](assets/sample-questions.yaml).
