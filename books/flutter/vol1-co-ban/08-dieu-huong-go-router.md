# Chương 8 — Điều hướng: Navigator và go_router

## Mục tiêu

- Dùng `Navigator.push`/`pop` (mệnh lệnh) và nhận kết quả trả về từ màn hình khác.
- Dùng **go_router** (khai báo, theo URL) — cách docs chính thức khuyên cho đa số app:
  path parameter, query parameter, route lồng, tab giữ state (`StatefulShellRoute`), trang 404.
- Viết **guard** bằng `redirect` + `refreshListenable`.
- Biết khác nhau giữa `context.go` và `context.push`.

## Giải thích đơn giản

Flutter có 2 kiểu điều hướng (docs "Navigation and routing"):

1. **Navigator (imperative)**: một ngăn xếp (stack) màn hình. `push` chồng màn hình mới lên, `pop` bỏ ra.
   Đơn giản, nhưng không có URL → khó deep link, không hợp web.
2. **Router (declarative)** qua package như **go_router**: bạn khai báo bảng **URL → màn hình**; đi đến URL nào
   thì stack được dựng theo URL đó. Docs: go_router là "preferred way to write 90% of Flutter applications";
   named routes (`Navigator.pushNamed`) **không** được khuyên dùng cho đa số app.

| Angular Router | go_router |
|---|---|
| `Routes` array | `GoRouter(routes: [GoRoute(...)])` |
| `path: 'tasks/:id'` | `GoRoute(path: ':id')` lồng trong `/tasks` |
| `route.paramMap.get('id')` | `state.pathParameters['id']` |
| `route.queryParamMap` | `state.uri.queryParameters` |
| `router.navigateByUrl('/tasks/1')` | `context.go('/tasks/1')` |
| `children` + `<router-outlet>` | route con / `ShellRoute` / `StatefulShellRoute` |
| `canActivate` trả `UrlTree` | `redirect:` trả URL mới hoặc `null` |
| `**` → NotFound | `errorBuilder:` |

## Ví dụ

### Navigator: push và nhận kết quả

`examples/lib/chapters/ch08/navigator_basics.dart`:

```dart
Future<void> _pick() async {
  // push trả về Future: hoàn thành khi màn hình kia gọi Navigator.pop(context, value).
  final result = await Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (context) => const ColorChoiceScreen()),
  );
  if (!mounted) return; // widget có thể đã bị gỡ trong lúc chờ
  setState(() => _picked = result ?? 'đã hủy');
}
```

Màn hình kia: `ListTile(title: Text(c), onTap: () => Navigator.pop(context, c))`. Người dùng bấm nút Back →
`result == null` ("đã hủy"). Hộp thoại `showDialog` cũng trả kết quả theo cách này (app mẫu dùng để xác nhận xóa).

### go_router: path, query, guard

`examples/lib/chapters/ch08/word_router.dart`:

```dart
GoRouter buildWordRouter({required ValueNotifier<bool> loggedIn, String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: loggedIn, // loggedIn đổi → chạy lại redirect
    redirect: (context, state) {
      final goingToWords = state.matchedLocation.startsWith('/words');
      if (goingToWords && !loggedIn.value) {
        // giống CanActivateFn trả về UrlTree('/login')
        return Uri(path: '/login', queryParameters: {'from': state.uri.toString()}).toString();
      }
      return null; // null = cho đi tiếp
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WordHome()),
      GoRoute(
        path: '/words/:id',
        builder: (context, state) =>
            WordDetail(id: state.pathParameters['id']!, tab: state.uri.queryParameters['tab'] ?? 'meaning'),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(loggedIn: loggedIn, from: state.uri.queryParameters['from']),
      ),
    ],
  );
}
```

Dùng trong app: `MaterialApp.router(routerConfig: router)`. Mở từ: `context.push('/words/1')` hoặc
`context.push('/words/1?tab=examples')`. Sau khi đăng nhập: `loggedIn.value = true; context.go(from ?? '/')`.

