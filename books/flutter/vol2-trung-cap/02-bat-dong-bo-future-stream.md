# Chương 2 — Bất đồng bộ: Future, async/await, Stream, isolate

## Mục tiêu

- Dùng `Future` + `async`/`await`, chạy song song bằng `Future.wait`, xử lý lỗi và timeout.
- Tạo và dùng `Stream` (`async*`/`yield`, `StreamController`), hiển thị bằng `StreamBuilder`/`FutureBuilder`.
- Biết **event loop** của Dart và khi nào cần **isolate** (`compute`, `Isolate.run`) để UI không bị đứng.
- Tránh lỗi kinh điển: kết quả cũ về sau (race condition), `setState` sau `dispose`.

## Giải thích đơn giản

| RxJS / TypeScript | Dart |
|---|---|
| `Promise<T>` | `Future<T>` |
| `async`/`await` | `async`/`await` (giống hệt) |
| `Promise.all([...])` / `forkJoin` | `Future.wait([...])` |
| `Observable<T>` | `Stream<T>` |
| `subscribe(next, error, complete)` | `listen(onData, onError:, onDone:)` → trả `StreamSubscription` |
| `unsubscribe()` | `subscription.cancel()` |
| `Subject` / `BehaviorSubject` | `StreamController` / `StreamController.broadcast()` |
| `map`, `filter`, `distinctUntilChanged`, `take` | `map`, `where`, `distinct`, `take` |
| `async` pipe | `FutureBuilder` / `StreamBuilder` |
| Web Worker | **Isolate** |

Dart chạy code của bạn trên **một luồng** với **event loop** (vòng lặp sự kiện), giống JavaScript. `await` không
chặn luồng: nó "tạm dừng" hàm và cho event loop làm việc khác (vẽ frame, xử lý chạm). Nhưng một vòng lặp tính
toán nặng **không có await** sẽ chiếm luồng → UI đứng (jank). Khi đó dùng **isolate** — một "luồng" có bộ nhớ riêng.

## Ví dụ

`examples/lib/chapters/ch02/async_demo.dart`:

### Future

```dart
Future<String> fetchGreeting(String name, {Duration delay = const Duration(milliseconds: 50)}) async {
  await Future<void>.delayed(delay);
  if (name.isEmpty) throw ArgumentError('Thiếu tên');
  return 'Xin chào $name';
}

/// Chạy song song và chờ tất cả (≈ Promise.all / forkJoin).
Future<List<String>> greetAll(List<String> names) => Future.wait([for (final n in names) fetchGreeting(n)]);
```

Timeout: `await client.get(uri).timeout(const Duration(seconds: 8))` ném `TimeoutException` nếu quá hạn (dùng trong
`DictionaryClient`, Chương 3).

### Stream bằng `async*`

```dart
Stream<int> countdown(int from, {Duration interval = const Duration(seconds: 1)}) async* {
  for (var i = from; i >= 0; i--) {
    yield i;
    if (i > 0) await Future<void>.delayed(interval);
  }
}
```

`async*` + `yield` = hàm sinh (generator) trả về Stream — tiện hơn tự quản `StreamController`.

### StreamBuilder

```dart
class _CountdownViewState extends State<CountdownView> {
  // Tạo stream MỘT lần trong State — nếu tạo trong build, mỗi lần build sẽ đếm lại từ đầu.
  late final Stream<int> _stream = countdown(widget.from);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) => switch (snapshot) {
        AsyncSnapshot(connectionState: ConnectionState.done) => const Text('Hết giờ!'),
        AsyncSnapshot(:final data?) => Text('Còn $data giây'),
        _ => const Text('Chuẩn bị…'),
      },
    );
  }
}
```

`AsyncSnapshot` có `connectionState` (none/waiting/active/done), `data`, `error`. Pattern `AsyncSnapshot(:final data?)`
nghĩa là "có data khác null". `StreamBuilder` tự hủy đăng ký khi widget bị gỡ.

### Isolate: `compute`

