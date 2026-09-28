# Thư viện Claude skills

Bộ skill (kỹ năng) cho Claude Code trong `.claude/skills/`. Mỗi skill là một thư mục có `SKILL.md`.
Claude luôn thấy **tên + description**; khi yêu cầu khớp, Claude gọi tool `Skill` để nạp hướng dẫn đầy đủ.
Bạn cũng có thể gọi trực tiếp: `/vietnamese-pdf-builder`, `/ocp-question-writer`, …

Đi cặp với Task 1 (18 agent trong `.claude/agents/`, branch `task-1-agents`).

## 1. Skill hay agent? (ý tưởng đơn giản)

| | Agent (Task 1) | Skill (Task 6) |
|---|---|---|
| Là gì | **Ai** làm việc: một vai trò có system prompt, tool, model riêng | **Làm thế nào**: quy trình, checklist, script đã test |
| Chạy ở đâu | Context riêng (subagent) | Nạp vào context đang dùng (main session hoặc agent) |
| Ví dụ | `code-reviewer` đưa verdict trước khi merge | `angular-review-checklist` = danh sách luật Angular |
| Kết hợp | Agent thêm `skills: [tên-skill]` vào frontmatter để **nạp sẵn** nội dung skill | Skill không bao giờ "đóng vai" một agent |

Quy tắc chống chồng chéo (chi tiết: [PLAN.md](PLAN.md)):
- Skill ví dụ trùng hoàn toàn với agent → **bỏ**: `srs-to-test-cases` (= test-case-writer),
  `requirement-challenger` (= ba-requirements-challenger), `english-roleplay-coach` (= english-coach).
- Skill review/tính năng theo stack → **đổi thành checklist** để agent nạp sẵn:
  `angular-review-checklist`, `csharp-review-checklist`, `react-native-feature-checklist`.
- `bilingual-handbook-writer` → `handbook-chapter-writer` (chỉ chương sách; README/ADR là việc của docs-writer).

Gợi ý nạp sẵn cho agent của Task 1 (chưa sửa file agent vì ngoài phạm vi task này):

| Agent | Thêm vào frontmatter |
|---|---|
| code-reviewer | `skills: [angular-review-checklist, csharp-review-checklist]` |
| angular-expert | `skills: [angular-review-checklist]` |
| csharp-dotnet | `skills: [csharp-review-checklist]` |
| react-native-mobile | `skills: [react-native-feature-checklist]` |
| docs-writer | (không cần; dùng `code-sample-runner` khi tài liệu có code) |

## 2. Bảng đầy đủ

