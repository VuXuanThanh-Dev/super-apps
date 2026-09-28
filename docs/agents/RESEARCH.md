# RESEARCH — Claude Code subagents (M1)

> Ngày kiểm tra: 2026-09-28. Mọi dữ kiện có thể thay đổi đều ghi "(checked 2026-09-28)".

## 1. Ý tưởng đơn giản

Subagent (tác tử con) là một "trợ lý chuyên môn" mà Claude Code có thể giao việc.
Mỗi subagent là **một file Markdown** có phần đầu YAML (frontmatter) và phần thân là
system prompt (lời dặn hệ thống). Subagent chạy trong **context riêng**, làm xong thì
chỉ trả về bản tóm tắt. Nhờ vậy cuộc trò chuyện chính không bị ngập log, kết quả tìm kiếm.

Ví dụ thực tế: bạn gõ "review giúp tôi MR này". Claude đọc `description` của các
subagent, thấy `code-reviewer` khớp nhất, rồi giao việc cho nó.

## 2. Định dạng chính thức (checked 2026-09-28)

Nguồn: tài liệu chính thức https://code.claude.com/docs/en/sub-agents và
https://code.claude.com/docs/en/tools-reference.

### 2.1 Vị trí file

| Vị trí | Phạm vi | Ghi chú |
|---|---|---|
| `.claude/agents/` | Dự án hiện tại | Nên commit vào git để cả team dùng |
| `~/.claude/agents/` | Mọi dự án của bạn | Agent cá nhân |
| Thư mục `agents/` của plugin | Nơi plugin được bật | Ưu tiên thấp nhất |
| Cờ CLI `--agents '{...}'` | Một phiên | JSON |

Claude Code theo dõi (watch) `.claude/agents/`: sửa file thì lần giao việc sau dùng
bản mới, **không cần khởi động lại**. Ngoại lệ: nếu thư mục `agents` **chưa tồn tại lúc
phiên bắt đầu**, phải khởi động lại phiên sau khi tạo file đầu tiên.

### 2.2 Frontmatter

| Trường | Bắt buộc | Ý nghĩa |
|---|---|---|
| `name` | Có | Tên duy nhất. Không bắt đầu bằng `-`, không chứa `:`. Quy ước: kebab-case |
| `description` | Có | Khi nào Claude nên giao việc cho agent này. Đây là "công tắc kích hoạt" |
| `tools` | Không | Danh sách tool được phép (chuỗi cách nhau bởi dấu phẩy hoặc YAML list). **Bỏ trống = kế thừa mọi tool** |
| `disallowedTools` | Không | Danh sách tool bị cấm (denylist) |
| `model` | Không | `sonnet`, `opus`, `haiku`, `fable`, ID đầy đủ, hoặc `inherit` |
| `permissionMode` | Không | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `effort`, `isolation`, `color`, `omitClaudeMd`, `initialPrompt` | Không | Tuỳ chọn nâng cao |

### 2.3 Chọn model

Thứ tự quyết định model: tham số `model` khi gọi → `model` trong frontmatter
(`inherit` = dùng model của phiên chính) → biến môi trường `CLAUDE_CODE_SUBAGENT_MODEL`
→ model của phiên chính.

Quy tắc thực tế (tổng hợp từ docs + các repo bên dưới):
- `opus`: việc cần suy luận sâu, sai thì tốn kém (review bảo mật, thiết kế DB, soi SRS).
- `sonnet`: việc lập trình/viết thông thường.
- `haiku`: việc nhanh, lặp lại, rẻ (commit message, lệnh git).
- `inherit`: để người dùng tự chọn theo phiên (các agent viết code theo stack).

### 2.4 Giới hạn tool (least privilege — quyền tối thiểu)

- `tools` là **allowlist**: chỉ những tool được liệt kê. Agent chỉ đọc thì không cho `Edit`/`Write`.
- Không liệt kê `Agent` trong `tools` ⇒ subagent **không thể sinh subagent khác**
  (mặc định subagent được lồng tối đa 3 tầng).
- Trên macOS/Linux/WSL, `Glob` và `Grep` **không có trong bộ tool mặc định**; Claude tìm
  bằng `find`/`grep` qua `Bash`. Nếu subagent liệt kê `Glob`/`Grep` **và không có `Bash`**,
  hai tool này được bật lại cho riêng subagent đó. ⇒ Agent chỉ-đọc nên dùng
  `Read, Grep, Glob` (không `Bash`).
