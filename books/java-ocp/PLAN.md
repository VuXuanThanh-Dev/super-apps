# PLAN — Sổ tay ôn thi Java OCP (tiếng Việt)

> Task 2 của Nobin. Thư mục: `books/java-ocp/`. Nhánh: `task-2-java-ocp`.
> Ngày lập kế hoạch: 2026-09-28.

## Mục tiêu (Goal)

Viết một cuốn sổ tay ôn thi **Oracle Java OCP** bằng tiếng Việt, kèm bộ câu hỏi luyện tập
**tự viết (original)**. Mục tiêu của Nobin: điểm cao **và** hiểu Java thật sự.
Người đọc: dev TypeScript/Angular, biết Java cơ bản, đi làm full-time.

## Mục lục dự kiến (Table of contents)

| # | Chương | Nhóm mục tiêu thi (objective group) |
|---|--------|--------------------------------------|
| 0 | Giới thiệu, cách dùng sách | — |
| 1 | Dữ liệu: số, boolean, chuỗi, ngày giờ | Handling Date, Time, Text, Numeric and Boolean Values |
| 2 | Luồng điều khiển | Controlling Program Flow |
| 3 | Hướng đối tượng | Using Object-Oriented Concepts in Java |
| 4 | Ngoại lệ | Handling Exceptions |
| 5 | Mảng và Collections | Working with Arrays and Collections |
| 6 | Lambda và Stream | Working with Streams and Lambda expressions |
| 7 | Module, đóng gói, triển khai | Packaging and Deploying Java Code |
| 8 | Đồng thời (concurrency) | Managing Concurrent Code Execution |
| 9 | I/O và NIO.2 | Using Java I/O API |
| 10 | Bản địa hoá (localization) | Implementing Localization |
| — | 3 đề thi thử, cheat sheet từng chương, lịch học 6–8 tuần, GLOSSARY | — |

(Tên nhóm mục tiêu sẽ được xác nhận ở M1/M2; xem DECISION.md và COVERAGE.md.)

## Cấu trúc thư mục

```
books/java-ocp/
  PLAN.md  PROGRESS.md  DECISION.md  COVERAGE.md  SOURCES.md  GLOSSARY.md  README.md
  chapters/          # Markdown = nguồn sự thật (source of truth)
  examples/chNN/     # ví dụ chạy được cho từng chương
  examples/questions/chNN/questions.yaml   # câu hỏi + đáp án + cách kiểm tra
  examples/questions/chNN/QNN_MM/...        # code Java sinh ra từ YAML, được script biên dịch + chạy
  mock/              # 3 đề thi thử + file đáp án riêng
  cheatsheets/       # 1 trang / chương
  schedule/          # lịch học
  tools/             # script: chạy ví dụ, kiểm tra câu hỏi, build PDF, kiểm tra link
  dist/              # PDF
```

## Milestones

- **M1 — Chọn kỳ thi.** So sánh 1Z0-830 (Java SE 21) và 1Z0-829 (Java SE 17): mục tiêu thi,
  số câu, thời gian, điểm đậu, giá, hình thức, tình trạng retire. Viết DECISION.md.
- **M2 — Nguồn và độ phủ.** SOURCES.md (JLS, API docs, OpenJDK, repo GitHub, sách/khóa học — chỉ link).
  COVERAGE.md: objective → chương → ví dụ → ID câu hỏi. Công cụ: script chạy ví dụ và script kiểm tra câu hỏi.
- **M3 — 10 chương.** Mỗi chương: Mục tiêu → Giải thích đơn giản → Ví dụ → Đi sâu →
  Bẫy thường gặp (Exam traps) → Góc nhìn từ TypeScript → Tóm tắt → Bài tập (có lời giải) → Nguồn tham khảo.
  10+ ví dụ có output thật; 20 câu hỏi original (chọn 1 / chọn 2–3, dễ/vừa/khó), mỗi câu có đáp án,
  lý do đúng, lý do từng phương án sai. Script biên dịch + chạy để xác nhận đáp án. Commit sau mỗi chương.
- **M4 — Thi thử và ôn tập.** 3 đề thi thử đúng kích thước/thời gian/tỷ trọng; đáp án ở file riêng;
  cheat sheet 1 trang/chương; lịch 6–8 tuần (~1h ngày thường, ~3h cuối tuần) có ngày ôn và ngày thi thử.
- **M5 — PDF.** 3 PDF: handbook, mock exams, cheat sheets. Pipeline: pandoc → HTML (font Noto) →
  Playwright Chromium → PDF. Kiểm tra dấu tiếng Việt bằng pdftotext. Phần giới thiệu nói rõ:
  không tài liệu nào đảm bảo điểm tuyệt đối.

## Definition of Done (copy từ task)

- [ ] DECISION.md with cited Oracle facts
- [ ] COVERAGE.md maps 100% of objectives, no empty rows
- [ ] Every chapter: 10+ examples with real output, 20 original questions
- [ ] Every question's answer confirmed by the check script
- [ ] 3 mock exams, cheat sheets, study schedule
- [ ] 3 PDFs with correct Vietnamese accents

## Nguyên tắc làm việc

- Làm xong trọn một milestone rồi mới sang milestone sau. Sau mỗi milestone: commit, push, cập nhật PROGRESS.md.
- Không bịa link / version / output. Không kiểm chứng được → **UNVERIFIED**.
- Không copy sách, không dùng exam dump. Mọi câu hỏi đều tự viết.
