# Test result — code-reviewer

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: code-reviewer
- Correct agent triggered: yes
- Tools the subagent used: Bash, Read

## Prompt

Please review the change in add-user-search.diff before I merge it into develop. Be strict.

## Result (verbatim)

## Verdict: REQUEST CHANGES
Tóm tắt: Change này thay cách load danh sách user bằng search trực tiếp qua `HttpClient` trong component. Có 2 blocker. (1) Template `@if (users.length = 0)` dùng phép gán thay vì so sánh. (2) Màn hình không còn load danh sách ban đầu, nên bị regression. Ngoài ra còn nhiều lỗi major: race condition do nested subscribe, subscription leak, URL không encode, không xử lý lỗi, dùng `innerHTML` cho dữ liệu user, `getAge` tính sai, và không có test.

**Lưu ý về phạm vi:** repo tại `/tmp/claude-0/-home-user-super-apps/dc3b63d6-198e-59e3-b3c8-1c8b388a1027/scratchpad/agent-tests/code-reviewer` chưa có commit nào (`fatal: your current branch 'main' does not have any commits yet`). Không có branch `develop` và không có source code. Repo chỉ chứa file diff và thư mục `.claude/agents`. Vì vậy tôi **không đối chiếu được** với `UserService`, `user.model.ts`, `user-list.component.html` hay convention của project (không có CLAUDE.md, eslint, prettier). Review dưới đây chỉ dựa trên diff và các quy tắc chung của team (Angular Signals, standalone, PrimeNG).

