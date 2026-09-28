# Bộ subagent Claude Code cho công việc IT hằng ngày

18 subagent (tác tử con) nằm trong `.claude/agents/`. Mỗi agent làm **một việc**, chỉ có
**quyền tối thiểu** (least privilege) cần cho việc đó.

## Ý tưởng đơn giản

Bạn cứ nói việc cần làm. Claude đọc `description` của các agent và tự giao việc cho agent phù hợp.
Muốn chắc chắn dùng một agent, hãy gọi tên nó:

```text
Use the code-reviewer subagent to review this branch
@agent-code-reviewer review MR !42
```

Chạy cả phiên với một agent làm "agent chính": `claude --agent english-coach`.

> Lưu ý: nếu thư mục `.claude/agents/` chưa có lúc bạn mở phiên, hãy **khởi động lại phiên** một lần
> để Claude Code thấy các agent (theo docs chính thức, checked 2026-09-28).

## Bảng agent

| Agent | Dùng khi | Tools | Model | Prompt ví dụ |
|---|---|---|---|---|
| `code-reviewer` | Review diff/PR/MR trước khi merge; gác cổng chất lượng, chỉ đọc | Read, Grep, Glob, Bash | opus | "Review MR này trước khi tôi merge vào develop. Strict nhé." |
| `angular-expert` | Viết/refactor Angular: Signals, standalone, `@if/@for/@defer`, PrimeNG | Read, Write, Edit, Grep, Glob, Bash, WebFetch | inherit | "Chuyển component này sang signals và control flow mới." |
| `java-spring-backend` | Backend Java Spring Boot: REST, JPA, validation, security, test | Read, Write, Edit, Grep, Glob, Bash, WebFetch | inherit | "Tại sao @Transactional của tôi không rollback?" |
| `csharp-dotnet` | C#/.NET: ASP.NET Core, EF Core, LINQ, async, xUnit | Read, Write, Edit, Grep, Glob, Bash, WebFetch | inherit | "Tạo minimal API cho Product với EF Core + test." |
| `react-native-mobile` | App React Native/Expo: màn hình, expo-router, lỗi Expo Go | Read, Write, Edit, Grep, Glob, Bash, WebFetch | inherit | "Danh sách 2000 contact bị lag, sửa giúp." |
| `database-designer` | Từ nghiệp vụ → schema, ràng buộc, index, truy vấn mẫu | Read, Write, Grep, Glob | opus | "Thiết kế DB cho module đặt phòng họp." |
| `ba-requirements-challenger` | Đọc SRS, đặt câu hỏi khó: thiếu case, mâu thuẫn, mơ hồ, NFR | Read, Grep, Glob | opus | "Đọc SRS này và liệt kê câu hỏi gửi BA." |
| `test-case-writer` | Viết test case QA từ SRS/user story | Read, Grep, Glob, Write | sonnet | "Viết test case cho mục 3.1 của SRS." |
| `security-reviewer` | Review bảo mật: OWASP, auth, injection, secrets, dependency | Read, Grep, Glob, Bash | opus | "Kiểm tra bảo mật phần upload file trước release." |
| `debugger` | Tìm nguyên nhân gốc của MỘT lỗi và sửa tối thiểu | Read, Edit, Write, Grep, Glob, Bash | sonnet | "Test này fail với NullPointerException, tìm nguyên nhân." |
| `performance-optimizer` | Đo và tối ưu hiệu năng, có số trước/sau | Read, Edit, Write, Grep, Glob, Bash | sonnet | "Trang danh sách load 5 giây, tối ưu giúp." |
| `git-helper` | Branch, merge/rebase, conflict, nhiều GitLab remote | Read, Edit, Bash | haiku | "Merge develop bị conflict, gỡ giúp." |
| `devops-ci` | GitLab CI / GitHub Actions, Dockerfile, job CI fail | Read, Write, Edit, Grep, Glob, Bash, WebFetch | sonnet | "Viết .gitlab-ci.yml build + test Angular." |
| `docs-writer` | Tài liệu kỹ thuật song ngữ Việt/Anh: README, ADR, hướng dẫn | Read, Write, Edit, Grep, Glob | sonnet | "Viết README song ngữ cho module này." |
| `pr-and-commit-writer` | Commit message, mô tả PR/MR, changelog từ diff (không commit) | Read, Grep, Glob, Bash | haiku | "Viết commit message cho thay đổi đang staged." |
| `estimation-and-planning` | Chia task, ước lượng 3 điểm, rủi ro, thứ tự làm | Read, Grep, Glob | sonnet | "Chia task và ước lượng cho SRS này, team 3 người." |
| `intern-mentor` | Giải thích code cho intern; góp ý review nhẹ nhàng, có bài tập | Read, Grep, Glob | sonnet | "Giải thích đoạn RxJS này cho intern." |
| `english-coach` | Roleplay tiếng Anh công việc; chỉ sửa lỗi khi hết cảnh | Read | sonnet | "Roleplay daily stand-up, bạn là Scrum Master." |

