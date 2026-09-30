# Chương 2 — Performance: đo trước, sửa sau

## Mục tiêu

- Hiểu ngân sách thời gian mỗi frame (16 ms ở 60 Hz, 8 ms ở 120 Hz) và vì sao phải đo ở **profile mode**.
- Giảm chi phí `build`: `const`, tách widget nhỏ, `select`/`Consumer`, tham số `child` của `AnimatedBuilder`.
- Danh sách lớn: lazy (`ListView.builder`), `itemExtent`, tránh `shrinkWrap` và intrinsic.
- Việc nặng: đưa sang isolate (`compute`).
- Dùng DevTools (Performance, CPU profiler, Memory) và đo kích thước app.
- Chứng minh bằng test "đếm số lần build".

## Giải thích đơn giản

Docs "Performance best practices": Flutter có luồng build (UI) và luồng vẽ (raster) riêng; ở màn hình 60 Hz bạn có khoảng
**16 ms** cho mỗi frame; với thiết bị 120 Hz cần dưới **8 ms**. Quá thời gian → giật (jank). Docs nhấn mạnh: nếu frame
đã dưới 16 ms ở **profile mode** thì thường không cần lo; nhưng làm nhanh hơn vẫn giúp **tiết kiệm pin**.

Quy trình đúng: **đo → tìm chỗ chậm → sửa → đo lại**. Đừng tối ưu theo cảm giác.

| Angular | Flutter |
|---|---|
| `ChangeDetectionStrategy.OnPush` | Widget `const`, tách widget nhỏ, `select` |
| `trackBy` | `Key` |
| Virtual scroll (CDK) | `ListView.builder` (lazy sẵn) |
| Web Worker | Isolate (`compute`) |
| Chrome DevTools Performance | Flutter DevTools Performance + CPU profiler |
| `ng build --prod` rồi đo | `flutter run --profile` rồi đo |

## Ví dụ

### `const` làm Flutter bỏ qua việc build lại

`examples/lib/chapters/ch02/rebuild_demo.dart`:

```dart
class _RebuildDemoState extends State<RebuildDemo> {
  int _ticks = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Đã bấm $_ticks lần'),
        const BuildCounter(label: 'const'), // cùng một đối tượng mỗi lần → Flutter bỏ qua, không build lại
        // ignore: prefer_const_constructors
        BuildCounter(label: 'không const'), // đối tượng mới mỗi lần → build lại
        FilledButton(onPressed: () => setState(() => _ticks++), child: const Text('setState')),
      ],
    );
  }
}
```

`BuildCounter` đếm số lần `build` của nó. Test bấm 2 lần:

```dart
expect(BuildCounter.counts, {'const': 1, 'không const': 3});
```

Widget `const` là **cùng một đối tượng** ở mọi lần build của cha → Flutter so sánh thấy giống hệt → không build lại con.
Lint `prefer_const_constructors` (trong `flutter_lints`) nhắc bạn thêm `const`; dòng `// ignore:` ở trên chỉ để minh họa.

### `AnimatedBuilder` với `child`

Docs liệt kê bẫy: đặt cây con **không phụ thuộc animation** bên trong `builder` → build lại mỗi tick. Cách đúng
(`examples/lib/chapters/ch02/exercise_solution.dart`):

```dart
return AnimatedBuilder(
  animation: _controller,
  // child được build MỘT lần, rồi truyền lại vào builder ở mọi frame.
  child: const BuildCounter(label: 'logo'),
  builder: (context, child) => Transform.rotate(angle: _controller.value * 6.283, child: child),
);
```

Test cho animation chạy 10 frame → `BuildCounter.counts['logo'] == 1`.

Kết quả thật (2026-09-30, phần Ch.2 của `test/chapters_test.dart`):

```text
00:00 +3: Ch.2 — performance const không build lại; không const thì build lại
00:01 +4: Ch.2 — performance Bài 1: child của AnimatedBuilder chỉ build một lần
```

### Danh sách và isolate (nhắc lại Tập 1–2)

- `ListView.builder` + `itemExtent` (Tập 1, Ch.6); tránh `shrinkWrap: true` với list dài — mất tính lazy.
- Parse JSON lớn / lọc hàng nghìn phần tử: `compute(parse, data)` (Tập 2, Ch.2).
- Tìm kiếm trong SQLite (có chỉ mục) nhanh hơn lọc list trong Dart khi dữ liệu lớn (Tập 2, Ch.4).

## Đi sâu

### Đo đúng cách: profile mode + DevTools

Docs `testing/build-modes`: **debug** chậm (JIT, nhiều kiểm tra) — **không** dùng để đo; **profile** gần giống release nhưng
vẫn cho DevTools kết nối; **release** để phát hành.

```bash
flutter run --profile        # trên máy thật (iPhone cần Mac + Xcode); không chạy profile trên máy ảo iOS
```

Trong DevTools:
- **Performance**: biểu đồ frame; frame đỏ là vượt ngân sách. Xem "UI" (build) hay "Raster" (vẽ) chậm.
- **CPU profiler**: hàm nào tốn thời gian.
- **Memory**: rò rỉ (ví dụ controller không dispose).
- **Widget rebuild stats** (plugin IDE, mục "Show widget rebuild information"): widget nào build lại nhiều.