| # | Mức độ | File:dòng | Vấn đề | Đề xuất sửa |
|---|--------|-----------|--------|-------------|
| 1 | blocker | src/app/users/user-list.component.ts:26 (diff dòng 26) | `@if (users.length = 0)` là phép **gán**, không phải so sánh. Angular template không cho phép assignment trong binding hay control flow, nên sẽ báo compile error. Nếu có qua được thì biểu thức cũng luôn falsy và còn xoá luôn mảng. | Sửa thành `@if (users().length === 0)`. Tốt hơn là dùng `<ng-template pTemplate="emptymessage">` của `p-table`. |
| 2 | blocker | user-list.component.ts:36-43 | Regression: trước đây `ngOnInit` gọi `userService.getAll()` để load danh sách. Giờ `valueChanges` không emit giá trị ban đầu, nên bảng **rỗng cho tới khi user gõ phím**. | Thêm `startWith(this.search.value ?? '')` vào pipeline, hoặc load danh sách đầy đủ khi term rỗng. |
| 3 | major | user-list.component.ts:38-42 | Nested subscribe và không có `switchMap` gây race condition: response cũ về sau sẽ ghi đè kết quả mới. Không có `debounceTime` / `distinctUntilChanged`, nên mỗi lần gõ phím là một request. | `this.search.valueChanges.pipe(startWith(''), debounceTime(300), map(t => (t ?? '').trim()), distinctUntilChanged(), switchMap(t => this.userService.search(t).pipe(catchError(() => of([])))))` |
| 4 | major | user-list.component.ts:38 | Subscription leak: `valueChanges.subscribe` không bao giờ được unsubscribe khi component bị destroy. | Dùng `toSignal(...)` (tự cleanup) hoặc `.pipe(takeUntilDestroyed(this.destroyRef))`. |
| 5 | major | user-list.component.ts:39 | `'/api/users?q=' + term` nối chuỗi mà không encode. Term chứa `&`, `#`, `+` hay `%` sẽ làm hỏng hoặc chèn thêm query param (parameter injection). `FormControl('')` có kiểu `string \| null`, nên khi `reset()` sẽ gửi `q=null`. | Dùng `new FormControl('', { nonNullable: true })` và `http.get<User[]>('/api/users', { params: new HttpParams().set('q', term) })`. |
| 6 | major | user-list.component.ts:39-41 | Không có error handling. Lỗi HTTP (401/500/network) sẽ thành unhandled error, UI không có trạng thái lỗi hay loading. Sau khi chuyển sang `switchMap`, một lỗi còn **giết luôn stream search**. | Thêm `catchError` bên trong `switchMap`, cùng các signal `loading` / `error` và hiển thị trạng thái cho user. |
| 7 | major | user-list.component.ts:23 | `[innerHTML]="u.name"` render dữ liệu do user nhập dưới dạng HTML. Angular sanitizer có chặn script, nhưng vẫn cho HTML injection (link, markup giả mạo, phishing). Không có lý do nghiệp vụ nào để dùng. | Dùng interpolation `{{ u.name }}`. |
| 8 | major | user-list.component.ts:45-48 | `getAge` chỉ trừ năm, nên sai 1 tuổi nếu chưa tới sinh nhật trong năm. `birthDate` null hoặc sai format sẽ ra `NaN`. `new Date('YYYY-MM-DD')` parse theo UTC, nên lệch ngày ở timezone âm. Hàm còn được gọi trong template ở mỗi change detection cycle. | Tính đủ tháng và ngày, guard giá trị invalid, chuyển thành pure pipe hoặc `computed`. |
| 9 | major | (toàn bộ change) | Không có test cho logic mới: search, debounce, race, empty state, error, `getAge` (edge case sinh nhật, 29/02, null). | Thêm spec cho component với `HttpTestingController` và `fakeAsync`, cùng unit test cho age pipe/helper. |
| 10 | major | user-list.component.ts:21, 39 | Search không có pagination hay giới hạn: `p-table` không `paginator`/`lazy`, API không có `page`/`size`, không có độ dài term tối thiểu. | Dùng `p-table [lazy]="true" [paginator]="true"`, gửi `page`/`size`/`q` lên backend, giới hạn page size, yêu cầu term tối thiểu 2 ký tự. |
| 11 | minor | user-list.component.ts:9, 12, 32 | Bỏ `UserService` và gọi `HttpClient` trực tiếp trong component với URL hardcode. | Thêm `search(term, page)` vào `UserService` rồi inject service đó. |
| 12 | minor | user-list.component.ts:34 | `users: any[]` bỏ mất type `User`, nên mất type-check. | Dùng `users = signal<User[]>([])` hoặc `toSignal(..., { initialValue: [] })`. |
| 13 | minor | user-list.component.ts:14-28 | Không dùng Signals/OnPush theo quy tắc của team. | Thêm `ChangeDetectionStrategy.OnPush`, dùng signal và `toSignal`. |
| 14 | minor | user-list.component.ts:16 | Bỏ `templateUrl`, chuyển inline, nhưng diff không xoá `user-list.component.html` → dead code. | Giữ `templateUrl` và sửa file HTML, hoặc xoá file HTML trong cùng MR. |
| 15 | minor | user-list.component.ts:20 | Input search không có `<label>`/`aria-label`, vấn đề a11y. | `<input pInputText aria-label="Search users" ...>` |
| 16 | nit | user-list.component.ts:21 | `p-table` không có `dataKey`. | Thêm `dataKey="id"`. |

### Kiểm tra đã chạy
- `git log` → `fatal: your current branch 'main' does not have any commits yet`. Repo không có base `develop` hay `origin/main`, nên không so sánh được với base.
- Lint/typecheck/unit test: **không chạy**, vì repo không có `package.json`, `angular.json` hay source code. Diff cũng không apply được vào đâu.

### Câu hỏi cho tác giả
- Còn component/service nào khác đang dùng `UserService.getAll()` không? Bỏ nó ở đây có chủ ý không?
- API `/api/users?q=` đã có phía backend chưa? Có check authz và pagination/giới hạn kết quả không?
- `u.name` dùng `innerHTML` có phải vì backend trả về HTML highlight không? Nếu vậy backend có escape không?
- Project đang dùng Angular version nào?
- Có thể cung cấp repo đầy đủ hoặc branch có base `develop` để đối chiếu convention và chạy lint/test thật không?
