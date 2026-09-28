# RESEARCH — Định dạng skill chính thức và so sánh các bộ skill

Ngày kiểm tra: 2026-09-28. Phiên bản CLI dùng để test: Claude Code `2.1.283` (`claude --version`).

## 1. Skill là gì? (ý tưởng đơn giản)

Skill (kỹ năng) là **một thư mục** có file `SKILL.md`. Claude luôn thấy **tên + mô tả (description)**
của mọi skill. Khi yêu cầu của người dùng khớp với mô tả, Claude gọi tool `Skill` để nạp **toàn bộ
nội dung** `SKILL.md`. File phụ (references/, scripts/) chỉ được đọc hoặc chạy khi cần
→ gọi là "progressive disclosure" (tiết lộ dần), giúp tiết kiệm context.

Ví dụ thật trong repo này: `.claude/skills/vietnamese-pdf-builder/SKILL.md` + `scripts/build-pdf.mjs`.

## 2. Định dạng chính thức (đi sâu)

### 2.1 Vị trí (Claude Code docs)

| Loại | Đường dẫn | Phạm vi |
|---|---|---|
| Project | `.claude/skills/<skill-name>/SKILL.md` | Repo này; commit để cả team dùng |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | Mọi project trên máy |
| Nested | `<subdir>/.claude/skills/...` | Khi Claude làm việc trong `<subdir>` |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Gọi bằng `/plugin:skill` |

Tên dành riêng: không dùng `synced` hoặc tên bắt đầu bằng `anthropic-skills` ở project/personal.

### 2.2 Cấu trúc thư mục (Agent Skills spec)

```
skill-name/
├── SKILL.md          # bắt buộc: frontmatter + hướng dẫn
├── scripts/          # tuỳ chọn: code chạy được
├── references/       # tuỳ chọn: tài liệu dài
└── assets/           # tuỳ chọn: template, tài nguyên
```

### 2.3 Frontmatter

| Trường | Bắt buộc | Ràng buộc | Nguồn |
|---|---|---|---|
| `name` | Có (spec) / tuỳ chọn (Claude Code, mặc định = tên thư mục) | 1–64 ký tự, `a-z 0-9 -`, không bắt đầu/kết thúc bằng `-`, không có `--`, **phải trùng tên thư mục** | spec, docs |
| `description` | Có | 1–1024 ký tự (spec). Claude Code: `description` + `when_to_use` ≤ 1.536 ký tự | spec, docs |
| `when_to_use` | Không | Nối vào description, chung giới hạn 1.536 | docs |
| `license` | Không | Tên license hoặc tên file license đi kèm | spec |
| `compatibility` | Không | ≤ 500 ký tự | spec |
| `metadata` | Không | map key → value | spec |
| `allowed-tools` | Không | Tool được **cho phép sẵn** trong lượt đó (không giới hạn tool) | spec (experimental), docs |
| `disable-model-invocation` | Không | `true` = chỉ người dùng gọi `/name` được | docs |
| `user-invocable` | Không | `false` = chỉ Claude gọi (kiến thức nền) | docs |
| `context: fork` + `agent` | Không | Chạy skill trong subagent riêng | docs |
| `model`, `effort`, `paths`, `hooks`, `shell`, `arguments`, `argument-hint`, `disallowed-tools`, `background` | Không | Xem docs | docs |

Validator của repo (`docs/skills/scripts/validate-skills.py`) kiểm tra đúng các luật trên
+ luật riêng của Nobin: skill tái sử dụng có file LICENSE thì phải có dòng `Source:` ở đầu.

### 2.4 Description kích hoạt skill như thế nào?

- Description **luôn** nằm trong context (kể cả trước khi gọi); nội dung đầy đủ chỉ nạp khi gọi.
- Docs khuyên: đặt **use case chính lên đầu**; spec khuyên có **từ khoá cụ thể**, nói rõ
  "làm gì" và "khi nào dùng".
- Danh sách skill có thể bị cắt ngắn để tiết kiệm context → câu đầu phải đủ nghĩa.
- Quy ước của repo này: câu 1 = làm gì; "Use when …"; "Not for … (dùng X)" để tránh chồng chéo.

### 2.5 Độ dài và vòng đời

- `SKILL.md` nên < 500 dòng; tài liệu dài chuyển sang file phụ (docs).
- Sau khi gọi, nội dung skill **ở lại context** cho tới hết phiên; khi auto-compact, giữ tối đa
  5.000 token đầu của mỗi skill, tổng 25.000 token cho mọi skill (docs).
