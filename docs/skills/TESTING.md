# TESTING — mỗi skill 1 test thật

Ngày chạy: 2026-09-28. CLI: Claude Code `2.1.283`. **Tất cả test đều là test thật (real)**, không có test "simulated".

## Cách test (ý tưởng đơn giản)

1. Tạo một thư mục mới (ngoài repo), copy **cả 10 skill** + fixture nhỏ của skill đó
   ([test-fixtures/](test-fixtures/)).
2. Chạy CLI headless với một prompt **thực tế, không nhắc tên skill**:
   `claude -p "<prompt>" --output-format stream-json --verbose --allowedTools "Bash,Read,Edit,Write,Grep,Glob,Skill"`.
3. Đọc luồng JSON: PASS khi có `tool_use` tên `Skill` với `input.skill` **đúng bằng** tên skill
   (skill plugin như `anthropic-skills:pdf` không được tính). Môi trường còn 33 skill khác
   (built-in/plugin) cạnh tranh → description phải đủ rõ mới được chọn.
4. Kiểm tra thêm kết quả công việc (file tạo ra, output script) và lưu bằng chứng vào
   [test-results/](test-results/).

Lệnh: `python3 docs/skills/scripts/run-all-tests.py` (4 test song song) ·
`bash docs/skills/scripts/run-negative-tests.sh` · `bash docs/skills/scripts/test-skill-scripts.sh`.

## Kết quả kích hoạt (1 test / skill)

| Skill | Prompt (rút gọn) | Kích hoạt | Turns / thời gian | Kết quả công việc (đã kiểm tra) | Bằng chứng |
|---|---|---|---|---|---|
| vietnamese-pdf-builder | "Build a print-ready PDF of chuong1.md … accents correct" | ✅ PASS | 15 / 42 s | Copy script vào `tools/`, tạo `dist/chuong1.pdf`; check-pdf: 10/10 ký tự ok, 4 font Noto embedded, `RESULT: PASS`; model xem ảnh trang 2 | [test-results/vietnamese-pdf-builder.md](test-results/vietnamese-pdf-builder.md) |
| ocp-question-writer | "Viết 2 câu hỏi … Java OCP 21 về record và switch pattern matching … chứng minh đáp án" | ✅ PASS | 11 / 56 s | `questions.yaml` 2 câu; `2/2 questions verified with javac 21.0.10`; chạy lại verifier trên file artifact: vẫn 2/2 PASS | [kết quả](test-results/ocp-question-writer.md), [questions.yaml](test-results/artifacts/ocp-question-writer.questions.yaml) |
| code-sample-runner | "The code examples in guide.md must show their real output" | ✅ PASS | 10 / 25 s | Fixture có output **sai cố ý** (`50`); skill sửa thành output thật `Tổng 1..10 = 55`, thêm output Python; `--check` exit 0 | [kết quả](test-results/code-sample-runner.md), [guide.md](test-results/artifacts/code-sample-runner.guide.md) |
| handbook-chapter-writer | "Viết chương 5 cho sách C# … `record` … examples/ch05/" | ✅ PASS | 29 / 126 s | `ch05-record.md` đủ 8 mục (`check_chapter.py` → OK), 2 ví dụ C# chạy bằng `dotnet run`, GLOSSARY +6 thuật ngữ; link Microsoft Learn bị chặn → model tự ghi UNVERIFIED | [kết quả](test-results/handbook-chapter-writer.md), [chương](test-results/artifacts/handbook-chapter-writer.ch05-record.md) |
| angular-review-checklist | "Please review src/app/cart.component.ts in this Angular 22 project" | ✅ PASS | 14 / 70 s | Bảng findings có mã luật (NG-T1, NG-R3, NG-K2 …), ghi rõ không chạy được lint vì fixture không có node_modules | [test-results/angular-review-checklist.md](test-results/angular-review-checklist.md) |
| csharp-review-checklist | "Check OrderService.cs for problems before I open the merge request" | ✅ PASS | 11 / 63 s | 11 findings có mã luật: `async void`, `.Result`, `ToList()` trước `Where`, `new HttpClient()`, `throw ex;`, log interpolation …; đã thử `dotnet build` và báo thật | [test-results/csharp-review-checklist.md](test-results/csharp-review-checklist.md) |
| react-native-feature-checklist | "Add a 'Saved words' screen … Give me the plan" | ✅ PASS | 11 / 76 s | Kế hoạch theo checklist: đọc phiên bản ghim, spec 5 dòng, file trong `src/app` + `src/features/…`, dùng `expo-sqlite` có sẵn, báo thiếu tsconfig/scripts | [test-results/react-native-feature-checklist.md](test-results/react-native-feature-checklist.md) |
| vocabulary-extractor | "Lấy từ vựng TOEIC hữu ích từ email.txt … word\|pos\|definition\|example" | ✅ PASS | 9 / 62 s | Chạy script (simplemma), `new-words.txt` 23 mục đúng 4 trường, bảng nghĩa tiếng Việt + họ từ + collocation | [kết quả](test-results/vocabulary-extractor.md), [new-words.txt](test-results/artifacts/vocabulary-extractor.new-words.txt) |
| webapp-testing (reused) | "Open index.html in a real headless browser, click 'Save word' … screenshot" | ✅ PASS | 7 / 19 s | Python Playwright thấy "Saved!", lưu `saved.png` | [kết quả](test-results/webapp-testing.md), [saved.png](test-results/artifacts/webapp-testing.saved.png) |
| skill-creator (reused) | "Create a new Claude skill in .claude/skills/meeting-notes …" | ✅ PASS | 5 / 30 s | Tạo `.claude/skills/meeting-notes/SKILL.md` | [kết quả](test-results/skill-creator.md), [SKILL.md](test-results/artifacts/skill-creator.meeting-notes.SKILL.md) |

**10/10 PASS.**

## Test âm (không được kích hoạt) — chứng minh không chồng chéo với agent

Prompt thuộc việc của agent Task 1 (test-case-writer, english-coach, ba-requirements-challenger):
không skill nào của repo được gọi → **3/3 PASS**. (Thư mục test chỉ có skill, không có agent, nên test này chứng minh
skill không "giành" việc của agent; khi merge cả hai PR, agent vẫn là nơi xử lý các prompt đó.) Chi tiết: [test-results/negative.md](test-results/negative.md).

## Test script trong skill (ca đúng + ca sai)

`test-skill-scripts.sh`: 11/11 kỳ vọng đúng — PDF (có Mermaid) + `--require-all`, `<details>` được in,
verifier OCP bắt được đáp án sai, `run_samples.py --check` bắt được output sửa tay, `check_chapter.py`
bắt được thiếu mục "Đi sâu", extractor từ vựng. Output thật: [test-results/scripts.md](test-results/scripts.md).

## Validator và link checker

```text
$ python3 docs/skills/scripts/validate-skills.py
... 10 skills, 0 errors   (2 warning: description của 2 skill reused không có phần "Not for" — giữ nguyên bản gốc)
$ python3 docs/skills/scripts/check-links.py
28 external links, 0 broken, 0 blocked by sandbox
```

## Giới hạn của test

- Mỗi skill chỉ 1 prompt kích hoạt → chưa đo tỉ lệ kích hoạt với nhiều cách hỏi khác nhau
  (skill-creator có công cụ đo này — xem "Ideas for later" trong PR).
- Model dùng cho test là model mặc định của CLI trong phiên này; model khác có thể chọn skill khác.
- Fixture nhỏ, không có `node_modules` → lint/tsc Angular và React Native không chạy trong test (model ghi rõ).
