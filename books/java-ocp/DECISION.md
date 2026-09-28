# DECISION — Chọn kỳ thi nào? 1Z0-830 (Java SE 21) hay 1Z0-829 (Java SE 17)

> Ngày kiểm tra: 2026-09-28.
>
> **Cảnh báo trung thực:** các trang chính thức của Oracle (`education.oracle.com`,
> `docs.oracle.com`, `mylearn.oracle.com`) và `dev.java` **bị chặn** trong sandbox nơi mình làm việc
> (lỗi 403 / `connect_rejected`). Vì vậy mọi con số về kỳ thi dưới đây lấy từ
> **đoạn trích kết quả tìm kiếm (WebSearch snippet)** có trỏ tới trang Oracle, và từ các nguồn phụ
> mình mở được. Tất cả đều được đánh dấu **UNVERIFIED** cho tới khi Nobin (hoặc một phiên có mạng)
> mở trang Oracle và xác nhận. Việc này nằm trong mục Blockers của PROGRESS.md.

## 1. Kết luận ngắn

**Chọn 1Z0-830 — Java SE 21 Developer Professional.** Cả cuốn sách, ví dụ và câu hỏi đều dùng **JDK 21**
(máy kiểm tra: OpenJDK 21.0.10, biên dịch với `--release 21`).

## 2. Bảng so sánh

| Tiêu chí | 1Z0-830 — Java SE 21 | 1Z0-829 — Java SE 17 | Nguồn / trạng thái |
|---|---|---|---|
| Tên kỳ thi | Java SE 21 Developer Professional | Java SE 17 Developer | Tiêu đề trang Oracle trong kết quả tìm kiếm [O1], [O2] — **UNVERIFIED** |
| Số câu hỏi | 50 | 50 | [S1], [S2], [G1] — **UNVERIFIED** |
| Thời gian | 120 phút (~2,4 phút/câu) | 90 phút (~1,8 phút/câu) | [S1], [S2], [G1] — **UNVERIFIED** |
| Điểm đậu | 68% (≈ 34/50 câu) | 68% | [S1], [S2], [G1] — **UNVERIFIED** |
| Giá | 245 USD (thay đổi theo quốc gia) | 245 USD (thay đổi theo quốc gia) | [S1], [S3] — **UNVERIFIED**; giá ở Việt Nam có thể khác |
| Hình thức | Trắc nghiệm chọn 1 và chọn nhiều (multiple choice / multiple select), nhiều câu có code | Như bên trái | [S2], [S3] — **UNVERIFIED** |
| Nơi thi | Online qua Oracle University (có giám sát) | Online giám sát hoặc tại trung tâm | [G1], [S3] — **UNVERIFIED** |
| Tình trạng | Đang mở. Đã có bản mới hơn 1Z0-831 (Java SE 25) từ khoảng 2026-05 | Theo snippet: **retire ngày 2027-02-28** | [S4], [S5], [G2] — **UNVERIFIED** |
| Nhóm mục tiêu thi | 10 nhóm (xem mục 3) — **không còn JDBC** | 11 nhóm, **có** "Accessing databases using JDBC" | [G1], [S2] — **UNVERIFIED** |
| Tính năng Java mới trong đề | record, sealed, pattern matching cho `instanceof` và `switch`, text block, **virtual threads**, sequenced collections (Java 21) | record, sealed, text block, switch expression (Java 17); không có virtual threads | [G1] |

## 3. Mục tiêu thi 1Z0-830 (10 nhóm)

Danh sách này lấy từ bảng mục tiêu trong `intro.md` của repo `eh3rrera/ocpj21-book` [G1]
(tác giả ghi là mục tiêu chính thức của Oracle) và khớp với snippet tìm kiếm của trang Oracle [S6].
**UNVERIFIED** so với trang Oracle gốc. Bản đầy đủ từng mục con nằm trong COVERAGE.md.

1. Handling Date, Time, Text, Numeric and Boolean Values
2. Controlling Program Flow
3. Using Object-Oriented Concepts in Java
4. Handling Exceptions
5. Working with Arrays and Collections
6. Working with Streams and Lambda expressions
7. Packaging and Deploying Java Code
8. Managing Concurrent Code Execution
9. Using Java I/O API
10. Implementing Localization

## 4. Lý do chọn 1Z0-830

1. **Nhiều thời gian hơn mỗi câu.** 120 phút cho 50 câu (1Z0-829 chỉ 90 phút). Đề OCP nổi tiếng là
   code dài và bẫy nhiều; thêm 30 phút giúp người đi làm full-time đọc kỹ hơn.
