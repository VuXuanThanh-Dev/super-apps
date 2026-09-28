# Task 1 — PLAN: AI agents cho công việc IT hằng ngày

Branch: `task-1-agents` · Thư mục: `.claude/agents/` (CHỈ file agent) và `docs/agents/` (mọi file khác).

## Mục tiêu

Tạo một bộ subagent Claude Code đã được kiểm thử, phục vụ công việc hằng ngày của Nobin:
lead team Angular, review code, đọc SRS, ước lượng, mentor intern, làm việc với nhiều
remote GitLab, và học Java Spring, C#/.NET, React Native, tiếng Anh.

## Mục lục (các file sẽ tạo)

| File | Nội dung |
|---|---|
| `docs/agents/PLAN.md` | File này: mục tiêu, milestone, thiết kế, DoD |
| `docs/agents/PROGRESS.md` | Done / Next / Blockers / Decisions |
| `docs/agents/RESEARCH.md` | Định dạng chính thức + so sánh 5 repo |
| `.claude/agents/*.md` | 18 file agent |
| `docs/agents/samples/` | Mẫu nhỏ để test (SRS, diff, code lỗi…) |
| `docs/agents/TESTING.md` | 1 test / agent: prompt, kết quả, pass/fail |
| `docs/agents/README.md` | Bảng tổng hợp + hướng dẫn chọn agent |
| `docs/agents/scripts/validate-agents.py` | Script kiểm tra frontmatter |

## Milestones

- **M1 — Research** → `RESEARCH.md` (định dạng, tool, model, description; bảng 5 repo).
- **M2 — Design** → bảng thiết kế bên dưới (1 trách nhiệm, khi dùng / không dùng, tool tối thiểu, model, output).
- **M3 — Agent files** → 18 file trong `.claude/agents/` + script kiểm tra frontmatter.
- **M4 — Testing** → `TESTING.md`, 1 test / agent trên mẫu nhỏ thực tế.
- **M5 — README** → bảng đầy đủ + "cách chọn đúng agent".

## M2 — Thiết kế (Design)

Nguyên tắc:
1. Một agent = một trách nhiệm. Cột "Không dùng khi" chỉ rõ agent nào thay thế ⇒ không chồng chéo.
2. Quyền tối thiểu: agent chỉ đọc dùng `Read, Grep, Glob` (không `Bash`). Chỉ agent cần chạy lệnh mới có `Bash`. Chỉ agent tạo/sửa file mới có `Write`/`Edit`. Không agent nào có `Agent` (không sinh agent con).
3. Model: `opus` cho suy luận sâu/rủi ro cao; `sonnet` cho việc thường; `haiku` cho việc nhanh; `inherit` cho agent viết code theo stack (Nobin tự chọn theo phiên).
4. Output có khuôn mẫu cố định; ngôn ngữ trả lời: tiếng Việt (thuật ngữ giữ tiếng Anh), trừ khi người dùng viết tiếng Anh hoặc sản phẩm cần tiếng Anh.