### App mẫu: 3 tab giữ state + route lồng

`examples/lib/router.dart` (rút gọn):

```dart
GoRouter(
  initialLocation: initialLocation,
  errorBuilder: (context, state) => NotFoundScreen(location: state.uri.toString()),
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => HomeShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/tasks',
            builder: (context, state) => TaskListScreen(store: store),
            routes: [
              GoRoute(path: 'new', builder: (context, state) => TaskFormScreen(store: store)),
              GoRoute(
                path: ':id',
                builder: (context, state) => TaskDetailScreen(store: store, id: state.pathParameters['id']!),
                routes: [
                  GoRoute(path: 'edit', builder: (context, state) =>
                      TaskFormScreen(store: store, editId: state.pathParameters['id'])),
                ],
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [/* /lab, /lab/:chapter */]),
        StatefulShellBranch(routes: [/* /settings */]),
      ],
    ),
  ],
)
```

`HomeShell` vẽ `NavigationBar` và gọi `shell.goBranch(i)` khi đổi tab. `indexedStack` giữ **mỗi tab một stack**
riêng: sang tab Cài đặt rồi quay lại, danh sách vẫn ở nguyên vị trí (test "Cài đặt: chuyển sang giao diện Tối" kiểm tra).

Kết quả thật (2026-09-30, `flutter test --reporter expanded test/chapters/ch08_test.dart`):

```text
00:00 +0: Chương 8 — điều hướng Navigator.push nhận kết quả khi màn hình kia pop
00:01 +1: Chương 8 — điều hướng go_router: path + query parameter
00:01 +2: Chương 8 — điều hướng go_router: redirect về /login khi chưa đăng nhập, rồi quay lại
00:01 +3: Chương 8 — điều hướng Bài 1: safeRedirectTarget chặn open redirect
00:01 +4: All tests passed!
```

## Đi sâu

### `go` hay `push`?

- `context.go('/tasks/t2')`: **đặt** vị trí theo URL. go_router dựng stack từ cây route: `/tasks` rồi `/tasks/t2`
  → có nút Back về danh sách. URL trên web đổi theo.
- `context.push('/words/1')`: **chồng** route lên stack hiện tại, và trả về `Future` (có thể nhận kết quả như
  `Navigator.push`). Hợp với màn hình tạm (chi tiết, chọn một giá trị).
- `context.pop()` bỏ màn hình trên cùng; kiểm tra `context.canPop()` trước nếu màn hình có thể được mở bằng deep link
  (app mẫu: nút "Lưu" dùng `canPop() ? pop() : go('/tasks')`).

### Page-backed và pageless

Docs giải thích: route tạo bởi Router/go_router là *page-backed* (deep link được); route tạo bằng
`Navigator.push`/`showDialog` là *pageless*. Khi một route page-backed bị bỏ khỏi stack (vì `go` sang URL khác), các
route pageless phía sau nó cũng bị bỏ. Vì vậy: trong app dùng go_router, dùng `Navigator.push` chỉ cho thứ tạm thời
(hộp thoại, bottom sheet).

### Thứ tự route và "new" vs ":id"

go_router so khớp theo thứ tự khai báo. Đặt `GoRoute(path: 'new')` **trước** `GoRoute(path: ':id')`, nếu không
`/tasks/new` sẽ khớp `:id = "new"`.

### Deep link trên iPhone

Với go_router, mở app từ URL (universal link / custom scheme) sẽ dựng đúng màn hình. Cấu hình iOS (Associated Domains)
và Android (intent filter) nằm ở Tập 3 (Bảo mật — kiểm tra tham số deep link). Test của app mẫu mở thẳng `/tasks/t2`,
`/tasks/khong-co` và `/abc` (404).

### Web: nút Back của trình duyệt

Router tích hợp History API: mỗi lần điều hướng bằng Router là một mục lịch sử; nút Back của trình duyệt đi ngược
theo thời gian (docs "Web support").

## Lỗi và bẫy thường gặp

