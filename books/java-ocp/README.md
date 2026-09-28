# Sổ tay ôn thi Java OCP 21 (1Z0-830) — tiếng Việt

Sách ôn thi **Oracle Certified Professional: Java SE 21 Developer (1Z0-830)** bằng tiếng Việt, kèm 200 câu hỏi theo
chương và 3 đề thi thử (150 câu) — **tất cả tự viết** và **được biên dịch, chạy thật để kiểm chứng đáp án**.

> Không tài liệu nào bảo đảm điểm tuyệt đối. Xem [Giới thiệu](chapters/ch00-gioi-thieu.md).

## Nội dung

| Phần | File |
|---|---|
| Giới thiệu | [chapters/ch00-gioi-thieu.md](chapters/ch00-gioi-thieu.md) |
| Chọn kỳ thi | [DECISION.md](DECISION.md) |
| 10 chương | [ch01](chapters/ch01-du-lieu.md) · [ch02](chapters/ch02-luong-dieu-khien.md) · [ch03](chapters/ch03-huong-doi-tuong.md) · [ch04](chapters/ch04-ngoai-le.md) · [ch05](chapters/ch05-mang-va-collections.md) · [ch06](chapters/ch06-lambda-va-stream.md) · [ch07](chapters/ch07-module-va-trien-khai.md) · [ch08](chapters/ch08-dong-thoi.md) · [ch09](chapters/ch09-io-va-nio2.md) · [ch10](chapters/ch10-ban-dia-hoa.md) |
| Độ phủ mục tiêu thi | [COVERAGE.md](COVERAGE.md) |
| Đề thi thử | [mock/](mock/README.md) |
| Cheat sheet (1 trang/chương) | [cheatsheets/](cheatsheets/) |
| Lịch học 6–8 tuần | [schedule/schedule.md](schedule/schedule.md) |
| Thuật ngữ | [GLOSSARY.md](GLOSSARY.md) |
| Nguồn | [SOURCES.md](SOURCES.md) |
| PDF | `dist/java-ocp-handbook.pdf`, `dist/java-ocp-mock-exams.pdf`, `dist/java-ocp-cheatsheets.pdf` |

## Phiên bản công cụ (đã dùng để kiểm chứng)

| Công cụ | Phiên bản |
|---|---|
| JDK | **OpenJDK 21.0.10** (`javac --release 21`, không dùng tính năng preview) |
| Python | 3.11, PyYAML 6.0.1 |
| pandoc | 3.1.3 (build PDF) |
| Node.js | v22.22.2, Playwright 1.56.1 + Chromium 1194 (build PDF) |
| Font | Noto Serif / Noto Sans / Noto Sans Mono (fonts-noto-core) |

Ví dụ được chạy với locale `en_US` và múi giờ `UTC` (cố định trong `tools/book.py`) để output luôn giống nhau.

## Lệnh

```bash
cd books/java-ocp
bash tools/run_all.sh                         # chạy mọi ví dụ, kiểm tra 350 câu hỏi, sinh COVERAGE.md, kiểm tra link
python3 tools/book.py examples ch03           # chạy ví dụ một chương (và cập nhật output trong Markdown)
python3 tools/book.py questions ch03 mock1    # kiểm tra câu hỏi + sinh lại phần câu hỏi/lời giải trong Markdown
python3 tools/book.py coverage                # sinh lại COVERAGE.md
python3 tools/check_links.py                  # kiểm tra link
bash tools/build_pdf.sh                       # build 3 PDF vào dist/ và kiểm tra dấu tiếng Việt
```

## Cấu trúc thư mục

```text
chapters/                    Markdown (nguồn sự thật)
examples/chNN/               ví dụ chạy được (+ *.out.txt / output.txt: output thật)
examples/questions/<set>/    questions.yaml + code Java sinh ra + CHECK_RESULT.txt
mock/                        3 đề + 3 file đáp án (sinh từ examples/questions/mockN)
cheatsheets/  schedule/      cheat sheet, lịch học
tools/                       book.py, check_links.py, run_all.sh, build_pdf.sh, pdf/
dist/                        PDF
```

## Bản quyền nội dung

Nội dung do tác giả (AI, theo yêu cầu của Nobin) tự viết. Tên các mục tiêu thi (objective) là của Oracle, trích ngắn để
đối chiếu. Không có exam dump, không sao chép sách có bản quyền.

## Nguồn tham khảo (Sources)

- Xem [SOURCES.md](SOURCES.md) và mục Sources ở cuối mỗi chương.
