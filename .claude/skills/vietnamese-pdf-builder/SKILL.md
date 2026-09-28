---
name: vietnamese-pdf-builder
description: Build a print-ready PDF from Vietnamese Markdown (books, handbooks, chapters) with pandoc -> standalone HTML -> Playwright Chromium page.pdf(), Noto Serif/Noto Sans fonts, Mermaid diagrams rendered to SVG, then verify accents (ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ) with pdftotext and embedded fonts with pdffonts. Use when asked to build, rebuild or fix a PDF of a Vietnamese book or document, or when a PDF shows broken Vietnamese accents, missing fonts or unrendered diagrams. Not for writing chapter content (use handbook-chapter-writer), not for reading/splitting/merging existing PDFs, and not for LaTeX or typst pipelines.
compatibility: Needs pandoc 3.x, Node with the playwright package and its Chromium, poppler-utils (pdftotext, pdffonts, pdfinfo), fonts-noto-core. Mermaid needs mermaid.min.js (npm package mermaid).
---

# Vietnamese PDF builder

Markdown là nguồn sự thật (source of truth). PDF chỉ là sản phẩm build, để trong `dist/`.

Pipeline: `pandoc` (Markdown → 1 file HTML, CSS dùng "Noto Serif"/"Noto Sans")
→ Chromium của Playwright `page.pdf()` (vẽ Mermaid thành SVG trước khi in)
→ `check-pdf.py` (pdftotext + pdffonts).

## Steps

1. **Tìm script có sẵn.** Nếu sách đã có script build được commit (ví dụ `tools/build-pdf.sh`,
   `tools/book.py pdf`), dùng nó và chỉ sửa khi cần. Nếu chưa có, copy 4 file sau vào thư mục
   `tools/` của sách (rule: script build phải được commit cùng sách):
   `${CLAUDE_SKILL_DIR}/scripts/build-pdf.sh`, `render-pdf.cjs`, `check-pdf.py`,
   `${CLAUDE_SKILL_DIR}/assets/book.css` (sửa đường dẫn `css` trong build-pdf.sh nếu cần).
2. **Kiểm tra công cụ** (dừng và báo Blocker nếu thiếu, không giả kết quả):
   `pandoc --version`, `node -e "require('playwright')"` (hoặc với `NODE_PATH=$(npm root -g)`),
   `fc-list | grep -E "Noto (Serif|Sans)"`, `pdftotext -v`.
   Không chạy `playwright install` nếu máy đã có Chromium (`PLAYWRIGHT_BROWSERS_PATH`).
3. **Mermaid** (chỉ khi có khối ```mermaid): cần `mermaid.min.js`, ví dụ
   `npm i -D mermaid` rồi `export MERMAID_JS=$PWD/node_modules/mermaid/dist/mermaid.min.js`.
   Script dừng với lỗi nếu có sơ đồ mà thiếu MERMAID_JS → sơ đồ không bao giờ bị in dạng text.
4. **Build**, liệt kê chương theo đúng thứ tự:
   ```bash
   tools/build-pdf.sh -o dist/<book>.pdf -t "<Tên sách>" README.md ch01/*.md ch02/*.md
   ```
   Script tự chạy `check-pdf.py` ở cuối và trả exit code ≠ 0 nếu lỗi.
5. **Kiểm tra dấu lần cuối** trên chính file trong `dist/`:
   ```bash
   python3 tools/check-pdf.py dist/<book>.pdf --source <các file .md>
   ```
   Lần build đầu tiên của một máy mới: build thêm `assets/accent-test.md` và chạy với
   `--require-all` để chắc chắn cả 10 ký tự ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ đều ra đúng.
6. **Xem bằng mắt 1–2 trang** có bảng, code và sơ đồ: `pdftoppm -r 60 -png -f 2 -l 3 dist/x.pdf /tmp/pg`
   rồi mở ảnh. pdftotext không phát hiện được chữ bị đè hay sơ đồ bị cắt.
7. Commit script + PDF theo quy định của task (PDF trong `dist/`).

## Expected output

- `dist/<book>.pdf` (+ file `.html` trung gian cạnh nó; thêm vào `.gitignore` nếu không cần).
- Báo cáo dán **output thật** của check-pdf.py, dạng:
  ```
  char  in_source  in_pdf
  ắ             3       3  ok
  ...
  fonts: NotoSans-Bold, NotoSans-Regular, NotoSerif-Regular, NotoSansMono-Regular
  Pages:           2
  RESULT: PASS
  ```

## Quality checklist

- [ ] `RESULT: PASS`; không có font Type 3; mọi font Noto đều embedded.
- [ ] Số sơ đồ đã vẽ = số khối mermaid (`mermaid: N/N diagram(s) rendered`).
- [ ] Mục lục có, mỗi chương (`#`) sang trang mới, có số trang ở footer.
- [ ] Đã xem ảnh ít nhất 1 trang có bảng/code/sơ đồ.
- [ ] Script build được commit; lệnh build ghi trong README của sách.

## Pitfalls

- Cảnh báo `Could not load translations for vi` của pandoc 3.1.3 là vô hại (lỗi file dịch của pandoc).
- pdftotext có thể trả chữ dạng tổ hợp (NFD); `check-pdf.py` đã chuẩn hoá NFC trước khi so.
- Chromium ẩn nội dung `<details>` đang đóng khi in → `render-pdf.cjs` mở sẵn mọi `<details>` (lời giải bài tập vẫn in ra).
- Ảnh/SVG dùng đường dẫn tương đối theo từng chương: script truyền `--resource-path` = thư mục các chương.
- Chi tiết thêm và cách xử lý lỗi: [references/troubleshooting.md](references/troubleshooting.md).
