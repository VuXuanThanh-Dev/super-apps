# Troubleshooting — vietnamese-pdf-builder

| Triệu chứng | Nguyên nhân thường gặp | Cách sửa |
|---|---|---|
| `Cannot find module 'playwright'` | playwright cài global, Node không tìm thấy | `NODE_PATH=$(npm root -g) node render-pdf.cjs ...` (build-pdf.sh đã làm) hoặc `npm i -D playwright@<đúng bản khớp Chromium>` |
| `Executable doesn't exist at .../chromium-XXXX` | Bản playwright không khớp Chromium có sẵn | Dùng đúng bản playwright mà máy đã cài (`npm ls -g playwright`), không tải browser mới nếu mạng chặn |
| Dấu tiếng Việt ra ô vuông hoặc font lạ | Máy thiếu Noto | `sudo apt-get install fonts-noto-core` rồi `fc-cache -f`; kiểm tra `fc-list \| grep Noto` |
| `check-pdf.py` báo `Type 3 font found` | Chromium dùng glyph dự phòng | Thường do font thiếu glyph → đổi sang font Noto có đủ glyph trong CSS |
| `ERROR: N mermaid block(s) found but MERMAID_JS is not set` | Chưa có mermaid.min.js | `npm i -D mermaid` và export `MERMAID_JS` |
| `ERROR: mermaid: ...Parse error` | Cú pháp sơ đồ sai | Sửa khối mermaid trong Markdown; thử lại |
| Bảng bị cắt ngang trang | Bảng dài hơn một trang | Chia bảng; hoặc bỏ `page-break-inside: avoid` cho `table` trong CSS |
| Code dài bị tràn lề | Dòng quá dài | CSS đã `white-space: pre-wrap`; nếu vẫn tràn, xuống dòng trong nguồn |

Kiểm tra nhanh toàn bộ pipeline trên máy mới:
```bash
MERMAID_JS=... scripts/build-pdf.sh -o /tmp/accent.pdf -t "Test" assets/accent-test.md
python3 scripts/check-pdf.py /tmp/accent.pdf --require-all
```