```dart
/// Hàm tốn CPU: đếm từ dài trong văn bản lớn.
int countLongWords(String text) => text.split(RegExp(r'\s+')).where((w) => w.length >= 8).length;

/// Chạy trong isolate khác để không làm đứng UI (trên web: chạy cùng luồng).
Future<int> countLongWordsInBackground(String text) => compute(countLongWords, text);
```

Docs `perf/isolates` gợi ý dùng isolate cho việc nặng như parse JSON lớn, xử lý ảnh, lọc danh sách rất dài. App TOEIC
có thể cần khi nạp một file dữ liệu lớn lần đầu. Hàm truyền cho `compute`/`Isolate.run` phải là hàm top-level hoặc
static (hoặc closure không bắt biến không gửi được), và dữ liệu được **sao chép** sang isolate kia.

### Race condition trong ViewModel — "switchMap" bằng tay

Người dùng gõ "b" rồi "inv": nếu kết quả tìm "b" về **sau** "inv", danh sách hiển thị sai. `WordListViewModel`
giữ một số thứ tự yêu cầu và bỏ kết quả cũ:

```dart
Future<void> refresh() async {
  final id = ++_requestId;
  _loading = true;
  notifyListeners();
  try {
    final result = await _repository.search(query: _query, favoritesOnly: _favoritesOnly);
    if (id != _requestId) return; // đã có yêu cầu mới hơn → bỏ kết quả này
    _words = result;
    _error = null;
  } on Exception catch (e) {
    if (id != _requestId) return;
    _error = e;
  } finally {
    if (id == _requestId) {
      _loading = false;
      notifyListeners();
    }
  }
}
```

Test "bỏ qua kết quả CŨ về muộn (giống switchMap)" dùng một `Completer` để giữ yêu cầu đầu chậm lại (Chương 7).

### Kết quả test thật

`flutter test --reporter expanded test/chapters/ch02_test.dart` (2026-09-30):

```text
00:00 +0: Chương 2 — Future, Stream, isolate Future: await và Future.wait
00:00 +1: Chương 2 — Future, Stream, isolate Stream async*: countdown phát 3, 2, 1, 0 rồi đóng
00:00 +2: Chương 2 — Future, Stream, isolate StreamBuilder hiển thị từng giá trị
00:00 +3: Chương 2 — Future, Stream, isolate compute: chạy hàm nặng ở isolate khác
00:00 +4: Chương 2 — Future, Stream, isolate Bài 1: retry thử lại rồi thành công / hết lượt thì ném lỗi
00:00 +5: Chương 2 — Future, Stream, isolate Bài 2: Completer biến callback thành Future
00:01 +6: All tests passed!
```

## Đi sâu

### Event loop: microtask và event

Dart có 2 hàng đợi: **microtask** (ưu tiên, ví dụ phần sau `await` của Future đã xong) và **event** (I/O, timer,
chạm, vẽ frame). Học chi tiết không bắt buộc; chỉ nhớ: đừng tạo vòng lặp dài không `await` trên luồng UI.

### Single-subscription vs broadcast

- Stream mặc định **single-subscription**: chỉ một người `listen` (giống Observable "lạnh" chỉ cho một subscriber).
- `StreamController.broadcast()`: nhiều người nghe cùng lúc (giống `Subject`). Người đến sau **không** nhận giá trị cũ
  (khác `BehaviorSubject`).

### Lỗi trong Future/Stream

- `try { await f(); } on SocketException catch (e) {...}` — bắt theo kiểu.
- Future lỗi mà không ai `await`/`catchError` → lỗi "unhandled", đi tới `PlatformDispatcher.onError` (Tập 3, Monitoring).
- Lint `unawaited_futures` (dự án của sách bật) nhắc khi quên `await`; nếu cố ý không chờ, bọc `unawaited(f())`.

### `FutureBuilder` và bẫy "tạo Future trong build"

