# Đề thi thử (mock exams)

| Đề | File đề | File đáp án |
|---|---|---|
| Số 1 | [mock-exam-1.md](mock-exam-1.md) | [mock-exam-1-answers.md](mock-exam-1-answers.md) |
| Số 2 | [mock-exam-2.md](mock-exam-2.md) | [mock-exam-2-answers.md](mock-exam-2-answers.md) |
| Số 3 | [mock-exam-3.md](mock-exam-3.md) | [mock-exam-3-answers.md](mock-exam-3-answers.md) |

## Mô phỏng kỳ thi thật

- **50 câu, 120 phút, đậu khi đúng ≥ 34 câu (68%)** — theo thông tin kỳ thi 1Z0-830 trong DECISION.md
  (**UNVERIFIED**: trang Oracle bị chặn trong sandbox, số liệu lấy từ kết quả tìm kiếm ngày 2026-09-28).
- Dạng câu: chọn 1 đáp án và "chọn 2/3 đáp án"; phần lớn có đoạn code; có câu "đoạn code nào cho ra output này".
- Trong file đề **không** ghi objective và độ khó của từng câu (giống thi thật). File đáp án có ghi.

## Tỷ trọng chủ đề (blueprint)

Oracle **không công bố** tỷ trọng từng nhóm mục tiêu cho 1Z0-830 (mình không tìm thấy nguồn chính thức; **UNVERIFIED**).
Mình phân bổ theo số lượng objective con và độ "nặng" của từng nhóm:

| Nhóm mục tiêu | Mục tiêu (số câu / đề) |
|---|---|
| 1. Date, Time, Text, Numeric, Boolean | 6–7 |
| 2. Program Flow | 4–5 |
| 3. Object-Oriented Concepts | 12–13 |
| 4. Exceptions | 3–4 |
| 5. Arrays and Collections | 4–5 |
| 6. Streams and Lambdas | 6–7 |
| 7. Packaging and Deploying (modules) | 3 |
| 8. Concurrency | 4 |
| 9. I/O | 3 |
| 10. Localization | 2–3 |

Bảng "Phân bố theo nhóm mục tiêu" ở cuối mỗi file đáp án là số đếm thật (theo objective đầu tiên của mỗi câu).

## Cách dùng

1. Làm đề trong 120 phút, ghi đáp án ra giấy.
2. Chấm bằng "Bảng đáp án nhanh" ở đầu file đáp án.
3. Đọc lời giải của **mọi** câu sai và cả câu đúng nhưng đoán. Ghi lỗi vào sổ tay (xem `schedule/`).
4. Tự chạy lại code trong `examples/questions/mockN/` nếu còn nghi ngờ.

Kiểm tra lại toàn bộ đáp án: `python3 tools/book.py questions mock1 mock2 mock3`.
