# Style guide — chương sách tiếng Việt

## Câu và đoạn
- Câu ≤ 25 từ. Đoạn ≤ 5 câu. Một đoạn = một ý.
- Dùng "bạn" với người đọc. Tránh câu bị động dài.
- Mỗi mục bắt đầu bằng 1 câu nói mục đó để làm gì.

## Thuật ngữ
- Giữ tiếng Anh cho thuật ngữ kỹ thuật; lần đầu viết: `tiếng Việt (English)`, ví dụ
  "kiểu bản ghi (record)", "khớp mẫu (pattern matching)". Các lần sau có thể dùng tiếng Anh.
- Tên class, method, lệnh: để trong `backtick`.
- Mỗi thuật ngữ mới → một dòng trong GLOSSARY.md:
  `| record | kiểu bản ghi | Lớp chỉ chứa dữ liệu, tự sinh equals/hashCode/toString | ch03 |`

## Ví dụ
- Ví dụ đầu tiên ≤ 20 dòng, có bối cảnh đời thật (đơn hàng, học viên, hoá đơn …).
- Mỗi ví dụ có: mục đích (1 câu) → code → output thật → giải thích 2–4 gạch đầu dòng.

## Lỗi và bẫy thường gặp
- Bảng 3 cột: Lỗi / bẫy — Vì sao sai — Cách đúng. Ưu tiên lỗi người mới hay gặp và bẫy trong đề thi.

## Bài tập
- 3–5 bài, từ dễ đến khó. Lời giải trong `<details><summary>Lời giải</summary> … </details>`
  (trên GitHub bấm để mở; khi build PDF bằng vietnamese-pdf-builder, mọi `<details>` được mở sẵn nên lời giải vẫn in ra).

## Sơ đồ
- Mermaid trong khối ```mermaid; giữ ≤ 10 nút; nhãn tiếng Việt ngắn.
  Khi build PDF, skill vietnamese-pdf-builder vẽ sơ đồ thành SVG.

## Nguồn
- Ưu tiên: docs chính thức / spec > repo GitHub uy tín > blog kỹ thuật nổi tiếng.
- Chỉ liệt kê link đã mở; ghi ngày mở. Site bị chặn → ghi rõ và đánh dấu **UNVERIFIED**.