2. **Ít chủ đề "cũ" hơn.** 1Z0-830 bỏ nhóm JDBC. Thời gian ôn dồn vào ngôn ngữ và API lõi.
3. **Kiến thức dùng được ngay khi làm backend.** Java 21 là bản LTS; virtual threads, record,
   sealed type, pattern matching cho `switch` là những thứ Nobin sẽ gặp trong Spring Boot 3 hiện đại.
4. **1Z0-829 sắp retire** (snippet nói 2027-02-28, **UNVERIFIED**). Nếu học 6–8 tuần rồi thi, vẫn kịp,
   nhưng không có lợi thế gì so với 1Z0-830.
5. **Kiểm chứng được 100% code trong môi trường này.** Sandbox có sẵn OpenJDK 21.0.10, nên mọi ví dụ
   và câu hỏi đều được biên dịch và chạy thật bằng đúng phiên bản của kỳ thi.
6. **Tài liệu ôn nhiều và đã "chín".** Sách Sybex cho 1Z0-830, sách mở `ocpj21-book` (CC BY-NC-SA),
   Enthuware, các khóa Pearson/Pluralsight đều đã có (xem SOURCES.md).

## 5. Còn 1Z0-831 (Java SE 25) thì sao?

Task chỉ yêu cầu so sánh 21 và 17, nên mình giữ đúng phạm vi. Nhưng khi tìm kiếm, mình thấy
Oracle đã ra **1Z0-831 — Java SE 25 Developer Professional** (khoảng tháng 5/2026; 50 câu, 120 phút,
68% — theo snippet [S4] và issue GitHub của dev.java [G2]; **UNVERIFIED**).

Mình vẫn chọn 1Z0-830 vì: JDK 25 không có trong sandbox nên không kiểm chứng được code;
tài liệu ôn cho Java 25 còn rất ít; và ~90% kiến thức Java 21 vẫn đúng cho Java 25.
Đây là **câu hỏi cho Nobin** (xem PR): nếu muốn thi Java 25, phần lớn sách vẫn dùng được, chỉ cần
thêm một chương "Java 22–25" (flexible constructor bodies, unnamed variables `_`, module import,
scoped values, stream gatherers, compact source files…).

## 6. Hệ quả cho phần còn lại của task

- Mọi chương dùng tên nhóm mục tiêu của 1Z0-830.
- Mọi ví dụ và câu hỏi: biên dịch bằng `javac --release 21`, chạy bằng `java` 21.0.10.
- Không dùng tính năng preview của Java 21 (ví dụ: unnamed variables `_`, string templates),
  vì đề thi chỉ dùng tính năng chính thức.
- Đề thi thử: 50 câu, 120 phút, đậu khi đúng ≥ 34 câu (68%).

## Nguồn tham khảo (Sources)

Trang Oracle (bị chặn trong sandbox — chỉ thấy qua kết quả tìm kiếm, **chưa mở được**):

- [O1] https://education.oracle.com/java-se-21-developer-professional/pexam_1Z0-830
- [O2] https://education.oracle.com/java-se-17-developer/pexam_1Z0-829
- [O3] https://education.oracle.com/java-se-25-developer-professional/pexam_1Z0-831

Đoạn trích tìm kiếm (WebSearch, 2026-09-28) — nguồn phụ:

- [S1] Snippet cho truy vấn "1Z0-830 … number of questions duration passing score price": 50 câu, 120 phút, 68%, 245 USD (kết quả gồm trang Oracle [O1] và các trang luyện thi).
- [S2] Snippet cho truy vấn "1Z0-829 … 90 minutes 68%": 50 câu, 90 phút, 68%, có nhóm JDBC.
- [S3] Snippet cho truy vấn "1Z0-829 exam price $245 format": 245 USD (tuỳ khu vực), online hoặc Pearson VUE.
- [S4] Snippet cho truy vấn "1Z0-831 … release date": Java 25 exam ra ngày 2026-05-01, 50 câu, 120 phút, 68%.
- [S5] Snippet cho truy vấn "1Z0-829 retired … 2027": "will retire on February 28, 2027".
- [S6] Snippet cho truy vấn các nhóm mục tiêu 1Z0-830 (Handling Date, Time, Text… / Implementing Localization).

Nguồn đã mở được:

- [G1] eh3rrera/ocpj21-book, `intro.md` — https://github.com/eh3rrera/ocpj21-book/blob/main/intro.md (mở 2026-09-28; license CC BY-NC-SA 4.0; chỉ tham khảo thông tin, không sao chép nội dung)
- [G2] java/devjava-content issue #242 — https://github.com/java/devjava-content/issues/242 (mở 2026-09-28)