- **`/tasks/new` khớp nhầm `:id`** — đặt route cụ thể trước route có tham số.
- **Dùng `context` sau `await`** (sau `showDialog`) mà không kiểm tra `context.mounted`.
- **Quên `refreshListenable`** → đăng nhập xong mà redirect không chạy lại.
- **Redirect vòng lặp**: redirect `/login` → `/login`… luôn trả `null` khi đã ở đúng chỗ.
- **Open redirect**: dùng thẳng `from` từ URL để `go(from)` — kẻ xấu có thể gửi link `?from=https://…`. Kiểm tra (Bài 1).
- **Pop khi stack trống** (mở từ deep link) → dùng `canPop()`.
- **Tạo GoRouter trong `build`** → mỗi lần build tạo router mới, mất trạng thái. Tạo một lần (trong `State`, hoặc biến top-level).

## Tóm tắt

- `Navigator.push/pop` cho màn hình tạm, nhận kết quả bằng `await`.
- go_router: URL → màn hình; `go` đặt vị trí, `push` chồng lên; tham số qua `state.pathParameters`/`state.uri.queryParameters`.
- `StatefulShellRoute.indexedStack` cho tab giữ state; `errorBuilder` cho 404; `redirect` + `refreshListenable` cho guard.

## Bài tập (có lời giải)

**Bài 1.** `LoginScreen` gọi `context.go(from ?? '/')` với `from` lấy từ URL. Viết `safeRedirectTarget(from)` chỉ cho
phép đường dẫn **nội bộ** (bắt đầu bằng một `/`), chặn `https://evil.com`, `//evil.com`, `javascript:...`.

<details>
<summary>Lời giải</summary>

`examples/lib/chapters/ch08/exercise_solution.dart`:

```dart
String safeRedirectTarget(String? from, {String fallback = '/'}) {
  if (from == null || from.isEmpty) return fallback;
  if (!from.startsWith('/') || from.startsWith('//')) return fallback;
  final uri = Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return fallback;
  return from;
}
```

Rồi trong `LoginScreen`: `context.go(safeRedirectTarget(from))`. `//evil.com` là URL "protocol-relative" — trình
duyệt hiểu là domain khác, nên phải chặn riêng. Test có 5 trường hợp (`ch08_test.dart`).
</details>

**Bài 2.** Trong app mẫu, vì sao nút "Lưu" ở form viết `if (context.canPop()) context.pop(); else context.go('/tasks');`
thay vì chỉ `context.pop()`?

<details>
<summary>Lời giải</summary>

Form có thể được mở bằng **deep link** thẳng `/tasks/new`. Khi đó go_router vẫn dựng stack `/tasks` → `/tasks/new`
(route con), nên `pop` thường được. Nhưng nếu route được cấu hình ở cấp cao nhất hoặc mở trong ngữ cảnh khác, stack chỉ
có một trang và `pop()` sẽ báo lỗi "There is nothing to pop". `canPop()` giúp an toàn trong mọi trường hợp. Test
"thêm việc: validate rồi lưu, quay về danh sách" và "chi tiết → sửa → lưu" (`app_test.dart`) chạy qua cả hai nhánh.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30 (đọc file nguồn docs ở commit `ab59c61`):

- Navigation and routing — https://docs.flutter.dev/ui/navigation —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/ui/navigation/index.md
- Tutorial: Stack based navigation — https://docs.flutter.dev/learn/pathway/tutorial/navigation —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/learn/pathway/tutorial/navigation.md
- Cookbook: Navigate to a new screen and back — https://docs.flutter.dev/cookbook/navigation/navigation-basics —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/navigation/navigation-basics.md
- Cookbook: Return data from a screen — https://docs.flutter.dev/cookbook/navigation/returning-data —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/navigation/returning-data.md
- Architecture recommendations (go_router) — https://docs.flutter.dev/app-architecture/recommendations —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/recommendations.md
- Package go_router 18.0.2 (README trong pub cache sau `flutter pub get`): https://pub.dev/packages/go_router