| Skill | Nguồn | License | Khi dùng | KHÔNG dùng khi | Prompt ví dụ |
|---|---|---|---|---|---|
| [vietnamese-pdf-builder](../../.claude/skills/vietnamese-pdf-builder/SKILL.md) | Tự viết | Như repo | Build PDF sách/tài liệu tiếng Việt: pandoc → HTML → Chromium `page.pdf()`, Noto Serif/Sans, Mermaid → SVG, kiểm dấu bằng pdftotext | Viết nội dung chương; đọc/tách/gộp PDF có sẵn | "Build PDF cho sách OCP vào dist/ và kiểm tra dấu tiếng Việt" |
| [handbook-chapter-writer](../../.claude/skills/handbook-chapter-writer/SKILL.md) | Tự viết | Như repo | Viết/sửa một chương sách theo 8 mục (Mục tiêu → … → Nguồn tham khảo), GLOSSARY, ví dụ trong examples/ | README/ADR/wiki (docs-writer); build PDF; câu hỏi OCP | "Viết chương 5 sách C# về record" |
| [ocp-question-writer](../../.claude/skills/ocp-question-writer/SKILL.md) | Tự viết | Như repo | Câu hỏi luyện thi Java OCP 21 tự viết, định dạng questions.yaml, xác minh bằng JDK 21 | Lý thuyết Java; code Spring; chép đề thật/dump | "Viết 5 câu hỏi OCP về sealed class và chứng minh đáp án" |
| [code-sample-runner](../../.claude/skills/code-sample-runner/SKILL.md) | Tự viết | Như repo | Chạy code mẫu trong Markdown (Java, C#, TS, JS, Python, Bash), dán output thật hoặc "NOT RUN" | Câu hỏi OCP; unit test/CI của app; debug app | "Chạy các ví dụ trong guide.md và dán output thật" |
| [angular-review-checklist](../../.claude/skills/angular-review-checklist/SKILL.md) | Tự viết (theo tài liệu Angular) | Như repo | Luật review Angular 20–22: signals, input()/output(), @if/@for+track, OnPush, inject(), PrimeNG, a11y | Verdict/merge gate (code-reviewer); React Native; bảo mật | "Review cart.component.ts (Angular 22)" |
| [csharp-review-checklist](../../.claude/skills/csharp-review-checklist/SKILL.md) | Tự viết (theo tài liệu .NET) | Như repo | Luật review C# 14/.NET 10: async, DI lifetime, IHttpClientFactory, logging, EF Core | Verdict/merge gate (code-reviewer); Java/Angular; bảo mật | "Kiểm tra OrderService.cs trước khi mở MR" |
| [react-native-feature-checklist](../../.claude/skills/react-native-feature-checklist/SKILL.md) | Tự viết (theo tài liệu Expo) | Như repo | Thêm 1 tính năng vào app Expo: route src/app, feature folder, npx expo install, offline, a11y, jest-expo | Angular web; tối ưu hiệu năng (performance-optimizer); EAS/CI (devops-ci) | "Lên kế hoạch màn hình Saved words cho app Expo" |
| [vocabulary-extractor](../../.claude/skills/vocabulary-extractor/SKILL.md) | Tự viết | Như repo | Trích từ vựng TOEIC từ email/bài đọc → `word\|pos\|definition\|example` cho app TOEIC + bảng nghĩa | Roleplay (english-coach); trích hàng loạt từ sách có bản quyền | "Lấy từ vựng TOEIC từ email.txt cho app của tôi" |
| [webapp-testing](../../.claude/skills/webapp-testing/SKILL.md) | [anthropics/skills](https://github.com/anthropics/skills/tree/33375500bcea98d610eb30ce10ac4e59b89c390d/skills/webapp-testing) | Apache-2.0 (LICENSE.txt trong thư mục) | Kiểm thử web app local bằng Python Playwright: click, chụp màn hình, xem console | Test case QA viết tay (test-case-writer) | "Mở index.html, bấm Save và kiểm tra có chữ Saved!" |
| [skill-creator](../../.claude/skills/skill-creator/SKILL.md) | [anthropics/skills](https://github.com/anthropics/skills/tree/33375500bcea98d610eb30ce10ac4e59b89c390d/skills/skill-creator) | Apache-2.0 (LICENSE.txt trong thư mục) | Tạo skill mới, sửa skill, đo và tối ưu description | Tạo agent (dùng /agents) | "Tạo skill meeting-notes tóm tắt biên bản họp" |

"Như repo" = skill do phiên này viết, theo license của repo super-apps (repo hiện chưa có file LICENSE — xem Questions trong PR).

## 3. Cài đặt công cụ cần cho script

| Skill | Cần | Đã thử trên |
|---|---|---|
| vietnamese-pdf-builder | pandoc 3.x, Node + `playwright` + Chromium, poppler-utils, fonts-noto-core; Mermaid: `npm i mermaid` + `MERMAID_JS` | pandoc 3.1.3, playwright 1.56.1, Chromium 1194, mermaid 12.0.0 |
| ocp-question-writer | JDK 21+, Python + PyYAML | OpenJDK 21.0.10, PyYAML 6.0.1 |
| code-sample-runner | Công cụ của từng ngôn ngữ (thiếu → NOT RUN) | JDK 21.0.10, .NET SDK 10.0.112, Node 22.22.2, Python 3.11 |
| handbook-chapter-writer | Python 3.10+ | Python 3.11 |
| vocabulary-extractor | Python 3.10+; nên `pip install simplemma` | simplemma 2.0.0 |
| webapp-testing | Python `playwright` khớp Chromium có sẵn | `pip install playwright==1.56.0` |

## 4. Kiểm tra

```bash
python3 docs/skills/scripts/validate-skills.py          # frontmatter, tên, độ dài, link, credit
bash docs/skills/scripts/test-skill-scripts.sh          # script trong skill (ca đúng + ca sai)
python3 docs/skills/scripts/run-all-tests.py            # test thật bằng claude -p (1 test / skill)
```
Kết quả: [TESTING.md](TESTING.md). Nghiên cứu định dạng và so sánh repo: [RESEARCH.md](RESEARCH.md).

## 5. Thêm skill mới

1. Tạo `.claude/skills/<ten-skill>/SKILL.md` (tên = thư mục, chữ thường, gạch nối).
2. Description: câu 1 = làm gì; "Use when …"; "Not for … (dùng X)". ≤ 1024 ký tự.
3. SKILL.md ngắn (< 500 dòng); tài liệu dài để trong `references/`, script trong `scripts/` (chỉ khi đã test).
4. Chạy validator + thêm 1 test vào `run-all-tests.py`.

## Nguồn tham khảo (Sources)

- Claude Code docs — Skills: https://code.claude.com/docs/en/skills
- Claude Code docs — Subagents (`skills:` field): https://code.claude.com/docs/en/sub-agents
- Agent Skills spec (GitHub): https://github.com/agentskills/agentskills/blob/main/docs/specification.mdx
- anthropics/skills: https://github.com/anthropics/skills
