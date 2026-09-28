# Test result — `ocp-question-writer`

- Kết quả: **PASS — Skill tool triggered**
- Loại test: **real** (headless CLI `claude -p`, stream-json), chạy lúc 2026-09-28T15:07:12Z
- CLI: `2.1.283` · thư mục test mới, có đủ 10 skill của repo
  (`angular-review-checklist, code-sample-runner, csharp-review-checklist, handbook-chapter-writer, ocp-question-writer, react-native-feature-checklist, skill-creator, vietnamese-pdf-builder, vocabulary-extractor, webapp-testing`) + 33 skill có sẵn của môi trường (built-in/plugin, ví dụ `anthropic-skills:pdf`)
- Fixture: `test-fixtures/ocp-question-writer`
- Kết thúc: `success`, 11 turns, 56 s

## Prompt
```text
Viết 2 câu hỏi trắc nghiệm luyện thi Java OCP 21 (tự viết, không lấy từ đề thật) về record và switch pattern matching. Lưu vào questions.yaml và chứng minh đáp án đúng.
```

## Bằng chứng kích hoạt (tool_use "Skill" trong stream)
```json
[
 {
  "id": "toolu_01AdRMZw6xRdjJXbdVsUBP2E",
  "input": {
   "skill": "ocp-question-writer",
   "args": "Viết 2 câu hỏi trắc nghiệm luyện thi Java OCP 21 (1Z0-830) bằng tiếng Việt về chủ đề record và switch pattern matching (record patterns trong switch). Lưu vào questions.yaml và chứng minh đáp án đúng bằng cách compile/run với JDK 21."
  }
 }
]
```

Thứ tự tool đã gọi: `Skill → Read → Read → Read → Bash → Bash → Bash → Write → Bash`

## File thay đổi trong thư mục test
```text
?? questions.yaml
```

## Câu trả lời cuối của Claude (nguyên văn)
Đã xác minh xong. Kết quả:

```
PASS RP-01: output 'NPE' confirmed
PASS RP-02: compile error on lines [8, 9] confirmed

2/2 questions verified with javac 21.0.10 --release 21
```

Đã lưu tại `/tmp/skill-tests/ocp-question-writer-1790608032/questions.yaml`, 2 câu:

- **RP-01** (medium): trong switch pattern matching, `default` không bắt `null` — thiếu `case null` khiến `describe(null)` ném `NullPointerException` dù có `default`. → đáp án B ("NPE"), đã compile/run thật ra kết quả này.
- **RP-02** (hard): record pattern + sealed interface — nhánh `case Shape sh` (type pattern tổng quát) đặt trước `case Circle c` / `case Square sq` khiến hai nhánh sau bị "dominated by a preceding case label" → lỗi biên dịch đúng ở L2 và L3, đã xác minh bằng `javac --release 21`.
