# Task 6 — PLAN: Thư viện Claude skills

Branch: `task-6-skills` · Thư mục: `.claude/skills/` (CHỈ thư mục skill) và `docs/skills/`.
Đi cặp với Task 1 (branch `task-1-agents`, 18 subagent trong `.claude/agents/`).

## Mục tiêu

Tạo một bộ **skill** (kỹ năng) cho Claude Code, đã kiểm thử thật bằng CLI headless, để hỗ trợ
các task khác của Nobin: agents (Task 1), sách Java OCP (Task 2), sách React Native (Task 3),
sách C# (Task 4) và app TOEIC (Task 5).

## Ranh giới skill ↔ agent (quyết định quan trọng)

- **Agent = AI làm việc gì (một vai trò)**: có system prompt, tool riêng, model riêng, chạy trong
  context riêng. Ví dụ: `code-reviewer`, `test-case-writer`.
- **Skill = cách làm / kiến thức tái sử dụng**: quy trình, checklist, script đã test.
  Skill được nạp vào context khi cần (main session hoặc agent nạp trước qua trường `skills:`
  trong frontmatter của agent).
- Quy tắc: nếu một skill ví dụ trong đề **trùng trách nhiệm** với agent của Task 1 thì
  (a) bỏ, hoặc (b) đổi thành **checklist kiến thức** mà agent có thể preload. Không có skill nào
  "đóng vai" một agent.

| Skill ví dụ trong đề | Agent gần nhất (Task 1) | Quyết định |
|---|---|---|
| vietnamese-pdf-builder | (không có) | GIỮ — quy trình + script build PDF |
| bilingual-handbook-writer | docs-writer (tài liệu song ngữ) | ĐỔI TÊN → `handbook-chapter-writer`: chỉ chương sách theo cấu trúc rule 8; README/ADR vẫn là việc của docs-writer |
| ocp-question-writer | (không có; java-spring-backend là Spring) | GIỮ — câu hỏi gốc + script xác minh bằng JDK 21 |
| code-sample-runner | (không có) | GIỮ — chạy code mẫu trong tài liệu, lấy output thật |
| react-native-feature | react-native-mobile | ĐỔI → `react-native-feature-checklist` (checklist; agent preload) |
| csharp-code-review | code-reviewer, csharp-dotnet | ĐỔI → `csharp-review-checklist` (checklist; agent preload) |
| angular-code-review | code-reviewer, angular-expert | ĐỔI → `angular-review-checklist` (checklist; agent preload) |
| srs-to-test-cases | test-case-writer (đã có đủ kỹ thuật) | BỎ — trùng hoàn toàn |
| requirement-challenger | ba-requirements-challenger | BỎ — trùng hoàn toàn |
| vocabulary-extractor | (không có) | GIỮ — trích từ vựng cho app TOEIC |
| english-roleplay-coach | english-coach | BỎ — trùng hoàn toàn |

Skill dùng lại (M2, chỉ license cho phép): `webapp-testing`, `skill-creator` từ
`anthropics/skills` (Apache-2.0, kiểm tra LICENSE.txt từng thư mục). Không dùng `pdf`, `docx`,
`pptx`, `xlsx` vì là source-available/Proprietary.

## Mục lục (file sẽ tạo)

| File | Nội dung |
|---|---|
| `docs/skills/PLAN.md` | File này |
| `docs/skills/PROGRESS.md` | Done / Next / Blockers / Decisions |
| `docs/skills/RESEARCH.md` | Định dạng chính thức + bảng so sánh các bộ skill |
| `docs/skills/scripts/validate-skills.py` | Kiểm tra frontmatter mọi skill |
| `docs/skills/scripts/run-skill-test.sh` | Chạy test headless + tìm tool_use "Skill" |
| `docs/skills/TESTING.md` | 1 test / skill, kết quả |
| `docs/skills/test-results/<skill>.md` | Bằng chứng từng test |
| `docs/skills/README.md` | Bảng đầy đủ + ranh giới skill/agent |
| `.claude/skills/<name>/SKILL.md` (+ references/, scripts/) | Các skill |

## Milestones

- **M1 — Research** → `RESEARCH.md` + validator script.
- **M2 — Reuse** → `webapp-testing`, `skill-creator` (giữ LICENSE.txt, dòng credit ở đầu).
- **M3 — Skill mới** → 8 skill: vietnamese-pdf-builder, handbook-chapter-writer,
  ocp-question-writer, code-sample-runner, angular-review-checklist, csharp-review-checklist,
  react-native-feature-checklist, vocabulary-extractor. Script trong skill chỉ khi đã test.
- **M4 — Testing** → chạy `claude -p` headless cho từng skill, chứng minh Skill tool được gọi.
- **M5 — README** → bảng (tên, nguồn, license, khi dùng, prompt ví dụ) + PR.

## Definition of Done (copy từ task)

- [ ] Comparison table
- [ ] Every skill folder valid; reused skills keep license and credit
- [ ] TESTING.md: one test per skill
- [ ] README.md with the full table
