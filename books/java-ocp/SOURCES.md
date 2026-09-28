# SOURCES — Nguồn học và nguồn kiểm chứng

> Ngày kiểm tra: 2026-09-28. Mình chỉ ghi "đã mở" với link mình thật sự mở được từ sandbox.
> Nhiều trang chính thức bị chặn trong sandbox — xem mục 5.

## 1. Nguồn chính thức (ưu tiên cao nhất)

| Nguồn | Link | Trạng thái |
|---|---|---|
| Trang kỳ thi 1Z0-830 (Oracle University) | https://education.oracle.com/java-se-21-developer-professional/pexam_1Z0-830 | Bị chặn trong sandbox — chưa mở |
| Java Language Specification, Java SE 21 (JLS) | https://docs.oracle.com/javase/specs/jls/se21/html/index.html | Bị chặn trong sandbox — chưa mở |
| Java SE 21 API docs (Javadoc) | https://docs.oracle.com/en/java/javase/21/docs/api/index.html | Bị chặn trong sandbox — chưa mở |
| Mã nguồn OpenJDK 21 (bản cập nhật) | https://github.com/openjdk/jdk21u | **Đã mở** (GPL-2.0). Javadoc nằm ngay trong mã nguồn |
| Javadoc trong `src.zip` của JDK đã cài | `/usr/lib/jvm/java-21-openjdk-amd64/lib/src.zip` | **Đã dùng** để đọc Javadoc gốc offline |

Cách mình kiểm chứng API khi Javadoc online bị chặn: đọc Javadoc trong mã nguồn JDK 21
(`src.zip` hoặc `raw.githubusercontent.com/openjdk/jdk21u/...`) **và** chạy code thật với JDK 21.0.10.

## 2. So sánh repo GitHub dùng để ôn 1Z0-830

Tiêu chí "repo uy tín" (theo RULES): commit trong 12 tháng, license rõ ràng, có người dùng thật, còn bảo trì.

| URL | Stars | Last push | License | Có gì hữu ích | Đánh giá | Ngày kiểm tra |
|---|---|---|---|---|---|---|
| https://github.com/eh3rrera/ocpj21-book | 144 | 2026-09-03 | CC BY-NC-SA 4.0 (ghi trong README; GitHub hiện "Other") | Sách ôn 1Z0-830 đầy đủ 14 chương, bảng objective → chương | **Tốt nhất** để đọc thêm. License NC-SA: chỉ đọc tham khảo, không copy vào sách này | 2026-09-28 |
| https://github.com/ThiagoBfim/java-21-certification | 42 | 2026-08-26 | MIT | Ghi chú (Guide.md) + code ví dụ Java 21 | Tốt, license rõ, còn cập nhật | 2026-09-28 |
| https://github.com/Anasss/java21docCards | 10 | 2026-06-19 | MIT | Flashcard + quiz Java 21 | Dùng để ôn nhanh; ít người dùng | 2026-09-28 |
| https://github.com/jose-de-souza/1Z0-830 | 29 | 2026-08-28 | Không có license | Code khóa học | Không đạt (không có license) | 2026-09-28 |
| https://github.com/boyarsky/sybex-1Z0-830-chapter-12 | 18 | 2024-07-30 | Không có license | Code chương 12 sách Sybex | Không đạt (cũ hơn 12 tháng, không license) | 2026-09-28 |

Số liệu stars / last push / license lấy qua GitHub search API ngày 2026-09-28; nội dung repo mở bằng trình đọc web.
Không repo nào được sao chép vào sách này.

## 3. Sách và khóa học nổi tiếng (chỉ giới thiệu link — có phí)

Các trang này **bị chặn trong sandbox**, mình chỉ thấy chúng trong kết quả tìm kiếm (2026-09-28), **chưa mở được**:

- Jeanne Boyarsky & Scott Selikoff — *OCP Oracle Certified Professional Java SE 21 Developer Study Guide: Exam 1Z0-830* (Sybex/Wiley):
  https://www.wiley.com/en-us/OCP+Oracle+Certified+Professional+Java+SE+21+Developer+Study+Guide-p-9781394286621
  — trang của tác giả (errata): https://www.selikoff.net/ocp21/
- Enthuware — bộ đề luyện 1Z0-830 (có phí): https://enthuware.com/java-certification-mock-exams/oracle-certified-professional/ocp-java-21-exam-1z0-830
- Esteban Herrera — bản web miễn phí của sách ocpj21: https://ocpj21.javastudyguide.com/
- Pearson — *Java SE 21 Developer (1Z0-830)* video: https://www.oreilly.com/videos/java-se-21/9780135461846/
- Pluralsight — loạt khóa "Java SE 21 Developer (Exam 1Z0-830)": https://www.pluralsight.com/courses/java-se-21-developer-1z0-830-concurrent-programming
- Diễn đàn Coderanch OCPJP (hỏi đáp về kỳ thi): https://coderanch.com/f/24/java-programmer-OCPJP

## 4. Chính sách bản quyền của sách này

- Mọi giải thích, ví dụ và câu hỏi đều **tự viết**. Không dùng exam dump, không dịch sách có bản quyền.
- Danh sách mục tiêu thi (tên objective) là thông tin mô tả kỳ thi, trích ngắn để đối chiếu.

## 5. Host bị chặn trong sandbox (không phải link hỏng)

`education.oracle.com`, `docs.oracle.com`, `mylearn.oracle.com`, `dev.java`, `openjdk.org`, `enthuware.com`,
`www.selikoff.net`, `www.wiley.com`, `ocpj21.javastudyguide.com`, `www.oreilly.com`, `www.pluralsight.com`, `coderanch.com`.
Kết quả link checker: `tools/check_links.py` (xem PROGRESS.md).