| Agent | Một trách nhiệm | Dùng khi | KHÔNG dùng khi (dùng agent khác) | Tools | Model | Output |
|---|---|---|---|---|---|---|
| code-reviewer | Gác cổng chất lượng cho một diff/PR/MR | Trước khi merge; "review MR này" | Chỉ về bảo mật → security-reviewer; chỉ hiệu năng → performance-optimizer; review cho intern (giọng dạy học) → intern-mentor; muốn sửa code → agent theo stack | Read, Grep, Glob, Bash | opus | Verdict (Approve/Request changes) + bảng findings (mức độ, file:dòng, vấn đề, cách sửa) |
| angular-expert | Viết/refactor/tư vấn code Angular (Signals, standalone, control flow mới, PrimeNG) | Tạo component, chuyển sang Signals, lỗi template | Review PR → code-reviewer; RN → react-native-mobile | Read, Write, Edit, Grep, Glob, Bash, WebFetch | inherit | Kế hoạch ngắn → code → lệnh kiểm tra đã chạy + kết quả |
| java-spring-backend | Viết/tư vấn backend Java Spring Boot | REST API, JPA, Spring Security config, test | Thiết kế schema → database-designer; review → code-reviewer | Read, Write, Edit, Grep, Glob, Bash, WebFetch | inherit | Như trên |
| csharp-dotnet | Viết/tư vấn C#/.NET (ASP.NET Core, EF Core) | Web API, LINQ, async, xUnit | Thiết kế schema → database-designer; review → code-reviewer | Read, Write, Edit, Grep, Glob, Bash, WebFetch | inherit | Như trên |
| react-native-mobile | Viết/tư vấn app React Native/Expo | Màn hình, navigation, Expo module, lỗi Metro | Angular web → angular-expert; pipeline build app → devops-ci | Read, Write, Edit, Grep, Glob, Bash, WebFetch | inherit | Như trên |
| database-designer | Thiết kế schema, index, truy vấn từ nhu cầu nghiệp vụ | "Thiết kế bảng cho module đặt phòng", query chậm cần index | Viết code ORM/repository → agent theo stack; đo hiệu năng app → performance-optimizer | Read, Write, Grep, Glob | opus | Entity list → ERD (Mermaid) → DDL → index + lý do → truy vấn mẫu → câu hỏi mở |
| ba-requirements-challenger | Đọc SRS và đặt câu hỏi khó | Nhận SRS mới từ BA, trước khi estimate | Viết test case → test-case-writer; chia task/ước lượng → estimation-and-planning | Read, Grep, Glob | opus | Câu hỏi theo nhóm (thiếu case, mâu thuẫn, luật mơ hồ, NFR) kèm trích dẫn mục SRS + mức ưu tiên |
| test-case-writer | Viết test case QA từ SRS/user story | "Viết test case cho US-12" | Tìm lỗ hổng yêu cầu → ba-requirements-challenger; unit test code → agent theo stack | Read, Grep, Glob, Write | sonnet | Bảng test case (ID, tiêu đề, tiền điều kiện, bước, dữ liệu, kết quả mong đợi, loại, ưu tiên, truy vết yêu cầu) |
| security-reviewer | Soi lỗ hổng bảo mật (OWASP, secrets, dependency) | Trước release, code auth/upload/thanh toán | Chất lượng chung → code-reviewer; sửa lỗi → agent theo stack | Read, Grep, Glob, Bash | opus | Bảng findings (CWE/OWASP, mức độ, bằng chứng file:dòng, kịch bản khai thác, cách sửa) |
| debugger | Tìm nguyên nhân gốc của MỘT lỗi cụ thể và sửa tối thiểu | Stack trace, test fail, "tại sao X null" | Chậm nhưng đúng → performance-optimizer; lỗi pipeline → devops-ci; lỗi git → git-helper | Read, Edit, Write, Grep, Glob, Bash | sonnet | Triệu chứng → tái hiện → giả thuyết → nguyên nhân gốc → fix → bằng chứng đã chạy |
| performance-optimizer | Đo và cải thiện hiệu năng (có số liệu trước/sau) | Trang chậm, bundle to, API chậm, rò rỉ bộ nhớ | Lỗi sai kết quả → debugger; thiết kế index từ đầu → database-designer | Read, Edit, Write, Grep, Glob, Bash | sonnet | Baseline → điểm nghẽn → thay đổi → số liệu sau → đánh đổi |
| git-helper | Thao tác git: branch, merge/rebase, conflict, nhiều GitLab remote | "Gộp conflict", "push lên 2 remote", cứu commit | Viết commit/PR message → pr-and-commit-writer; pipeline CI → devops-ci | Read, Edit, Bash | haiku | Tình trạng repo → lệnh từng bước (có giải thích) → kết quả → cách hoàn tác |
| devops-ci | Pipeline CI/CD (GitLab CI, GitHub Actions) và Docker | Viết `.gitlab-ci.yml`, Dockerfile, sửa job fail | Lỗi code ứng dụng → debugger; lệnh git → git-helper | Read, Write, Edit, Grep, Glob, Bash, WebFetch | sonnet | File cấu hình + giải thích từng stage + cách kiểm tra đã chạy |
| docs-writer | Viết tài liệu kỹ thuật song ngữ Việt/Anh | README, hướng dẫn cài đặt, ADR, wiki | Commit/PR text → pr-and-commit-writer; luyện tiếng Anh → english-coach | Read, Write, Edit, Grep, Glob | sonnet | File Markdown: song ngữ theo khối, mục lục, ví dụ đã kiểm tra |
| pr-and-commit-writer | Viết commit message, mô tả PR/MR, changelog từ diff | "Viết commit cho thay đổi này", "mô tả MR" | Thao tác git → git-helper; review → code-reviewer | Read, Grep, Glob, Bash | haiku | Commit (Conventional Commits) + mô tả PR theo template |
| estimation-and-planning | Chia task và ước lượng effort | Sau khi SRS rõ; lập kế hoạch sprint | Câu hỏi về SRS → ba-requirements-challenger; test case → test-case-writer | Read, Grep, Glob | sonnet | WBS (bảng task) + ước lượng 3 điểm (O/M/P) + giả định + rủi ro + thứ tự làm |
| intern-mentor | Giải thích code cho junior, góp ý review nhẹ nhàng mang tính dạy học | Intern hỏi "đoạn này làm gì?", viết lại review cho dễ nghe | Gác cổng merge → code-reviewer; tự viết code thay intern → agent theo stack | Read, Grep, Glob | sonnet | Ý tưởng đơn giản → ví dụ → chi tiết; góp ý theo mẫu khen–gợi ý–câu hỏi; 1 bài tập nhỏ |
| english-coach | Luyện tiếng Anh công việc qua roleplay | "Roleplay daily standup", "luyện họp với khách" | Viết tài liệu song ngữ → docs-writer; viết PR tiếng Anh → pr-and-commit-writer | Read | sonnet | Cảnh roleplay → (hết cảnh) bảng sửa lỗi + câu hay hơn + từ vựng |

Kiểm tra chồng chéo: mỗi cặp agent gần nhau đều có dòng "KHÔNG dùng khi" trỏ sang nhau
(code-reviewer ↔ security-reviewer ↔ performance-optimizer ↔ intern-mentor;
ba-requirements-challenger ↔ test-case-writer ↔ estimation-and-planning;
git-helper ↔ pr-and-commit-writer ↔ devops-ci; docs-writer ↔ english-coach ↔ pr-and-commit-writer;
database-designer ↔ agent theo stack; debugger ↔ performance-optimizer).

## Definition of Done (copy từ task)

- [ ] RESEARCH.md with comparison table
- [ ] One valid agent file per role; frontmatter matches the official format
- [ ] Least-privilege tools; no overlapping responsibilities
- [ ] Only agent files inside .claude/agents/
- [ ] TESTING.md: one test per agent (real or labelled "simulated")
- [ ] README.md with the full table
