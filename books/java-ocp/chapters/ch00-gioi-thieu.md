# Giới thiệu — Cách dùng cuốn sổ tay này

## Cuốn sách này dành cho ai?

Cho **Nobin** và những người giống Nobin: dev frontend (TypeScript/Angular) đã biết Java cơ bản, đi làm full-time,
muốn thi **Oracle Certified Professional: Java SE 21 Developer — kỳ thi 1Z0-830** với hai mục tiêu:
**điểm cao** và **hiểu Java thật sự** để làm backend.

Lý do chọn 1Z0-830 (thay vì 1Z0-829 / Java 17) nằm trong [DECISION.md](../DECISION.md).

## Nói thật trước khi bắt đầu

- **Không tài liệu nào — kể cả cuốn này — bảo đảm bạn đạt điểm tuyệt đối, hay thậm chí bảo đảm bạn đậu.**
  Đề thi thật có câu hỏi mình không thể biết trước, Oracle có thể thay đổi đề, và kết quả phụ thuộc vào việc bạn
  luyện tập, ngủ đủ, và cả may mắn hôm thi.
- Mọi câu hỏi trong sách đều **tự viết** theo phong cách đề thi (không phải đề thật, không phải "dump"). Mục đích là
  luyện **cách suy nghĩ**, không phải học thuộc đáp án.
- Một số thông tin về kỳ thi (số câu, thời gian, điểm đậu, giá) được lấy từ kết quả tìm kiếm vì trang Oracle bị chặn
  trong môi trường viết sách; chúng được đánh dấu **UNVERIFIED**. Hãy kiểm tra lại trên trang Oracle trước khi đăng ký thi.

## Thông tin kỳ thi (tóm tắt — xem DECISION.md)

| | 1Z0-830 |
|---|---|
| Số câu | 50 (**UNVERIFIED**) |
| Thời gian | 120 phút (**UNVERIFIED**) |
| Điểm đậu | 68% ≈ 34 câu (**UNVERIFIED**) |
| Dạng câu | Chọn 1 / chọn nhiều, phần lớn có code |
| Nhóm mục tiêu | 10 nhóm, 26 mục tiêu con (theo cách chia của sách này) — xem [COVERAGE.md](../COVERAGE.md) |

## Cấu trúc mỗi chương

Mỗi chương ứng với **một nhóm mục tiêu** của đề thi và đi theo thứ tự "ý đơn giản → ví dụ thật → chi tiết":

1. **Mục tiêu** — học xong làm được gì.
2. **Giải thích đơn giản** — ý chính bằng lời thường.
3. **Ví dụ** — 10+ chương trình nhỏ, kèm **output thật** (chạy bằng OpenJDK 21.0.10).
4. **Đi sâu** — quy tắc chi tiết mà đề thi hay hỏi.
5. **Lỗi và bẫy thường gặp (Exam traps)**.
6. **Góc nhìn từ TypeScript** — so sánh với thứ bạn đã biết.
7. **Tóm tắt**.
8. **Bài tập (có lời giải)** — 20 câu tự viết; mỗi câu có đáp án, lý do đúng, và lý do **từng** phương án sai.
9. **Nguồn tham khảo (Sources)**.

## Mọi đáp án đều được máy kiểm chứng

Mỗi câu hỏi được lưu trong `examples/questions/<chương>/questions.yaml`. Script `tools/book.py` sinh file Java, **biên dịch
và chạy thật** rồi so sánh với đáp án:

- Câu "in ra gì": output thật phải khớp đúng phương án đúng.
- Câu "dòng nào lỗi biên dịch": kiểm tra **từng dòng riêng lẻ** (sửa các dòng khác thì dòng đó vẫn lỗi; sửa tất cả thì biên dịch được).
- Câu "chèn đoạn nào…": biên dịch/chạy **từng phương án**.
- Câu "phát biểu nào đúng": **mỗi** phát biểu có một chương trình chứng minh đúng/sai.
- Câu về module/bundle: script tạo đúng cấu trúc thư mục rồi chạy `javac`, `java`, `jar`, `jlink` thật.

Chạy lại tất cả: `bash tools/run_all.sh` (xem [README.md](../README.md)).

## Học thế nào cho hiệu quả?

- Theo [lịch 8 tuần](../schedule/schedule.md): ~1 giờ ngày thường, ~3 giờ cuối tuần.
- Luôn **đoán output trước** khi nhìn đáp án. Sai thì ghi vào sổ lỗi.
- Làm câu hỏi **không dùng IDE** (đề thi không có IDE, không có gợi ý lỗi).
- Cuối lộ trình: 3 đề thi thử 50 câu / 120 phút, và cheat sheet 1 trang cho mỗi chương.

## Kiến thức nền cần có

Biết viết class, method, `if`, vòng lặp, và chạy `javac Hello.java && java Hello`. Nếu chưa, hãy học phần nhập môn Java
trước (khoảng 1–2 tuần) rồi quay lại.

## Nguồn tham khảo (Sources)

- Thông tin kỳ thi và nguồn học: [DECISION.md](../DECISION.md), [SOURCES.md](../SOURCES.md) (kiểm tra 2026-09-28).