- Tool có quyền rộng nhất là `Bash` (chạy mọi lệnh). Chỉ cấp khi agent thật sự cần chạy lệnh
  (git diff, build, test).

### 2.5 Viết `description` để kích hoạt đúng lúc

Docs chính thức:
- "Claude uses each subagent's description to decide when to delegate tasks."
- Mô tả chiếm context nên **giữ ngắn**; tổng mô tả của các subagent tự viết vượt
  **15.000 token** thì Claude Code cảnh báo khi khởi động.
- Ví dụ trong docs dùng cụm "Use proactively after code changes." để khuyến khích tự giao việc.

Agent `agent-creator` trong plugin chính thức `plugin-dev` (repo anthropics/claude-code)
khuyên: mở đầu bằng "Use this agent when…", kèm 2–4 ví dụ kích hoạt.

**Quyết định cho repo này:** mỗi `description` = 1 câu "Use when…" + 1 câu "Not for… (use X)"
+ 1–2 ví dụ ngắn trong ngoặc kép (có cả tiếng Việt, vì Nobin hay gõ tiếng Việt).
Giữ dưới ~450 ký tự. Lý do: vừa đủ để phân biệt các agent gần nhau, vừa không tốn token
(18 agent × ~120 token ≈ 2.200 token, xa ngưỡng 15.000).

## 3. So sánh 5 repo subagent uy tín

Tiêu chí "uy tín" (rule 3): commit trong 12 tháng gần đây, license mã nguồn mở rõ ràng,
có người dùng thật, có người bảo trì.

| # | URL | Stars | Commit gần nhất | License | Điều hữu ích | Ngày kiểm tra |
|---|---|---|---|---|---|---|
| 1 | https://github.com/wshobson/agents | 40.1k | 2026-09-26 | MIT | Phân tầng model rõ (Opus cho kiến trúc/bảo mật/review, Sonnet cho docs/test/debug, Haiku cho việc nhanh, `inherit` cho code theo stack); đóng gói theo plugin để chỉ nạp phần cần | 2026-09-28 |
| 2 | https://github.com/VoltAgent/awesome-claude-code-subagents | 25.4k | 2026-09-21 | MIT | 161+ agent chia 10 nhóm; phân quyền tool theo vai trò (reviewer chỉ đọc, developer đầy đủ) | 2026-09-28 |
| 3 | https://github.com/anthropics/claude-plugins-official | 37.1k | 2026-09-28 | Apache-2.0 | Thư mục plugin chính thức của Anthropic; cấu trúc `agents/` chuẩn trong plugin | 2026-09-28 |
| 4 | https://github.com/davepoon/buildwithclaude | 3.6k | 2026-09-28 | MIT | 117 agent + commands/hooks/skills; quy trình đóng góp agent có khuôn mẫu | 2026-09-28 |
| 5 | https://github.com/0xfurai/claude-code-subagents | 1.0k | 2025-10-15 | MIT | 100+ agent chuyên ngôn ngữ/framework (python-expert, react-expert…); tên kebab-case thống nhất | 2026-09-28 |

Tham khảo thêm (không đưa vào top 5):
- https://github.com/anthropics/claude-code/tree/main/plugins — ví dụ agent **chính thức**
  (`feature-dev/code-reviewer`, `pr-review-toolkit/*`, `plugin-dev/agent-creator`).
  Rất giá trị để học cách viết, nhưng LICENSE.md ghi "© Anthropic PBC. All rights reserved"
  ⇒ **không phải mã nguồn mở**, chỉ đọc để học, không sao chép.
- https://github.com/lst97/claude-code-sub-agents (1.7k, MIT) — commit gần nhất 2025-08-15,
  quá 12 tháng ⇒ loại theo tiêu chí.
- https://github.com/contains-studio/agents (12.4k) — trang không hiển thị license rõ ràng ⇒ loại.

### Bài học rút ra (áp dụng cho bộ agent của Nobin)