`FutureBuilder(future: repo.load(), ...)` trong `build` → mỗi lần build **gọi lại** `load()`. Tạo Future một lần
(trong `initState`, hoặc tốt hơn: trong ViewModel) rồi truyền vào. App mẫu dùng ViewModel + `Command` nên không cần
`FutureBuilder`.

## Lỗi và bẫy thường gặp

- **Quên `await`** → code chạy tiếp trước khi xong; lỗi không bị bắt.
- **`setState`/`notifyListeners` sau `dispose`** vì Future về muộn → kiểm tra `mounted`, hoặc bỏ qua theo `requestId`.
- **Tạo Stream/Future trong `build`**.
- **Không `cancel()` subscription** tự tạo → rò rỉ; `StreamBuilder` tự lo, còn `listen` thủ công thì phải hủy trong `dispose`.
- **Việc nặng trên luồng UI** → jank; dùng `compute`.
- **Kết quả cũ ghi đè kết quả mới** (race) → requestId / hủy yêu cầu cũ.

## Tóm tắt

- `Future` ≈ Promise, `Stream` ≈ Observable, `async*` tạo stream, `StreamBuilder` ≈ `async` pipe.
- Một luồng + event loop; việc nặng → isolate (`compute`).
- Luôn nghĩ tới: hủy đăng ký, `mounted`, và thứ tự kết quả.

## Bài tập (có lời giải)

**Bài 1.** Viết `retry(action, attempts, initialDelay)`: thử lại khi có `Exception`, thời gian chờ tăng gấp đôi mỗi lần
(100 ms, 200 ms, 400 ms…), hết lượt thì ném lỗi cuối.

<details>
<summary>Lời giải</summary>

`examples/lib/chapters/ch02/exercise_solution.dart`:

```dart
Future<T> retry<T>(
  Future<T> Function() action, {
  int attempts = 3,
  Duration initialDelay = const Duration(milliseconds: 100),
}) async {
  var delay = initialDelay;
  for (var i = 1; ; i++) {
    try {
      return await action();
    } on Exception {
      if (i >= attempts) rethrow;
      await Future<void>.delayed(delay);
      delay *= 2;
    }
  }
}
```

`rethrow` ném lại lỗi gốc (giữ stack trace). Test: hàm lỗi 2 lần rồi trả "ok" → nhận "ok" sau 3 lần gọi; hàm luôn lỗi
với `attempts: 2` → `throwsException`. Tương đương `retry({count, delay})` của RxJS.
</details>

**Bài 2.** Một thư viện cũ chỉ có API callback `legacyLoad(key, (result, error) {...})`. Viết `loadAsFuture(key)` trả
về `Future<String>`.

<details>
<summary>Lời giải</summary>

```dart
Future<String> loadAsFuture(String key) {
  final completer = Completer<String>();
  legacyLoad(key, (result, error) {
    if (error != null) {
      completer.completeError(StateError('$error'));
    } else {
      completer.complete(result);
    }
  });
  return completer.future;
}
```

`Completer` giống `new Promise((resolve, reject) => ...)`. Test: `loadAsFuture('k')` → "giá trị của k";
`loadAsFuture('')` → `throwsStateError`. Plugin native (Tập 3) cũng hay dùng mẫu này.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30:

- Dart — Asynchronous programming — https://dart.dev/language/async —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/language/async.md
- Dart — Async/await tutorial — https://dart.dev/libraries/async/async-await —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/libraries/async/async-await.md
- Dart — Using streams — https://dart.dev/libraries/async/using-streams —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/libraries/async/using-streams.md
- Dart — Creating streams — https://dart.dev/libraries/async/creating-streams —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/libraries/async/creating-streams.md
- Dart — Concurrency / isolates — https://dart.dev/language/concurrency —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/language/concurrency.md
- Flutter — Concurrency and isolates — https://docs.flutter.dev/perf/isolates —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/perf/isolates.md
- Flutter for React Native developers (Futures, async/await) — https://docs.flutter.dev/flutter-for/react-native-devs —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/flutter-for/react-native-devs.md
