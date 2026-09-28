# Lịch học 8 tuần (có phương án rút gọn 6 tuần)

Dành cho người đi làm full-time: **~1 giờ mỗi ngày thường (thứ 2–6), ~3 giờ mỗi ngày cuối tuần (thứ 7, CN)**
→ khoảng 11 giờ/tuần, **~88 giờ** cho cả 8 tuần.

## Nguyên tắc

1. **Đọc → chạy → đoán → kiểm tra.** Với mỗi ví dụ: đọc code, **tự đoán output trước**, rồi mới xem output thật.
   Chạy lại bằng `python3 tools/book.py examples chNN` hoặc tự gõ lại bằng tay với `javac`/`java` (không IDE — như lúc thi).
2. **Sổ lỗi (error log).** Mỗi câu sai hoặc đoán mò: ghi 1 dòng "bẫy gì, quy tắc đúng là gì". Ôn sổ lỗi mỗi Chủ nhật.
3. **Ôn giãn cách.** Mỗi Chủ nhật ôn cheat sheet của các chương đã học.
4. **Thi thử có bấm giờ** (120 phút, không tra cứu). Mục tiêu: **≥ 80%** ở cả 3 đề (dư ra so với ngưỡng đậu 68%) rồi mới đăng ký thi.

## 8 tuần

| Tuần | Thứ 2 – thứ 6 (1 giờ/ngày) | Thứ 7 (3 giờ) | Chủ nhật (3 giờ) |
|---|---|---|---|
| **1** | T2: đọc Giới thiệu, DECISION.md, cài JDK 21, thử `javac`/`java`. T3–T6: Chương 1 (primitive, wrapper, toán tử, Math, String/StringBuilder) | Chương 1: text block, `java.time`, DST; chạy 13 ví dụ | Làm 20 câu Chương 1; đọc lời giải; bắt đầu sổ lỗi; cheat sheet 1 |
| **2** | T2–T4: Chương 2 (switch, pattern matching, vòng lặp). T5–T6: Chương 3 phần 3.1–3.2 (object, nested class, khởi tạo, record) | Chương 3 phần 3.3–3.5 (overloading, scope/var, kế thừa, sealed, cast) | 20 câu Chương 2; ôn cheat sheet 1–2; sổ lỗi |
| **3** | T2–T3: Chương 3 phần 3.6–3.7 (interface, enum). T4: 20 câu Chương 3. T5–T6: Chương 4 (exception) | 20 câu Chương 4; tự viết 3 ví dụ try-with-resources + suppressed | **Ôn tổng hợp 1:** làm lại mọi câu sai Chương 1–4; cheat sheet 3–4 |
| **4** | T2–T5: Chương 5 (mảng, List/Set/Map/Deque, Comparator, generics). T6: 20 câu Chương 5 | Chương 6 phần 1: lambda, functional interface, method reference, stream cơ bản, Optional | Chương 6 phần 2: reduce, collectors (groupingBy, partitioningBy, toMap), parallel |
| **5** | T2: 20 câu Chương 6. T3–T6: Chương 7 (module) — **gõ lại các lệnh** `javac --module-source-path`, `jar`, `jlink` | 20 câu Chương 7; tự dựng 1 project 3 module có service | **Ôn tổng hợp 2:** câu sai Chương 4–7; cheat sheet 5–7 |
| **6** | T2–T4: Chương 8 (thread, virtual thread, executor, lock, concurrent collections). T5: 20 câu Chương 8. T6: Chương 9 phần I/O stream | Chương 9: serialization, `Path`, `Files`; 20 câu Chương 9 | **Đề thi thử số 1** (120 phút) + 1 giờ chữa bài; ghi chủ đề yếu |
| **7** | T2–T3: Chương 10 (localization). T4: 20 câu Chương 10. T5–T6: học lại 2 chủ đề yếu nhất từ đề 1 | **Đề thi thử số 2** + chữa bài | Ôn sâu sổ lỗi; tự viết lại cheat sheet bằng tay cho 3 chương yếu nhất |
| **8** | T2–T4: làm lại **tất cả** câu từng sai (chương + đề 1, 2). T5: đọc cheat sheet 1–5. T6: cheat sheet 6–10 | **Đề thi thử số 3** + chữa bài | Ôn nhẹ; nếu cả 3 đề ≥ 80% → đăng ký thi. Nếu chưa, lặp lại tuần 8 cho chủ đề yếu |

## Phương án rút gọn 6 tuần (khi đã vững Java cơ bản)

| Tuần | Nội dung |
|---|---|
| 1 | Chương 1 + 2 (+ 40 câu) |
| 2 | Chương 3 + 4 (+ 40 câu) |
| 3 | Chương 5 + 6 (+ 40 câu) |
| 4 | Chương 7 + 8 (+ 40 câu); Chủ nhật: **Đề 1** |
| 5 | Chương 9 + 10 (+ 40 câu); Chủ nhật: **Đề 2** |
| 6 | Làm lại câu sai + cheat sheet; thứ 7: **Đề 3**; Chủ nhật: ôn nhẹ |

## Theo dõi tiến độ (tự điền)

| Mục | Ngày làm | Điểm | Ghi chú chủ đề yếu |
|---|---|---|---|
| Câu hỏi Chương 1 | | /20 | |
| Câu hỏi Chương 2 | | /20 | |
| Câu hỏi Chương 3 | | /20 | |
| Câu hỏi Chương 4 | | /20 | |
| Câu hỏi Chương 5 | | /20 | |
| Câu hỏi Chương 6 | | /20 | |
| Câu hỏi Chương 7 | | /20 | |
| Câu hỏi Chương 8 | | /20 | |
| Câu hỏi Chương 9 | | /20 | |
| Câu hỏi Chương 10 | | /20 | |
| Đề thi thử 1 | | /50 | |
| Đề thi thử 2 | | /50 | |
| Đề thi thử 3 | | /50 | |

## Mẹo làm bài thi

- 120 phút / 50 câu ≈ **2,4 phút/câu**. Câu nào quá 4 phút → đánh dấu (mark for review), làm câu khác.
- Đọc **câu hỏi trước**, code sau: "chọn 2" hay "chọn 3"? Hỏi output, lỗi biên dịch, hay exception?
- Luôn kiểm tra trước: code có **biên dịch được** không? (import thiếu, kiểu không khớp, biến ngoài phạm vi, checked exception.)
- Với câu "dòng nào lỗi": xét **từng dòng độc lập**.
- Không để trống câu nào (không bị trừ điểm khi sai — theo thông lệ các kỳ thi Oracle; **UNVERIFIED** với 1Z0-830).