- `${CLAUDE_SKILL_DIR}` = thư mục chứa SKILL.md → dùng để gọi script đi kèm.

### 2.6 Skill và subagent

- Trường `skills:` trong frontmatter của **agent** nạp **toàn bộ nội dung** skill vào agent lúc khởi
  động. Không có trường này, agent vẫn tự gọi được skill qua tool `Skill` (docs sub-agents).
- ⇒ Ranh giới cho repo: **agent = vai trò (ai làm)**, **skill = quy trình/checklist (làm thế nào)**.
  Ví dụ: agent `code-reviewer` có thể thêm `skills: [angular-review-checklist]`.

## 3. So sánh các bộ skill trên GitHub

Số sao và ngày commit lấy từ GitHub API (qua công cụ tìm kiếm repo của GitHub) ngày 2026-09-28.

| URL | Stars | Commit gần nhất | License | Hữu ích cho Nobin | Dùng lại? |
|---|---|---|---|---|---|
| https://github.com/anthropics/skills | 178.767 | 2026-09-24 | Theo từng skill: phần lớn Apache-2.0; `docx/pdf/pptx/xlsx` = Proprietary (source-available) | `webapp-testing` (Playwright cho Angular/Expo web), `skill-creator` (tạo + đo skill) | **Có**: `webapp-testing`, `skill-creator` (Apache-2.0). **Không**: `pdf` và các document skill (Proprietary) |
| https://github.com/agentskills/agentskills | 25.758 | 2026-08-09 | Apache-2.0 | Bản spec chính thức của định dạng SKILL.md | Chỉ tham khảo (spec) |
| https://github.com/obra/superpowers | 292.404 | 2026-09-27 | MIT | Quy trình phát triển (TDD, debugging, writing-plans, writing-skills) | Không — trùng với agents Task 1 (debugger, code-reviewer) và cách làm việc của lead; chỉ tham khảo `writing-skills` |
| https://github.com/vercel-labs/agent-skills | 31.661 | 2026-08-28 | README + frontmatter ghi "MIT", **nhưng repo không có file LICENSE** (GitHub API: license = null) | `react-native-skills` (35+ luật hiệu năng RN/Expo) | Không copy — không có file LICENSE có dòng copyright để giữ lại; chỉ gợi ý link (xem README) |
| https://github.com/trailofbits/skills | 7.278 | 2026-09-25 | CC-BY-SA-4.0 | Skill bảo mật/audit | Không — share-alike ảnh hưởng license repo; security-reviewer (Task 1) đã có |
| https://github.com/alirezarezvani/claude-skills | 26.725 | 2026-08-30 | MIT | 388 skill tổng quát | Không — không có skill Angular/C#/Java/RN riêng |

Kết luận: chỉ dùng lại 2 skill Apache-2.0 của Anthropic. Mọi skill hỗ trợ sách/app là tự viết,
vì không bộ nào có quy trình PDF tiếng Việt, câu hỏi OCP được xác minh bằng JDK, hay cấu trúc
chương theo rule 8 của Nobin.

## 4. Kiểm thử thật bằng CLI headless

`claude -p "<prompt>" --output-format stream-json --verbose --allowedTools "Bash,Read,..."` chạy
trong thư mục tạm có `.claude/skills/<skill>`. Trong luồng JSON, tìm `tool_use` có `name == "Skill"`
và `input.skill == <tên skill>` ⇒ chứng minh description đã kích hoạt skill.
Script: `docs/skills/scripts/run-skill-test.sh`.

## Nguồn tham khảo (Sources)

- Claude Code docs — Skills: https://code.claude.com/docs/en/skills (mở 2026-09-28)
- Claude Code docs — Subagents: https://code.claude.com/docs/en/sub-agents (mở 2026-09-28)
- Agent Skills spec (nguồn GitHub): https://raw.githubusercontent.com/agentskills/agentskills/main/docs/specification.mdx (mở 2026-09-28; agentskills.io bị chặn bởi sandbox)
- https://github.com/anthropics/skills (clone commit `33375500bcea98d610eb30ce10ac4e59b89c390d`)
- https://github.com/obra/superpowers
- https://github.com/vercel-labs/agent-skills (clone commit `063bee94c3f4df8453406c830b0a7df0f2860278`)
- https://github.com/trailofbits/skills
- https://github.com/alirezarezvani/claude-skills