1. **Một agent = một trách nhiệm.** Các repo lớn có hàng trăm agent chồng chéo
   (ví dụ nhiều agent "reviewer" khác nhau). Nobin cần ít agent hơn nhưng ranh giới rõ.
2. **Review nên chỉ đọc.** Agent review chính thức (`feature-dev/code-reviewer`) không có
   `Edit`/`Write`; dùng thang điểm tin cậy để lọc báo động giả. ⇒ `code-reviewer` và
   `security-reviewer` của Nobin không được sửa code.
3. **Model theo độ khó** (wshobson): suy luận sâu → `opus`; viết code theo stack → `inherit`;
   việc nhanh → `haiku`.
4. **Output có khuôn mẫu cố định** giúp đọc nhanh và so sánh giữa các lần chạy.
5. **Không copy nội dung**: các file agent trong repo này là bài viết mới. Chỉ học cấu trúc.

## 4. Có cần thêm vai trò nào ngoài 18 vai trò Nobin liệt kê?

Đã so với danh mục của VoltAgent (10 nhóm) và wshobson. Các vai trò hay gặp mà danh sách
chưa có: `refactoring-specialist`, `accessibility-tester`, `api-designer`, `architect-reviewer`.
- Refactor: đã nằm trong các agent theo stack (angular-expert…) và `performance-optimizer`.
- Accessibility (a11y): có thể là một phần của `angular-expert` (PrimeNG có hỗ trợ a11y).
- API design: nằm trong `java-spring-backend` / `csharp-dotnet`.

**Kết luận:** không thêm agent mới. Chưa có bằng chứng rõ ràng về nhu cầu; thêm agent chỉ làm
tăng chồng chéo. Ghi vào "Ideas for later": `accessibility-reviewer` nếu team cần audit WCAG.

## 5. Phiên bản công nghệ dùng trong các agent (checked 2026-09-28)

Lấy bằng `npm view` và Maven Central / dotnet/core trên GitHub:

| Công nghệ | Phiên bản mới nhất | Nguồn |
|---|---|---|
| Angular (`@angular/core`) | 22.2.0 | `npm view @angular/core version` |
| PrimeNG | 22.1.1 | `npm view primeng version` |
| React Native | 0.87.1 | `npm view react-native version` |
| Expo | 57.0.25 | `npm view expo version` |
| Spring Boot (GA) | 4.1.1 | https://repo1.maven.org/maven2/org/springframework/boot/spring-boot/maven-metadata.xml |
| .NET LTS | 10.0 (10.0.12, SDK 10.0.401, hết hỗ trợ 2028-11-14) | https://raw.githubusercontent.com/dotnet/core/main/release-notes/releases-index.json |

Các agent **không cứng hoá** phiên bản: chúng được dặn đọc `package.json` / `pom.xml` /
`*.csproj` của dự án trước, vì dự án thật có thể dùng bản cũ hơn.

## Nguồn tham khảo (Sources)

- https://code.claude.com/docs/en/sub-agents
- https://code.claude.com/docs/en/tools-reference
- https://github.com/wshobson/agents
- https://github.com/wshobson/agents/commits/main
- https://github.com/VoltAgent/awesome-claude-code-subagents
- https://github.com/VoltAgent/awesome-claude-code-subagents/commits/main
- https://github.com/anthropics/claude-plugins-official
- https://github.com/anthropics/claude-plugins-official/commits/main
- https://github.com/davepoon/buildwithclaude
- https://github.com/davepoon/buildwithclaude/commits/main
- https://github.com/0xfurai/claude-code-subagents
- https://github.com/0xfurai/claude-code-subagents/commits/main
- https://github.com/lst97/claude-code-sub-agents
- https://github.com/contains-studio/agents
- https://github.com/anthropics/claude-code/tree/main/plugins
- https://raw.githubusercontent.com/anthropics/claude-code/HEAD/LICENSE.md
- https://raw.githubusercontent.com/anthropics/claude-code/HEAD/plugins/plugin-dev/agents/agent-creator.md
- https://raw.githubusercontent.com/anthropics/claude-plugins-official/HEAD/plugins/feature-dev/agents/code-reviewer.md
- https://repo1.maven.org/maven2/org/springframework/boot/spring-boot/maven-metadata.xml
- https://raw.githubusercontent.com/dotnet/core/main/release-notes/releases-index.json
