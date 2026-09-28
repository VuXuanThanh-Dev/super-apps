# Test result — `code-sample-runner`

- Kết quả: **PASS — Skill tool triggered**
- Loại test: **real** (headless CLI `claude -p`, stream-json), chạy lúc 2026-09-28T15:07:12Z
- CLI: `2.1.283` · thư mục test mới, có đủ 10 skill của repo
  (`angular-review-checklist, code-sample-runner, csharp-review-checklist, handbook-chapter-writer, ocp-question-writer, react-native-feature-checklist, skill-creator, vietnamese-pdf-builder, vocabulary-extractor, webapp-testing`) + 33 skill có sẵn của môi trường (built-in/plugin, ví dụ `anthropic-skills:pdf`)
- Fixture: `test-fixtures/code-sample-runner`
- Kết thúc: `success`, 10 turns, 25 s

## Prompt
```text
The code examples in guide.md must show their real output. Please run them and put the real output under each example.
```

## Bằng chứng kích hoạt (tool_use "Skill" trong stream)
```json
[
 {
  "id": "toolu_01XpdUCw4S1CnwZarhmmcBVL",
  "input": {
   "skill": "code-sample-runner",
   "args": "guide.md"
  }
 }
]
```

Thứ tự tool đã gọi: `Skill → Glob → Read → Edit → Read → Edit → Bash → Bash`

## File thay đổi trong thư mục test
```text
 M guide.md
```

## Câu trả lời cuối của Claude (nguyên văn)
`--check` confirms the outputs are current (exit 0). Summary:

- **Java** sum: real output is `Tổng 1..10 = 55` (the doc previously had a wrong hardcoded `50`, now fixed).
- **Python** sorted-by-length: real output is `['budget', 'invoice', 'contract']`.

Both samples were marked with `<!-- run -->`, executed, and their real output pasted into `<!-- output -->` blocks in `guide.md`.
