# IDEAS — Công cụ và ý tưởng cho Nobin

> Tài liệu này chỉ **đề xuất**. Không có gì được cài vào repo.
> Mọi số liệu (stars, last commit, license, giá) ghi "(checked 2026-09-28)".
> Link nào không mở được trong sandbox thì ghi **UNVERIFIED**.

## Cách đọc và cách chấm điểm

- **Value (1–5)**: giúp Nobin nhiều cỡ nào (công việc Angular → Java/C#, OCP, TOEIC, React Native, data engineering).
- **Effort (1–5)**: tốn bao nhiêu thời gian để bắt đầu dùng được. 1 = dưới 1 giờ, 3 = vài buổi tối, 5 = nhiều tháng.
- **Effort S/M/L**: S = Effort 1–2, M = Effort 3, L = Effort 4–5.
- **Ratio = Value ÷ Effort**. Mỗi phần được sắp xếp theo Ratio giảm dần. Nếu Ratio bằng nhau, mục có Value cao hơn đứng trước.
- **Maturity** (độ trưởng thành): với repo GitHub, ghi stars, ngày commit gần nhất (pushed_at) và license.
  "Reputable" theo rule của Nobin = commit trong 12 tháng + license rõ ràng + nhiều người dùng.

---

## Top 10 nên làm trước

Chọn theo Ratio cao, Value ≥ 4, và phủ đều 4 phần (việc học + repo).

| # | Việc | Phần | Value | Effort | Ratio | Vì sao làm trước |
|---|------|------|-------|--------|-------|------------------|
| 1 | Link check bằng lychee trong CI | 2 | 5 | 1 | 5.00 | Sách có rất nhiều link "Nguồn tham khảo"; link chết làm mất uy tín. Cài 1 file workflow là xong. |
| 2 | Anki + FSRS cho từ vựng TOEIC và bẫy OCP | 3 | 5 | 1 | 5.00 | Học 15–20 phút/ngày, hợp người làm full-time. |
| 3 | Luyện "đọc code, đoán output" với jshell / JBang | 3 | 5 | 1 | 5.00 | Đề OCP chủ yếu là đọc code và đoán kết quả. Công cụ có sẵn trong JDK. |
| 4 | Context7 MCP cho Claude Code | 1 | 4 | 1 | 4.00 | Cho AI đọc docs mới nhất (Spring, Expo, .NET) thay vì dữ liệu cũ. |
| 5 | GitHub MCP server | 1 | 4 | 1 | 4.00 | Quản lý PR/issue của repo này từ Claude Code. |
| 6 | typos (spell check tiếng Anh) trong CI | 2 | 4 | 1 | 4.00 | Gần như không báo sai, bắt lỗi gõ trong code và Markdown. |
| 7 | DuckDB để luyện SQL | 3 | 4 | 1 | 4.00 | Nền tảng của data engineering; chạy 1 file, không cần server. |
| 8 | Học word families từ 2 PDF TOEIC có sẵn trong repo | 3 | 4 | 1 | 4.00 | Tài liệu đã có, chỉ cần lịch ôn. |
| 9 | CI test code mẫu cho từng cuốn sách (chỉ chạy khi sách đó thay đổi) | 2 | 5 | 2 | 2.50 | Rule 7 bắt buộc "code mẫu phải chạy". CI giữ điều đó luôn đúng. |
| 10 | Side project: tạo Anki deck từ GLOSSARY.md của 3 cuốn sách | 4 | 5 | 2 | 2.50 | Biến sách mình viết thành flashcard; nối Phần 3 với Phần 4. |

---

## Phần 1 — Developer tools và MCP servers

**MCP (Model Context Protocol)** = giao thức mở để AI (ví dụ Claude Code) gọi công cụ bên ngoài: GitHub, trình duyệt, database...
Trong Claude Code, thêm server bằng `claude mcp add ...`; scope `project` lưu vào `.mcp.json` để chia sẻ qua git
(nguồn: https://code.claude.com/docs/en/mcp, checked 2026-09-28).

### Bảng xếp hạng Phần 1

| # | Công cụ | Value | Effort | Ratio |
|---|---------|-------|--------|-------|
| 1.1 | Context7 MCP | 4 | 1 | 4.00 |
| 1.2 | GitHub MCP server | 4 | 1 | 4.00 |
| 1.3 | JBang | 4 | 1 | 4.00 |
| 1.4 | Playwright MCP | 3 | 1 | 3.00 |
| 1.5 | SDKMAN! | 3 | 1 | 3.00 |
| 1.6 | Bruno (API client) | 3 | 1 | 3.00 |
| 1.7 | DBeaver Community | 3 | 1 | 3.00 |
| 1.8 | CSharpier | 3 | 1 | 3.00 |
| 1.9 | IntelliJ IDEA (bản free) | 5 | 2 | 2.50 |
| 1.10 | MCP reference servers (filesystem, fetch, memory...) | 2 | 1 | 2.00 |
| 1.11 | lazygit | 2 | 1 | 2.00 |
| 1.12 | DuckDB / MotherDuck MCP (local) | 3 | 2 | 1.50 |
| 1.13 | mise (quản lý version Node/Java...) | 3 | 2 | 1.50 |
| 1.14 | mermaid-cli | 3 | 2 | 1.50 |
| 1.15 | Testcontainers for Java | 4 | 3 | 1.33 |

### 1.1 Context7 MCP — V4 · E1 · Ratio 4.00

- **Là gì:** MCP server đưa docs và code example *mới nhất, đúng version* của thư viện vào prompt của AI.
- **Vì sao giúp Nobin:** Nobin học 3 hệ sinh thái mới cùng lúc (Spring/Java, .NET, Expo). AI hay trả lời theo API cũ. Context7 giảm lỗi này. Cũng hữu ích vì nhiều trang docs chính thức bị chặn trong sandbox cloud.
- **Effort:** S (1 lệnh cài).
- **Cost:** Free. README khuyên lấy API key miễn phí để có rate limit cao hơn (checked 2026-09-28).
- **License:** MIT (npm `@upstash/context7-mcp` 4.1.1, checked 2026-09-28).
- **Maturity:** ~62.5k stars, last commit 2026-09-28, MIT. Reputable.
- **Source:** https://github.com/upstash/context7

### 1.2 GitHub MCP server — V4 · E1 · Ratio 4.00

- **Là gì:** MCP server chính thức của GitHub: đọc/sửa issue, PR, file, Actions.
- **Vì sao giúp Nobin:** Repo này được nhiều session AI làm song song. Server này cho Claude Code mở PR, đọc log CI, trả lời review mà không cần `gh`.
  Có bản remote (`https://api.githubcopilot.com/mcp/`) nên không phải cài gì.
- **Effort:** S.
- **Cost:** Free (cần GitHub token / OAuth).
- **License:** MIT.
- **Maturity:** ~33.3k stars, last commit 2026-09-28 (checked 2026-09-28). Reputable.
- **Source:** https://github.com/github/github-mcp-server

### 1.3 JBang — V4 · E1 · Ratio 4.00

- **Là gì:** Chạy 1 file `.java` như script. Khai báo thư viện bằng comment `//DEPS group:artifact:version`, không cần Maven/Gradle.
- **Vì sao giúp Nobin:** Khi học OCP, Nobin cần thử rất nhiều đoạn code nhỏ. JBang bỏ qua bước tạo project. Giống cảm giác `npx` của frontend.
- **Effort:** S.
- **Cost:** Free.
- **License:** MIT.
- **Maturity:** ~1.9k stars, last commit 2026-09-24 (checked 2026-09-28). Nhỏ nhưng active.
- **Source:** https://github.com/jbangdev/jbang

### 1.4 Playwright MCP — V3 · E1 · Ratio 3.00

- **Là gì:** MCP server của Microsoft cho AI điều khiển trình duyệt (dựa trên accessibility tree, không cần screenshot).
- **Vì sao giúp Nobin:** Cho Claude kiểm tra bản HTML của sách trước khi in PDF, hoặc bản web của app TOEIC. Nobin đã quen Playwright từ frontend.
- **Effort:** S (`claude mcp add playwright npx @playwright/mcp@latest` — lệnh trong README).
- **Cost:** Free.
- **License:** Apache-2.0.
- **Maturity:** ~37.7k stars, last commit 2026-09-25; npm `@playwright/mcp` 0.0.82 = vẫn là bản 0.x (checked 2026-09-28).
- **Source:** https://github.com/microsoft/playwright-mcp

### 1.5 SDKMAN! — V3 · E1 · Ratio 3.00

- **Là gì:** Công cụ dòng lệnh để cài và đổi nhiều version JDK (và Maven, Gradle...).
- **Vì sao giúp Nobin:** OCP dùng Java 21, dự án công ty có thể dùng Java 17. Đổi version bằng 1 lệnh.
- **Effort:** S.
- **Cost:** Free.
- **License:** Apache-2.0.
- **Maturity:** ~6.9k stars, last commit 2026-09-27 (checked 2026-09-28).
- **Source:** https://github.com/sdkman/sdkman-cli

### 1.6 Bruno — V3 · E1 · Ratio 3.00

- **Là gì:** API client (giống Postman) lưu collection thành file text trong git.
- **Vì sao giúp Nobin:** Khi làm backend Java/C#, cần gọi thử API. Collection nằm cùng repo nên review được trong PR.
- **Effort:** S.
- **Cost:** App core free. Có gói trả phí — giá **UNVERIFIED** (usebruno.com bị chặn trong sandbox).
- **License:** MIT.
- **Maturity:** ~47.2k stars, last commit 2026-09-28 (checked 2026-09-28).
- **Source:** https://github.com/usebruno/bruno

### 1.7 DBeaver Community — V3 · E1 · Ratio 3.00

- **Là gì:** Công cụ GUI cho database (PostgreSQL, MySQL, SQLite, DuckDB...).
- **Vì sao giúp Nobin:** Backend và data engineering đều cần xem dữ liệu. Một tool cho mọi DB.
- **Effort:** S.
- **Cost:** Community free.
- **License:** Apache-2.0.
- **Maturity:** ~51.9k stars, last commit 2026-09-28 (checked 2026-09-28).
- **Source:** https://github.com/dbeaver/dbeaver

### 1.8 CSharpier — V3 · E1 · Ratio 3.00

- **Là gì:** Formatter "có ý kiến" (opinionated) cho C#, lấy ý tưởng từ Prettier.
- **Vì sao giúp Nobin:** Nobin đã quen Prettier trong Angular. Dùng CSharpier cho cuốn `books/csharp` để code mẫu luôn cùng một style.
- **Effort:** S.
- **Cost:** Free.
- **License:** MIT.
- **Maturity:** ~2.3k stars, last commit 2026-09-26 (checked 2026-09-28).
- **Source:** https://github.com/belav/csharpier

### 1.9 IntelliJ IDEA (bản free) — V5 · E2 · Ratio 2.50

- **Là gì:** IDE Java phổ biến nhất. Từ 2025.3, JetBrains gộp Community và Ultimate thành 1 bản; phần core vẫn free.
- **Vì sao giúp Nobin:** Debugger, refactor và gợi ý code Java tốt nhất. Giúp chuyển từ VS Code/Angular sang Java nhanh hơn.
- **Effort:** S (cài dễ, nhưng cần vài buổi để quen phím tắt).
- **Cost:** Core free, kể cả dùng cho công việc — **UNVERIFIED** (chỉ thấy trong kết quả WebSearch; blog.jetbrains.com và jetbrains.com bị chặn trong sandbox).
- **License:** Mã nguồn `intellij-community` phần lớn là Apache-2.0 (GitHub báo NOASSERTION vì có nhiều license).
- **Maturity:** ~20.6k stars, last commit 2026-09-28 (checked 2026-09-28). Rất trưởng thành.
- **Source:** https://github.com/JetBrains/intellij-community

### 1.10 MCP reference servers — V2 · E1 · Ratio 2.00

- **Là gì:** Bộ server mẫu chính thức của dự án MCP (filesystem, fetch, git, memory...).
- **Vì sao giúp Nobin:** Học cách MCP hoạt động trước khi tự viết server (xem 4.6). Không cần cho công việc hằng ngày.
- **Effort:** S.
- **Cost:** Free.
- **License:** Đang chuyển từ MIT sang Apache-2.0 (docs: CC-BY-4.0), theo file LICENSE (checked 2026-09-28).
- **Maturity:** ~90.6k stars, last commit 2026-09-28. Đây là server *mẫu*, không phải sản phẩm.
- **Source:** https://github.com/modelcontextprotocol/servers

### 1.11 lazygit — V2 · E1 · Ratio 2.00

- **Là gì:** Giao diện git trong terminal (TUI).
- **Vì sao giúp Nobin:** Repo có nhiều branch song song (`task-1-...`, `task-7-...`). Xem, stage từng dòng, rebase dễ hơn.
- **Effort:** S.
- **Cost:** Free.
- **License:** MIT.
- **Maturity:** ~82.7k stars, last commit 2026-09-28 (checked 2026-09-28).
- **Source:** https://github.com/jesseduffield/lazygit

### 1.12 DuckDB / MotherDuck MCP (local) — V3 · E2 · Ratio 1.50

- **Là gì:** MCP server cho AI chạy SQL trên file DuckDB, CSV, Parquet local (hoặc MotherDuck cloud).
- **Vì sao giúp Nobin:** Khi học data engineering (3.10, 4.2), có thể hỏi AI "phân tích file này" và AI tự viết + chạy SQL.
- **Effort:** S–M.
- **Cost:** Server local free. MotherDuck cloud có gói trả phí — **UNVERIFIED**.
- **License:** MIT.
- **Maturity:** ~524 stars, last commit 2026-09-19 (checked 2026-09-28). Nhỏ, do công ty MotherDuck duy trì.
- **Source:** https://github.com/motherduckdb/mcp-server-motherduck

### 1.13 mise — V3 · E2 · Ratio 1.50

- **Là gì:** Một công cụ quản lý version cho nhiều ngôn ngữ (Node, Java, Python...) qua 1 file config trong repo.
- **Vì sao giúp Nobin:** Repo này có Node (Expo), Java và .NET. Một file ghim version cho mọi người/mọi máy. Thay thế cho nvm + SDKMAN.
- **Effort:** S–M (phải học file config).
- **Cost:** Free.
- **License:** MIT.
- **Maturity:** ~34.4k stars, last commit 2026-09-28 (checked 2026-09-28). Hỗ trợ .NET: **UNVERIFIED** (mise.jdx.dev bị chặn).
- **Source:** https://github.com/jdx/mise

### 1.14 mermaid-cli — V3 · E2 · Ratio 1.50

- **Là gì:** CLI `mmdc` render sơ đồ Mermaid thành SVG/PNG/PDF.
- **Vì sao giúp Nobin:** Rule 8 yêu cầu sơ đồ phải hiện trong PDF. Render trước thành SVG thì pipeline pandoc → Chromium đơn giản hơn.
- **Effort:** S–M (cần Chromium; sandbox đã có).
- **Cost:** Free.
- **License:** MIT.
- **Maturity:** ~5.0k stars, last commit 2026-09-28 (checked 2026-09-28).
- **Source:** https://github.com/mermaid-js/mermaid-cli

### 1.15 Testcontainers for Java — V4 · E3 · Ratio 1.33

- **Là gì:** Thư viện chạy database/Kafka thật trong Docker cho integration test (kiểm thử tích hợp).
- **Vì sao giúp Nobin:** Kỹ năng backend Java thực tế mà nhà tuyển dụng thích. Dùng trong side project 4.7.
- **Effort:** M (cần Docker, JUnit, hiểu Spring test).
- **Cost:** Free.
- **License:** MIT.
- **Maturity:** ~8.7k stars, last commit 2026-09-18 (checked 2026-09-28).
- **Source:** https://github.com/testcontainers/testcontainers-java

---

## Phần 2 — Automation cho repo này (GitHub Actions)

Repo `VuXuanThanh-Dev/super-apps` là **public** (checked 2026-09-28). GitHub Actions **free** cho public repo khi dùng
standard GitHub-hosted runner (nguồn: file docs gốc trong repo `github/docs`,
https://github.com/github/docs/blob/main/data/reusables/actions/actions-billing.md, checked 2026-09-28).
Vì vậy mọi job dưới đây có **Cost = Free**, trừ khi ghi khác.

**Không tạo workflow file trong task này.** YAML bên dưới chỉ là **gợi ý (suggestion)**, chưa chạy thử trên GitHub.

### Bảng xếp hạng Phần 2

| # | Automation | Value | Effort | Ratio |
|---|-----------|-------|--------|-------|
| 2.1 | Link check (lychee) | 5 | 1 | 5.00 |
| 2.2 | Spell check tiếng Anh (typos) | 4 | 1 | 4.00 |
| 2.3 | Markdown lint (markdownlint-cli2) | 3 | 1 | 3.00 |
| 2.4 | Dependabot cho Actions + npm | 3 | 1 | 3.00 |
| 2.5 | Test code mẫu từng cuốn sách (paths-filter + setup-java/dotnet/node) | 5 | 2 | 2.50 |
| 2.6 | Spell check tiếng Việt + Anh (cspell + @cspell/dict-vi-vn) | 4 | 2 | 2.00 |
| 2.7 | CI cho app TOEIC (Expo) | 4 | 2 | 2.00 |
| 2.8 | Build PDF + kiểm tra dấu tiếng Việt | 5 | 3 | 1.67 |
| 2.9 | Claude Code GitHub Action | 3 | 2 | 1.50 |
| 2.10 | Git hooks local (lefthook) | 3 | 2 | 1.50 |
| 2.11 | Đăng PDF lên GitHub Release khi tag | 3 | 2 | 1.50 |
| 2.12 | Prose lint (Vale) | 2 | 3 | 0.67 |

### 2.1 Link check với lychee — V5 · E1 · Ratio 5.00

- **Là gì:** lychee là link checker viết bằng Rust, rất nhanh; `lychee-action` chạy nó trong GitHub Actions.
- **Vì sao giúp Nobin:** Rule 4 bắt mọi chương có "Nguồn tham khảo" và phải chạy link checker. CI làm việc này tự động cho mọi PR và chạy định kỳ (link có thể chết sau vài tháng).
- **Effort:** S.
- **Cost:** Free.
- **License:** Apache-2.0 (cả lychee và lychee-action).
- **Maturity:** lychee ~4.0k stars, last commit 2026-09-28; lychee-action ~514 stars, last commit 2026-07-09 (checked 2026-09-28).
- **Source:** https://github.com/lycheeverse/lychee-action · https://github.com/lycheeverse/lychee
- **Gợi ý (suggestion):** chạy khi có PR + mỗi tuần 1 lần; tạo issue khi có link chết (README có mẫu với `peter-evans/create-issue-from-file`).

```yaml
# SUGGESTION ONLY — .github/workflows/links.yml (not created)
on:
  pull_request:
    paths: ['**/*.md']
  schedule:
    - cron: '0 1 * * 1'   # thứ Hai hằng tuần
jobs:
  links:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: lycheeverse/lychee-action@v2
        with:
          args: --no-progress './**/*.md'
```

### 2.2 Spell check tiếng Anh với typos — V4 · E1 · Ratio 4.00

- **Là gì:** Spell checker cho source code. Chỉ báo các lỗi gõ *đã biết* (ví dụ `teh` → `the`), nên rất ít báo sai.
- **Vì sao giúp Nobin:** Code mẫu Java/C#/TS và thuật ngữ tiếng Anh trong sách không bị lỗi gõ. Không cần từ điển riêng. Chữ tiếng Việt không bị báo nhầm vì typos chỉ có danh sách lỗi tiếng Anh.
- **Effort:** S (`uses: crate-ci/typos@v1.50.2` — theo docs của typos).
- **Cost:** Free.
- **License:** Apache-2.0 (theo GitHub).
- **Maturity:** ~4.2k stars, last commit 2026-09-25 (checked 2026-09-28).
- **Source:** https://github.com/crate-ci/typos/blob/master/docs/github-action.md

### 2.3 Markdown lint với markdownlint-cli2 — V3 · E1 · Ratio 3.00

- **Là gì:** Kiểm tra style Markdown (heading, list, code block có ngôn ngữ...).
- **Vì sao giúp Nobin:** Markdown là "source of truth" của 3 cuốn sách. Markdown sạch → pandoc build PDF ít lỗi hơn.
- **Effort:** S (`uses: DavidAnson/markdownlint-cli2-action@v24`; cần 1 file config để tắt vài rule như độ dài dòng).
- **Cost:** Free.
- **License:** MIT.
- **Maturity:** markdownlint-cli2 ~929 stars, last commit 2026-09-25; npm 0.23.3 (checked 2026-09-28).
- **Source:** https://github.com/DavidAnson/markdownlint-cli2-action

### 2.4 Dependabot cho GitHub Actions + npm — V3 · E1 · Ratio 3.00

- **Là gì:** Tính năng có sẵn của GitHub, tự mở PR khi action hoặc package có version mới.
- **Vì sao giúp Nobin:** App TOEIC (npm) và các workflow (`actions/checkout@v5`...) sẽ cũ dần. Dependabot nhắc cập nhật, có cả cảnh báo bảo mật.
- **Effort:** S (1 file `.github/dependabot.yml`).
- **Cost:** Free.
- **License:** Tính năng của GitHub (không phải open source).
- **Maturity:** Tính năng GA lâu năm. Thay thế: Renovate (~22.6k stars, AGPL-3.0, checked 2026-09-28) — mạnh hơn nhưng phức tạp hơn.
- **Source:** https://github.com/github/docs/blob/main/content/code-security/reference/supply-chain-security/dependabot-options-reference.md

### 2.5 Test code mẫu cho từng cuốn sách — V5 · E2 · Ratio 2.50

- **Là gì:** Một workflow có 3 job: `java-ocp` (setup-java, JDK 21), `csharp` (setup-dotnet, .NET 10), `react-native` (Node 22). Mỗi job chạy script "build + run all examples" mà rule 8 đã yêu cầu. `dorny/paths-filter` giúp chỉ chạy job của cuốn sách có thay đổi.
- **Vì sao giúp Nobin:** Rule 7 nói "code mẫu phải compile và chạy". CI bảo đảm điều đó mãi đúng, kể cả khi sửa sách sau 6 tháng.
- **Effort:** S–M (script đã có sẵn trong mỗi sách, chỉ cần gọi).
- **Cost:** Free.
- **License:** MIT (setup-java, setup-dotnet, paths-filter).
- **Maturity:** setup-java ~2.0k stars (last commit 2026-09-25); setup-dotnet ~1.2k (2026-09-28); paths-filter ~3.3k (2026-09-27) (checked 2026-09-28).
- **Source:** https://github.com/dorny/paths-filter · https://github.com/actions/setup-java · https://github.com/actions/setup-dotnet

```yaml
# SUGGESTION ONLY — tên script là giả định, phải khớp script thật trong từng sách
jobs:
  changes:
    runs-on: ubuntu-latest
    outputs:
      java: ${{ steps.f.outputs.java }}
    steps:
      - uses: actions/checkout@v5
      - id: f
        uses: dorny/paths-filter@v3
        with:
          filters: |
            java: ['books/java-ocp/**']
  java-ocp:
    needs: changes
    if: needs.changes.outputs.java == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: actions/setup-java@v5
        with: { distribution: temurin, java-version: '21' }
      - run: ./books/java-ocp/examples/run-all.sh
```

Version `@v3`/`@v5` trong snippet là **UNVERIFIED** — kiểm tra tag mới nhất trước khi dùng.

### 2.6 Spell check tiếng Việt + Anh với cspell — V4 · E2 · Ratio 2.00

- **Là gì:** cspell là spell checker cho code và văn bản; `@cspell/dict-vi-vn` là từ điển tiếng Việt chính thức của cspell.
- **Vì sao giúp Nobin:** Sách viết tiếng Việt, gõ nhanh hay sai dấu. cspell bắt được cả lỗi Anh lẫn Việt trong 1 lần chạy.
- **Kết quả thử thật (trong scratchpad, không phải repo):** cspell 10.3.5 + `@cspell/dict-vi-vn` 3.0.6, config `"language": "en,vi"`.
  File thử có 3 dòng. Output thật:

  ```text
  sample.md:2:32 - Unknown word (Viêt)
  sample.md:3:6 - Unknown word (sentense) fix: (sentence)
  CSpell: Files checked: 1, Issues found: 2 in 1 file.
  ```

  Bắt được "Viêt" (thiếu dấu) và "sentense". **Không** bắt được "mọt" (gõ sai của "một"), vì "mọt" cũng là một từ đúng.
  Kết luận: từ điển kiểm tra *từng âm tiết*, không hiểu ngữ cảnh. Vẫn có ích, nhưng không thay được việc đọc lại.
- **Effort:** S–M (cần file `cspell.json` + danh sách từ riêng: tên người, thuật ngữ).
- **Cost:** Free.
- **License:** MIT (cspell, cspell-action, dict-vi-vn). Repo `cspell-dicts` tổng là GPL-3.0, nhưng thư mục `vi_VN` có LICENSE MIT (checked 2026-09-28).
- **Maturity:** cspell ~1.7k stars, last commit 2026-09-28, npm 10.3.5; dict-vi-vn cập nhật npm gần nhất 2025-07-19; cspell-action ~117 stars (checked 2026-09-28).
- **Source:** https://github.com/streetsidesoftware/cspell-dicts/tree/main/dictionaries/vi_VN · https://github.com/streetsidesoftware/cspell-action

```json
// SUGGESTION ONLY — cspell.json
{ "version": "0.2", "language": "en,vi",
  "import": ["@cspell/dict-vi-vn/cspell-ext.json"],
  "ignorePaths": ["dist/**", "node_modules/**"] }
```

### 2.7 CI cho app TOEIC (Expo) — V4 · E2 · Ratio 2.00

- **Là gì:** Job chạy `npm ci`, `tsc --noEmit`, lint và test cho `apps/toeic`. Tùy chọn: `expo/expo-github-action` để build preview qua EAS.
- **Vì sao giúp Nobin:** Học React Native cần phản hồi nhanh khi làm hỏng type hoặc test.
- **Effort:** S–M.
- **Cost:** Job CI free. EAS Build có gói free giới hạn và gói trả phí — **UNVERIFIED** (docs.expo.dev bị chặn).
- **License:** MIT (expo-github-action).
- **Maturity:** expo-github-action ~1.0k stars, last commit 2026-06-02 (checked 2026-09-28).
- **Source:** https://github.com/expo/expo-github-action

### 2.8 Build PDF + kiểm tra dấu tiếng Việt — V5 · E3 · Ratio 1.67

- **Là gì:** Job cài pandoc + font Noto, chạy script build (pandoc → HTML → Playwright Chromium `page.pdf()`), sau đó chạy `pdftotext` và `grep` chuỗi "ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ". Upload PDF bằng `actions/upload-artifact`.
- **Vì sao giúp Nobin:** Rule 8 yêu cầu kiểm tra dấu trong PDF. CI làm việc này tự động; Nobin tải PDF từ tab Actions để đọc trên điện thoại.
- **Effort:** M (phải cài font và Chromium trên runner; PDF build tốn vài phút).
- **Cost:** Free.
- **License:** pandoc GPL-2.0 (chỉ dùng như tool, không ảnh hưởng license sách); upload-artifact MIT.
- **Maturity:** pandoc ~46.4k stars, last commit 2026-09-28; upload-artifact ~4.2k stars, last commit 2026-04-14 (checked 2026-09-28).
- **Source:** https://github.com/jgm/pandoc · https://github.com/actions/upload-artifact

### 2.9 Claude Code GitHub Action — V3 · E2 · Ratio 1.50

- **Là gì:** Action chính thức cho phép gọi Claude trong PR/issue bằng `@claude`, hoặc chạy prompt tự động (ví dụ review PR).
- **Vì sao giúp Nobin:** Repo có nhiều PR do AI tạo. Một bước review tự động (kiểm tra link, rule "không bịa số liệu") giúp Nobin đỡ đọc.
  Cài nhanh bằng lệnh `/install-github-app` trong Claude Code (theo README).
- **Effort:** S–M.
- **Cost:** Action free, nhưng tốn phí API/subscription theo lượng dùng — **UNVERIFIED** (không mở được trang giá).
- **License:** MIT.
- **Maturity:** ~9.2k stars, last commit 2026-09-25 (checked 2026-09-28).
- **Source:** https://github.com/anthropics/claude-code-action

### 2.10 Git hooks local với lefthook — V3 · E2 · Ratio 1.50

- **Là gì:** Chạy lệnh (typos, cspell, markdownlint) ngay trước khi `git commit`.
- **Vì sao giúp Nobin:** Bắt lỗi trên máy trước khi CI báo đỏ. Nhanh hơn chờ CI.
- **Effort:** S–M.
- **Cost:** Free.
- **License:** MIT.
- **Maturity:** ~8.9k stars, last commit 2026-09-28. Thay thế: pre-commit (~15.6k stars, MIT, last commit 2026-08-17) (checked 2026-09-28).
- **Source:** https://github.com/evilmartians/lefthook

### 2.11 Đăng PDF lên GitHub Release khi tag — V3 · E2 · Ratio 1.50

- **Là gì:** Khi push tag như `java-ocp-v1.0`, workflow build PDF và đính kèm vào GitHub Release.
- **Vì sao giúp Nobin:** Có link tải cố định cho từng bản sách để chia sẻ (portfolio). Artifact của Actions sẽ hết hạn; Release thì không.
- **Effort:** S–M (dùng lại job 2.8).
- **Cost:** Free.
- **License:** MIT.
- **Maturity:** ~5.8k stars, last commit 2026-09-26 (checked 2026-09-28).
- **Source:** https://github.com/softprops/action-gh-release

### 2.12 Prose lint với Vale — V2 · E3 · Ratio 0.67

- **Là gì:** Linter cho văn bản (câu quá dài, từ bị cấm, style guide).
- **Vì sao giúp Nobin:** Có thể dùng cho README tiếng Anh. Với tiếng Việt, phải tự viết rule; hỗ trợ tiếng Việt: **UNVERIFIED**. Giá trị thấp với repo này.
- **Effort:** M.
- **Cost:** Free.
- **License:** MIT.
- **Maturity:** ~6.2k stars, last commit 2026-09-25 (repo đã chuyển sang `vale-cli/vale`, checked 2026-09-28).
- **Source:** https://github.com/vale-cli/vale

---

## Phần 3 — Công cụ và phương pháp học (OCP, TOEIC, data engineering)

### Bảng xếp hạng Phần 3

| # | Công cụ / phương pháp | Value | Effort | Ratio |
|---|----------------------|-------|--------|-------|
| 3.1 | Anki + FSRS (spaced repetition) | 5 | 1 | 5.00 |
| 3.2 | "Đọc code, đoán output" với jshell / JBang | 5 | 1 | 5.00 |
| 3.3 | DuckDB để luyện SQL | 4 | 1 | 4.00 |
| 3.4 | Word families từ 2 PDF TOEIC trong repo | 4 | 1 | 4.00 |
| 3.5 | Dev.java content (bài học Java chính thức) | 3 | 1 | 3.00 |
| 3.6 | Sách OCP Java SE 21 Study Guide (Boyarsky & Selikoff) | 5 | 2 | 2.50 |
| 3.7 | Thi thử TOEIC có bấm giờ bằng tài liệu chính thức ETS | 5 | 2 | 2.50 |
| 3.8 | Học C# qua repo dotnet/docs | 4 | 2 | 2.00 |
| 3.9 | Thi thử OCP có bấm giờ (mock exam) | 4 | 2 | 2.00 |
| 3.10 | Data Engineering Zoomcamp (free, 9 tuần) | 5 | 4 | 1.25 |
| 3.11 | Thạc sĩ online giá thấp (ví dụ Georgia Tech OMSCS) | 4 | 5 | 0.80 |

### 3.1 Anki + FSRS — V5 · E1 · Ratio 5.00

- **Là gì:** Anki là app flashcard dùng spaced repetition (lặp lại ngắt quãng: ôn đúng lúc sắp quên). FSRS là thuật toán lập lịch mới, có sẵn trong Anki (bật trong Deck Options).
- **Vì sao giúp Nobin:** Ít thời gian → cần học ít mà nhớ lâu. Dùng cho: từ vựng TOEIC, bẫy OCP (ví dụ "switch pattern có cần default không?"), lệnh SQL.
  Anki import được file CSV/TSV UTF-8 (theo manual), nên dễ tạo thẻ tự động (xem 4.1).
- **Effort:** S.
- **Cost:** Desktop free; AnkiDroid free. AnkiMobile (iOS) có phí — giá **UNVERIFIED** (apps.ankiweb.net bị chặn).
- **License:** Anki desktop AGPL-3.0-or-later (file LICENSE); AnkiDroid GPL-3.0; fsrs4anki MIT (checked 2026-09-28).
- **Maturity:** anki ~31.6k stars, last commit 2026-09-28; AnkiDroid ~11.9k stars; fsrs4anki ~4.1k stars, last commit 2026-08-14 (checked 2026-09-28).
- **Source:** https://github.com/ankitects/anki · https://github.com/ankitects/anki-manual/blob/main/src/deck-options.md · https://github.com/open-spaced-repetition/fsrs4anki

### 3.2 "Đọc code, đoán output" với jshell / JBang — V5 · E1 · Ratio 5.00

- **Là gì:** Phương pháp: mỗi ngày 10 đoạn code ngắn. (1) Đọc và viết ra output dự đoán. (2) Chạy bằng `jshell` (có sẵn trong JDK 21) hoặc JBang. (3) Sai thì tạo 1 thẻ Anki.
- **Vì sao giúp Nobin:** Đề OCP chủ yếu là đọc code và tìm lỗi compile/runtime. Luyện "compiler trong đầu" là kỹ năng chính. Không tốn tiền, làm được trong giờ nghỉ trưa.
- **Effort:** S.
- **Cost:** Free.
- **License:** jshell là một module của OpenJDK (GPL-2.0 with Classpath Exception); JBang MIT.
- **Maturity:** jshell có trong JDK từ Java 9 và nằm trong source `openjdk/jdk` (module `jdk.jshell`) (checked 2026-09-28).
- **Source:** https://github.com/openjdk/jdk/tree/master/src/jdk.jshell · https://github.com/jbangdev/jbang

### 3.3 DuckDB để luyện SQL — V4 · E1 · Ratio 4.00

- **Là gì:** Database phân tích (OLAP) chạy trong 1 file, đọc trực tiếp CSV/Parquet.
- **Vì sao giúp Nobin:** SQL là kỹ năng số 1 của data engineer. DuckDB không cần cài server, chạy cả trong Node/Python/Java (JDBC).
  Luyện window function, CTE trên dữ liệu thật (ví dụ lịch sử học Anki, xem 4.2).
- **Effort:** S.
- **Cost:** Free.
- **License:** MIT.
- **Maturity:** ~41.8k stars, last commit 2026-09-28 (checked 2026-09-28). Reputable.
- **Source:** https://github.com/duckdb/duckdb

### 3.4 Word families từ 2 PDF TOEIC trong repo — V4 · E1 · Ratio 4.00

- **Là gì:** Repo đã có `TOEIC-900-Word-Families-Collocations-Tap1.pdf` và `Tap2.pdf`. Phương pháp: mỗi ngày 1 nhóm word family (noun/verb/adj/adv) + 1 collocation, nhập vào Anki, ôn bằng FSRS.
- **Vì sao giúp Nobin:** Part 5–6 của TOEIC hỏi nhiều về dạng từ (word form). Tài liệu đã có, không mất thời gian tìm.
- **Effort:** S.
- **Cost:** Free (tài liệu có sẵn).
- **License:** **UNVERIFIED** — không rõ nguồn gốc/bản quyền của 2 PDF này. Nếu là tài liệu có bản quyền, chỉ dùng cá nhân, không đưa nội dung vào app công khai.
- **Maturity:** Tài liệu tĩnh.
- **Source:** https://github.com/VuXuanThanh-Dev/super-apps/blob/main/TOEIC-900-Word-Families-Collocations-Tap1.pdf

### 3.5 Dev.java content — V3 · E1 · Ratio 3.00

- **Là gì:** Nội dung của Dev.java — "trang web chính thức của nền tảng Java", do Java Platform Group ở Oracle duy trì (theo README).
- **Vì sao giúp Nobin:** Bài học miễn phí về tính năng Java mới (records, sealed classes, pattern matching) — đúng các chủ đề OCP 21. Đọc được trên GitHub khi dev.java bị chặn.
- **Effort:** S.
- **Cost:** Free.
- **License:** GitHub không nhận diện license (README có mục "Content License") — **UNVERIFIED**.
- **Maturity:** ~84 stars, last commit 2026-05-16 (checked 2026-09-28). Ít stars nhưng là nguồn chính thức.
- **Source:** https://github.com/java/devjava-content

### 3.6 Sách OCP Java SE 21 Developer Study Guide — V5 · E2 · Ratio 2.50

- **Là gì:** Sách luyện thi 1Z0-830 của Jeanne Boyarsky & Scott Selikoff (Sybex/Wiley). Theo kết quả tìm kiếm: 14 chương, có online test bank với 3 bài thi thử và hơn 500 flashcard.
- **Vì sao giúp Nobin:** Bộ sách này bám sát đề và được cộng đồng dùng nhiều. Dùng song song với cuốn `books/java-ocp` mình tự viết.
- **Effort:** S để bắt đầu (đọc hết thì L).
- **Cost:** Sách trả phí — giá **UNVERIFIED**. Chỉ đưa link, không copy nội dung (rule 5).
- **License:** Sách có bản quyền (không phải open license).
- **Maturity:** Bản cho Java 21. Thông tin sách **UNVERIFIED**: wiley.com, oreilly.com, selikoff.net đều bị chặn; chỉ thấy qua WebSearch.
- **Source (UNVERIFIED, link từ WebSearch):** https://www.wiley.com/en-us/OCP+Oracle+Certified+Professional+Java+SE+21+Developer+Study+Guide-p-9781394286621

### 3.7 Thi thử TOEIC có bấm giờ bằng tài liệu chính thức ETS — V5 · E2 · Ratio 2.50

- **Là gì:** Mỗi 2 tuần làm 1 bài full test, bấm giờ đúng như thi thật. Theo kết quả tìm kiếm: TOEIC Listening & Reading có 200 câu trong khoảng 2 giờ (Listening ~45 phút, Reading 75 phút), thang điểm 10–990.
- **Vì sao giúp Nobin:** TOEIC 600 → cao hơn cần tốc độ đọc Part 7. Chỉ làm test đúng thời gian mới đo được tiến bộ.
- **Effort:** S (mỗi lần ~2 giờ).
- **Cost:** Sách/đề chính thức ETS có phí — **UNVERIFIED**.
- **License:** Tài liệu có bản quyền của ETS. Không dùng đề leak (rule 5).
- **Maturity:** Định dạng đề: **UNVERIFIED** (ets.org và etsglobal.org bị chặn; chỉ thấy qua WebSearch).
- **Source (UNVERIFIED, link từ WebSearch):** https://www.ets.org/toeic/test-takers/about/listening-reading.html

### 3.8 Học C# qua repo dotnet/docs — V4 · E2 · Ratio 2.00

- **Là gì:** Source Markdown của tài liệu .NET/C# chính thức (bản web là learn.microsoft.com).
- **Vì sao giúp Nobin:** Trang learn.microsoft.com bị chặn trong sandbox cloud, nhưng repo này đọc được. Nội dung dùng lại được (CC-BY-4.0) cho cuốn `books/csharp`, nhớ ghi credit.
- **Effort:** S–M.
- **Cost:** Free.
- **License:** CC-BY-4.0 (docs); code mẫu thường MIT.
- **Maturity:** ~4.8k stars, last commit 2026-09-28 (checked 2026-09-28).
- **Source:** https://github.com/dotnet/docs

### 3.9 Thi thử OCP có bấm giờ — V4 · E2 · Ratio 2.00

- **Là gì:** Làm mock exam đúng thời gian thi thật. Theo kết quả tìm kiếm: 1Z0-830 có 50 câu, 120 phút, điểm đậu 68%. Nguồn đề: test bank của sách 3.6 hoặc bộ đề thương mại như Enthuware.
- **Vì sao giúp Nobin:** Nhiều người nói đề 1Z0-830 dài và thiếu thời gian. Luyện tốc độ trước khi đăng ký thi (lệ phí thi cao).
- **Effort:** S–M.
- **Cost:** Enthuware / test bank có phí — **UNVERIFIED**.
- **License:** Thương mại.
- **Maturity:** Thông tin đề thi **UNVERIFIED** (education.oracle.com, mylearn.oracle.com, enthuware.com đều bị chặn).
- **Source (UNVERIFIED, link từ WebSearch):** https://education.oracle.com/java-se-21-developer-professional/pexam_1Z0-830

### 3.10 Data Engineering Zoomcamp — V5 · E4 · Ratio 1.25

- **Là gì:** Khóa học miễn phí 9 tuần của DataTalks.Club: xây một data pipeline end-to-end (Docker, SQL, orchestration, data warehouse, batch, streaming) + final project.
- **Vì sao giúp Nobin:** Cách thử rẻ nhất để biết mình có thích data engineering không, **trước** khi đăng ký thạc sĩ. Final project là bài portfolio.
- **Effort:** L (9 tuần; có thể học theo tốc độ riêng, không cần theo cohort).
- **Cost:** Free.
- **License:** Repo không có file license (GitHub báo "none") — không tự do tái sử dụng nội dung.
- **Maturity:** ~45.9k stars, last commit 2026-09-15 (checked 2026-09-28).
- **Source:** https://github.com/DataTalksClub/data-engineering-zoomcamp

### 3.11 Thạc sĩ online giá thấp (ví dụ Georgia Tech OMSCS) — V4 · E5 · Ratio 0.80

- **Là gì:** Chương trình Online Master of Science in Computer Science của Georgia Tech, học hoàn toàn online, vừa học vừa đi làm.
  Theo kết quả tìm kiếm: $227 mỗi credit hour (Fall 2026), 30 credit hour, tổng dưới ~$7,000.
- **Vì sao giúp Nobin:** Đúng mục tiêu "có thể học thạc sĩ IT để thành data engineer". Giá thấp hơn nhiều so với du học. Nên làm 3.10 trước để chắc hướng đi.
- **Effort:** L (nhiều năm, 1–2 môn/kỳ).
- **Cost:** Khoảng $7,000 tổng — **UNVERIFIED** (omscs.gatech.edu và bursar.gatech.edu bị chặn).
- **License:** Không áp dụng.
- **Maturity:** Chương trình lâu năm — **UNVERIFIED** trong sandbox.
- **Source (UNVERIFIED, link từ WebSearch):** https://omscs.gatech.edu/cost-and-payment-schedule

---

## Phần 4 — Side project nhỏ (học nhanh hơn + portfolio)

Nguyên tắc chọn: mỗi project **dùng lại thứ đã có trong repo** (sách, app TOEIC, PDF) và luyện đúng stack Nobin đang chuyển sang.

### Bảng xếp hạng Phần 4

| # | Project | Value | Effort | Ratio |
|---|---------|-------|--------|-------|
| 4.1 | Tạo Anki deck từ GLOSSARY.md của 3 cuốn sách | 5 | 2 | 2.50 |
| 4.2 | Pipeline "dữ liệu học tập của tôi" → DuckDB → dashboard | 5 | 3 | 1.67 |
| 4.3 | OCP quiz CLI bằng Java 21 + JUnit | 5 | 3 | 1.67 |
| 4.4 | Dashboard điểm TOEIC bằng Streamlit | 3 | 2 | 1.50 |
| 4.5 | Cùng API đó bằng ASP.NET Core minimal API | 4 | 3 | 1.33 |
| 4.6 | MCP server riêng (Java SDK) cho glossary + quiz | 4 | 3 | 1.33 |
| 4.7 | Spring Boot backend đồng bộ tiến độ cho app TOEIC | 5 | 4 | 1.25 |
| 4.8 | One Billion Row Challenge (1BRC) bằng Java | 3 | 3 | 1.00 |
| 4.9 | Orchestrate pipeline 4.2 bằng Apache Airflow | 3 | 4 | 0.75 |

### 4.1 Tạo Anki deck từ GLOSSARY.md — V5 · E2 · Ratio 2.50

- **Là gì:** Script nhỏ đọc `books/*/GLOSSARY.md` (rule 8 bắt mỗi sách có 1 file) → xuất CSV/TSV UTF-8 → import vào Anki. Muốn đóng gói `.apkg` thì dùng thư viện Python genanki.
- **Vì sao giúp Nobin:** Sách mình viết trở thành flashcard mình học. Thêm từ vựng TOEIC (3.4) theo cùng cách. Là một tool nhỏ, rõ ràng, dễ show.
- **Effort:** S (bản CSV không cần thư viện nào).
- **Cost:** Free.
- **License:** genanki MIT. Anki import text file: theo manual.
- **Maturity:** genanki ~2.7k stars, last commit 2024-12-30 — **hơn 12 tháng không commit**, nên không đạt tiêu chí "reputable"; vì vậy ưu tiên cách CSV (checked 2026-09-28).
- **Source:** https://github.com/ankitects/anki-manual/blob/main/src/importing/text-files.md · https://github.com/kerrickstaley/genanki

### 4.2 Pipeline "dữ liệu học tập của tôi" → DuckDB → dashboard — V5 · E3 · Ratio 1.67

- **Là gì:** Lấy dữ liệu thật của Nobin: lịch sử commit GitHub, số thẻ Anki đã ôn, điểm thi thử TOEIC/OCP (file CSV). Nạp vào DuckDB, làm bảng tổng hợp bằng SQL, hiển thị bằng Evidence (báo cáo viết bằng SQL + Markdown).
- **Vì sao giúp Nobin:** Project data engineering nhỏ nhưng đủ các bước: ingest → transform → serve. Vừa là portfolio, vừa giúp thấy mình có học đều không.
- **Effort:** M.
- **Cost:** Free.
- **License:** DuckDB MIT; Evidence MIT.
- **Maturity:** DuckDB ~41.8k stars; Evidence ~7.0k stars, last commit 2026-09-25 (checked 2026-09-28).
- **Source:** https://github.com/evidence-dev/evidence · https://github.com/duckdb/duckdb

### 4.3 OCP quiz CLI bằng Java 21 + JUnit — V5 · E3 · Ratio 1.67

- **Là gì:** Ứng dụng dòng lệnh hỏi câu hỏi OCP *do mình tự viết* (không dùng đề thật/đề leak). Dùng records, sealed interfaces, pattern matching, `java.time`, streams — đúng các chủ đề OCP. Test bằng JUnit.
- **Vì sao giúp Nobin:** Viết code dùng đúng các tính năng sẽ thi là cách học sâu nhất. Kho câu hỏi có thể dùng chung với 4.6.
- **Effort:** M.
- **Cost:** Free.
- **License:** JUnit EPL-2.0 (repo đổi tên thành `junit-framework`).
- **Maturity:** ~7.1k stars, last commit 2026-09-27 (checked 2026-09-28).
- **Source:** https://github.com/junit-team/junit-framework

### 4.4 Dashboard điểm TOEIC bằng Streamlit — V3 · E2 · Ratio 1.50

- **Là gì:** App web Python rất nhỏ: nhập điểm từng Part sau mỗi lần thi thử, vẽ biểu đồ tiến bộ.
- **Vì sao giúp Nobin:** Làm quen Python — ngôn ngữ chính của data engineering — bằng một việc có ích ngay.
- **Effort:** S.
- **Cost:** Free (chạy local).
- **License:** Apache-2.0.
- **Maturity:** ~45.8k stars, last commit 2026-09-28 (checked 2026-09-28).
- **Source:** https://github.com/streamlit/streamlit

### 4.5 Cùng API đó bằng ASP.NET Core minimal API — V4 · E3 · Ratio 1.33

- **Là gì:** Viết lại API của 4.7 bằng C#/.NET 10 minimal API.
- **Vì sao giúp Nobin:** So sánh trực tiếp Spring Boot và ASP.NET Core trên *cùng một bài toán*. Giúp chọn hướng nghề, và là nội dung hay cho cuốn `books/csharp`.
- **Effort:** M.
- **Cost:** Free.
- **License:** MIT.
- **Maturity:** aspnetcore ~38.5k stars, last commit 2026-09-28 (checked 2026-09-28).
- **Source:** https://github.com/dotnet/aspnetcore

### 4.6 MCP server riêng (Java SDK) cho glossary + quiz — V4 · E3 · Ratio 1.33

- **Là gì:** Một MCP server viết bằng Java, cho Claude các tool như `lookup_term` (tra GLOSSARY) và `random_quiz` (lấy câu hỏi từ 4.3).
- **Vì sao giúp Nobin:** Vừa luyện Java, vừa hiểu MCP từ bên trong — kỹ năng mới, ít người có. Có thể thêm vào `.mcp.json` của repo này.
- **Effort:** M.
- **Cost:** Free.
- **License:** MIT (java-sdk).
- **Maturity:** ~3.7k stars, last commit 2026-09-23 (checked 2026-09-28).
- **Source:** https://github.com/modelcontextprotocol/java-sdk

### 4.7 Spring Boot backend đồng bộ tiến độ cho app TOEIC — V5 · E4 · Ratio 1.25

- **Là gì:** REST API (Spring Boot + PostgreSQL) lưu tiến độ học của app `apps/toeic`: user, bộ từ, lịch ôn. Integration test bằng Testcontainers (1.15).
- **Vì sao giúp Nobin:** Đây là project portfolio mạnh nhất cho mục tiêu "frontend lead → Java backend": có app mobile thật (Expo) gọi backend thật.
- **Effort:** L (auth, database, deploy).
- **Cost:** Free khi chạy local. Deploy lên cloud có thể tốn phí.
- **License:** Apache-2.0.
- **Maturity:** Spring Boot ~81.5k stars, last commit 2026-09-28 (checked 2026-09-28).
- **Source:** https://github.com/spring-projects/spring-boot

### 4.8 One Billion Row Challenge (1BRC) bằng Java — V3 · E3 · Ratio 1.00

- **Là gì:** Thử thách đọc file 1 tỉ dòng nhiệt độ và tính min/mean/max nhanh nhất bằng Java.
- **Vì sao giúp Nobin:** Học sâu về I/O, concurrency, virtual threads, memory — kiến thức backend nâng cao. Có sẵn nhiều lời giải để so sánh sau khi tự làm.
- **Effort:** M.
- **Cost:** Free.
- **License:** Apache-2.0.
- **Maturity:** ~8.1k stars, last commit 2024-08-20 — thử thách đã kết thúc; repo dùng làm tài liệu học, không còn phát triển (checked 2026-09-28).
- **Source:** https://github.com/gunnarmorling/1brc

### 4.9 Orchestrate pipeline 4.2 bằng Apache Airflow — V3 · E4 · Ratio 0.75

- **Là gì:** Chạy pipeline 4.2 theo lịch (hằng ngày) bằng Airflow DAG.
- **Vì sao giúp Nobin:** Airflow xuất hiện nhiều trong tin tuyển data engineer. Chỉ nên làm sau 3.10 và 4.2.
- **Effort:** L (cài đặt nặng, cần Docker).
- **Cost:** Free (local).
- **License:** Apache-2.0.
- **Maturity:** ~47.0k stars, last commit 2026-09-28 (checked 2026-09-28).
- **Source:** https://github.com/apache/airflow

---

## Host bị chặn trong sandbox (ảnh hưởng tới việc kiểm chứng)

Những trang chính thức sau trả về lỗi `EGRESS_BLOCKED` / `403` khi mở từ sandbox (checked 2026-09-28).
Các mục liên quan được ghi **UNVERIFIED**:

ets.org, etsglobal.org, education.oracle.com, enthuware.com, wiley.com, oreilly.com, selikoff.net,
apps.ankiweb.net, jetbrains.com, blog.jetbrains.com, omscs.gatech.edu, docs.github.com, github.blog,
docs.expo.dev, usebruno.com, mise.jdx.dev, duckdb.org, context7.com, cspell.org, lychee.cli.rs.

## Nguồn tham khảo (Sources)

Chỉ các link đã thực sự mở được (qua WebFetch, raw.githubusercontent.com hoặc GitHub API), checked 2026-09-28:

- https://code.claude.com/docs/en/mcp
- https://github.com/upstash/context7
- https://github.com/github/github-mcp-server
- https://github.com/jbangdev/jbang
- https://github.com/microsoft/playwright-mcp
- https://github.com/sdkman/sdkman-cli
- https://github.com/usebruno/bruno
- https://github.com/dbeaver/dbeaver
- https://github.com/belav/csharpier
- https://github.com/JetBrains/intellij-community
- https://github.com/modelcontextprotocol/servers
- https://github.com/jesseduffield/lazygit
- https://github.com/motherduckdb/mcp-server-motherduck
- https://github.com/jdx/mise
- https://github.com/mermaid-js/mermaid-cli
- https://github.com/testcontainers/testcontainers-java
- https://github.com/github/docs/blob/main/data/reusables/actions/actions-billing.md
- https://github.com/github/docs/blob/main/content/code-security/reference/supply-chain-security/dependabot-options-reference.md
- https://github.com/lycheeverse/lychee-action
- https://github.com/lycheeverse/lychee
- https://github.com/crate-ci/typos/blob/master/docs/github-action.md
- https://github.com/DavidAnson/markdownlint-cli2-action
- https://github.com/dorny/paths-filter
- https://github.com/actions/setup-java
- https://github.com/actions/setup-dotnet
- https://github.com/streetsidesoftware/cspell-dicts/tree/main/dictionaries/vi_VN
- https://github.com/streetsidesoftware/cspell-action
- https://github.com/expo/expo-github-action
- https://github.com/jgm/pandoc
- https://github.com/actions/upload-artifact
- https://github.com/anthropics/claude-code-action
- https://github.com/evilmartians/lefthook
- https://github.com/softprops/action-gh-release
- https://github.com/vale-cli/vale
- https://github.com/ankitects/anki
- https://github.com/ankitects/anki-manual/blob/main/src/deck-options.md
- https://github.com/ankitects/anki-manual/blob/main/src/importing/text-files.md
- https://github.com/open-spaced-repetition/fsrs4anki
- https://github.com/openjdk/jdk/tree/master/src/jdk.jshell
- https://github.com/duckdb/duckdb
- https://github.com/VuXuanThanh-Dev/super-apps/blob/main/TOEIC-900-Word-Families-Collocations-Tap1.pdf
- https://github.com/java/devjava-content
- https://github.com/dotnet/docs
- https://github.com/DataTalksClub/data-engineering-zoomcamp
- https://github.com/kerrickstaley/genanki
- https://github.com/evidence-dev/evidence
- https://github.com/junit-team/junit-framework
- https://github.com/streamlit/streamlit
- https://github.com/dotnet/aspnetcore
- https://github.com/modelcontextprotocol/java-sdk
- https://github.com/spring-projects/spring-boot
- https://github.com/gunnarmorling/1brc
- https://github.com/apache/airflow

Link chỉ thấy qua WebSearch (không mở được, **UNVERIFIED**):

- https://www.wiley.com/en-us/OCP+Oracle+Certified+Professional+Java+SE+21+Developer+Study+Guide-p-9781394286621
- https://www.ets.org/toeic/test-takers/about/listening-reading.html
- https://education.oracle.com/java-se-21-developer-professional/pexam_1Z0-830
- https://omscs.gatech.edu/cost-and-payment-schedule