Vì sao model như vậy: `opus` cho việc cần suy luận sâu và sai thì đắt (review, bảo mật, DB, SRS);
`sonnet` cho việc thường; `haiku` cho việc nhanh, lặp lại (git, commit message); `inherit` cho agent
viết code theo stack để bạn tự chọn model theo phiên. Chi tiết: `docs/agents/RESEARCH.md`.

## Cách chọn đúng agent

Hỏi 3 câu theo thứ tự:

**1. Bạn cần *làm ra* thứ gì, hay *đánh giá* thứ đã có?**
- Làm ra code theo stack → `angular-expert` / `java-spring-backend` / `csharp-dotnet` / `react-native-mobile`.
- Làm ra thiết kế DB → `database-designer`. Pipeline/Docker → `devops-ci`.
- Làm ra chữ: tài liệu → `docs-writer`; commit/PR → `pr-and-commit-writer`; test case → `test-case-writer`;
  kế hoạch/ước lượng → `estimation-and-planning`.
- Đánh giá code → câu 2. Đánh giá yêu cầu (SRS) → `ba-requirements-challenger`.

**2. Đánh giá code: theo góc nhìn nào?**
- Chất lượng tổng thể trước merge → `code-reviewer`.
- Chỉ bảo mật → `security-reviewer`.
- Chỉ tốc độ/bộ nhớ → `performance-optimizer`.
- Để dạy người mới → `intern-mentor`.

**3. Có sự cố?**
- Một lỗi cụ thể (exception, test fail, kết quả sai) → `debugger`.
- Chạy đúng nhưng chậm → `performance-optimizer`.
- Job CI/Docker fail → `devops-ci`. Rối git/conflict/remote → `git-helper`.

Luyện tiếng Anh → `english-coach` (không phải `docs-writer`).

### Quy trình gợi ý với SRS mới

```text
SRS từ BA → ba-requirements-challenger (câu hỏi) → BA trả lời
          → estimation-and-planning (task + ước lượng)
          → test-case-writer (test case)
          → database-designer / agent theo stack (làm)
          → code-reviewer + security-reviewer (trước merge)
          → pr-and-commit-writer (mô tả MR)
```

## Kiểm tra và test

```bash
python3 docs/agents/scripts/validate-agents.py     # kiểm tra frontmatter + quy tắc quyền tối thiểu
claude plugin validate .claude/agents/             # validator chính thức (khá dễ tính)
python3 docs/agents/scripts/run_agent_tests.py     # 18 test thật bằng `claude -p` (tốn token)
```

Kết quả test: `docs/agents/TESTING.md` và `docs/agents/test-results/`.

## Tuỳ chỉnh

- Đổi model: sửa dòng `model:` (ví dụ `sonnet` để tiết kiệm).
- Thêm quyền: thêm tool vào `tools:`. Hãy chạy lại `validate-agents.py`; script sẽ báo lỗi nếu agent chỉ đọc
  bị cấp quyền ghi.
- Muốn agent dùng cho mọi dự án: copy file vào `~/.claude/agents/`.

## Nguồn tham khảo (Sources)

- https://code.claude.com/docs/en/sub-agents
- https://code.claude.com/docs/en/tools-reference
- https://github.com/wshobson/agents
- https://github.com/VoltAgent/awesome-claude-code-subagents
