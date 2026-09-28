# Test result — `vietnamese-pdf-builder`

- Kết quả: **PASS — Skill tool triggered**
- Loại test: **real** (headless CLI `claude -p`, stream-json), chạy lúc 2026-09-28T15:07:12Z
- CLI: `2.1.283` · thư mục test mới, có đủ 10 skill của repo
  (`angular-review-checklist, code-sample-runner, csharp-review-checklist, handbook-chapter-writer, ocp-question-writer, react-native-feature-checklist, skill-creator, vietnamese-pdf-builder, vocabulary-extractor, webapp-testing`) + 33 skill có sẵn của môi trường (built-in/plugin, ví dụ `anthropic-skills:pdf`)
- Fixture: `test-fixtures/vietnamese-pdf-builder`
- Kết thúc: `success`, 15 turns, 42 s

## Prompt
```text
Build a print-ready PDF of chuong1.md into dist/chuong1.pdf and make sure the Vietnamese accents are correct in the PDF.
```

## Bằng chứng kích hoạt (tool_use "Skill" trong stream)
```json
[
 {
  "id": "toolu_01NgvnBVvcF2LWKb19b2GnWh",
  "input": {
   "skill": "vietnamese-pdf-builder",
   "args": "chuong1.md -> dist/chuong1.pdf"
  }
 }
]
```

Thứ tự tool đã gọi: `Skill → Bash → Read → Bash → Bash → Read → Bash → Bash → Bash → Read → Read → Bash → Write`

## File thay đổi trong thư mục test
```text
?? .gitignore
?? dist/chuong1.pdf
?? tools/book.css
?? tools/build-pdf.sh
?? tools/check-pdf.py
?? tools/render-pdf.cjs
```

## Câu trả lời cuối của Claude (nguyên văn)
PDF built successfully at `dist/chuong1.pdf` (2 pages: TOC + content).

Check-pdf.py output:
```
char  in_source  in_pdf
ắ             1       1  ok
ằ             1       1  ok
ẳ             1       1  ok
ẵ             1       1  ok
ặ             2       2  ok
ơ             3       8  ok
ư             3       7  ok
đ             2       3  ok
Ư             1       1  ok
Đ             3       3  ok
fonts: AAAAAA+NotoSans-Bold, BAAAAA+NotoSans-Regular, CAAAAA+NotoSerif-Regular, DAAAAA+NotoSansMono-Regular
Pages:           2
RESULT: PASS
```

All Noto fonts are embedded (no Type 3 bitmap fonts), and I visually confirmed the table, code block, and diacritics (ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ) render correctly on page 2.

Setup notes: no build script existed yet, so I copied `build-pdf.sh`, `render-pdf.cjs`, `check-pdf.py`, and `book.css` into `tools/` and added `dist/*.html` to `.gitignore` for the intermediate file. No Mermaid diagrams were present, so that step was skipped. I did not commit anything — let me know if you'd like me to commit the `tools/` scripts and the PDF.