**NOT RUN** trong sandbox (không có thiết bị để đo profile mode).

### Những thứ tốn kém (theo docs)

- `saveLayer` (gây ra bởi một số `Opacity`, `ShaderMask`, `ColorFilter`, clip có anti-alias…): tốn bộ nhớ GPU.
  Dùng `AnimatedOpacity`/`FadeTransition` thay vì `Opacity` trong animation.
- **Intrinsic pass** (`IntrinsicHeight`, `IntrinsicWidth`): bắt đo con hai lần; tránh trong list.
- Xây chuỗi dài bằng `+=` trong vòng lặp → dùng `StringBuffer`.

### Kích thước app

`flutter build apk --analyze-size` / `flutter build ios --analyze-size` tạo báo cáo xem trong DevTools (App Size). Ảnh lớn,
font thừa, package nặng là nguyên nhân hay gặp. Icon Material được **tree-shake** tự động khi build (log build web của sách:
"Font asset MaterialIcons-Regular.otf was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction)").

### Web

Docs có trang "Web performance". Bản web của sách build bằng `--release` (dart2js, tối ưu). Thử `--wasm` cho trình duyệt
hỗ trợ WasmGC (Chrome), **nhưng không dùng cho iPhone** (Tập 1, Ch.1).

## Lỗi và bẫy thường gặp

- **Đo ở debug mode** → kết luận sai.
- **Tối ưu trước khi đo**.
- **`setState` ở widget gốc** cho một thay đổi nhỏ → cả cây build lại. Đưa state xuống thấp, hoặc dùng `select`.
- **Tạo đối tượng nặng trong `build`** (RegExp, định dạng ngày, list lớn) → tạo một lần ở field `final`.
- **Animation dùng `Opacity`** thay vì `FadeTransition`.
- **Ảnh mạng không cache, kích thước gốc lớn** → dùng `cacheWidth`/`cacheHeight` khi giải mã.

## Tóm tắt

- Ngân sách ~16 ms/frame (60 Hz), ~8 ms (120 Hz). Đo ở profile mode bằng DevTools.
- `const`, widget nhỏ, `select`, `child` của `AnimatedBuilder` giảm số lần build — test đếm build chứng minh được.
- List lazy, isolate cho việc nặng, tránh `saveLayer`/intrinsic không cần thiết.

## Bài tập (có lời giải)

**Bài 1.** Một logo xoay dùng `AnimatedBuilder` nhưng đặt `const BuildCounter(label: 'logo')` **trong** `builder`. Sửa để logo
chỉ build một lần, và viết test chứng minh.

<details>
<summary>Lời giải</summary>

Chuyển logo vào tham số `child` (code `SpinningLogo` ở trên). Test:

```dart
testWidgets('Bài 1: child của AnimatedBuilder chỉ build một lần', (tester) async {
  BuildCounter.counts.clear();
  await pumpApp(tester, const SpinningLogo());
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  expect(BuildCounter.counts['logo'], 1);
  await tester.pumpWidget(const SizedBox()); // gỡ để dừng animation lặp
});
```

Lưu ý: vì `BuildCounter` là `const`, ngay cả khi đặt trong `builder` nó cũng **không** build lại (cùng đối tượng). Bài học
thật sự quan trọng khi cây con **không** const được (ví dụ phụ thuộc dữ liệu) — khi đó chỉ tham số `child` mới cứu được.
</details>

**Bài 2.** Màn hình danh sách từ (Tập 2) dùng `context.watch<WordListViewModel>()` ở đầu `build`. Khi chỉ `loading` đổi, cả màn
hình build lại. Đề xuất cách giảm.

<details>
<summary>Lời giải</summary>

Tách thanh tiến độ thành widget riêng dùng `context.select<WordListViewModel, bool>((vm) => vm.loading)`; danh sách dùng
`select((vm) => vm.words)` (list mới mỗi lần tải nên so sánh tham chiếu là đủ). Như vậy đổi `loading` chỉ build lại thanh
tiến độ. Kỹ thuật `select` đã được chứng minh bằng test đếm build ở Tập 2, Chương 1 (Bài 1). Với màn hình vài chục dòng thì
không cần — **đo trước** bằng DevTools rồi mới tách.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30 (đọc file nguồn docs ở commit `ab59c61`):

- Performance best practices — https://docs.flutter.dev/perf/best-practices —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/perf/best-practices.md
- Flutter performance profiling — https://docs.flutter.dev/perf/ui-performance —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/perf/ui-performance.md
- Build modes — https://docs.flutter.dev/testing/build-modes —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/testing/build-modes.md
- Measuring your app's size — https://docs.flutter.dev/perf/app-size —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/perf/app-size.md
- DevTools Performance view — https://docs.flutter.dev/tools/devtools/performance —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/tools/devtools/performance.md
- Concurrency and isolates — https://docs.flutter.dev/perf/isolates —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/perf/isolates.md
- Web performance — https://docs.flutter.dev/perf/web-performance —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/perf/web-performance.md
