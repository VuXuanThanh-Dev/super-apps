# Chương 5 — Animation: implicit, explicit, Hero

## Mục tiêu

- Dùng **animation ngầm (implicit)**: `AnimatedContainer`, `TweenAnimationBuilder`, `AnimatedSwitcher` — chỉ đổi giá trị đích.
- Dùng **animation tường minh (explicit)**: `AnimationController` + `vsync` + `CurvedAnimation` + `AnimatedBuilder`
  — làm thẻ lật (flip card) cho màn hình ôn tập.
- Dùng **Hero** để chữ "bay" từ danh sách sang màn hình chi tiết.
- Test animation bằng `pump(duration)` và biết vì sao `pumpAndSettle` có thể treo.

## Giải thích đơn giản

Docs ("Introduction to animations") chia hai loại:

| Loại | Bạn làm gì | Widget | Giống Angular |
|---|---|---|---|
| **Implicit** (ngầm) | Đổi thuộc tính → widget tự chạy từ giá trị cũ tới mới | `AnimatedContainer`, `AnimatedOpacity`, `TweenAnimationBuilder`, `AnimatedSwitcher` | CSS `transition` |
| **Explicit** (tường minh) | Tự điều khiển `AnimationController`: forward, reverse, repeat, stop | `AnimationController` + `AnimatedBuilder` / `*Transition` | `@angular/animations` với `AnimationPlayer` |

Quy tắc chọn: thử implicit trước; chỉ dùng explicit khi cần lặp, điều khiển thủ công, hoặc phối hợp nhiều animation.

## Ví dụ

### Implicit: thanh tiến độ và hộp đổi kích thước

`examples/lib/chapters/ch05/animation_demo.dart`:

```dart
class AnimatedProgress extends StatelessWidget {
  const AnimatedProgress({super.key, required this.value});

  final double value; // 0..1

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, v, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: v, minHeight: 10, color: scheme.primary),
          Text('${(v * 100).round()}%'),
        ],
      ),
    );
  }
}
```

`TweenAnimationBuilder` chỉ cần giá trị `end`; khi `value` đổi, nó chạy từ giá trị **hiện tại** tới giá trị mới.

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  height: _big ? 140 : 70,
  decoration: BoxDecoration(
    color: _big ? scheme.tertiaryContainer : scheme.primaryContainer,
    borderRadius: BorderRadius.circular(_big ? 32 : 8),
  ),
  alignment: Alignment.center,
  child: const Text('Chạm để đổi'),
)
```

### Explicit: thẻ lật — `examples/lib/ui/core/flip_card.dart`

```dart
class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  // SingleTickerProviderStateMixin cung cấp "vsync": animation chỉ chạy khi màn hình đang vẽ.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.flipped ? 1 : 0,
  );
  late final Animation<double> _angle = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flipped != widget.flipped) {
      widget.flipped ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _angle,
      builder: (context, _) {
        final angle = _angle.value * math.pi;
        final showBack = angle > math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // phối cảnh (perspective)
            ..rotateY(angle),
          child: showBack
              ? Transform(alignment: Alignment.center, transform: Matrix4.rotationY(math.pi), child: widget.back)
              : widget.front,
        );
      },
    );
  }
}
```

- `AnimationController` chạy giá trị 0 → 1 trong `duration`. `CurvedAnimation` làm chuyển động mượt (ease-in-out).
- `AnimatedBuilder` build lại **chỉ phần bên trong** mỗi frame.
- Nửa đường (90°) thì đổi sang mặt sau; mặt sau được lật thêm 180° để chữ không bị ngược.
- Màn hình **Ôn tập** của app dùng `FlipCard(flipped: vm.revealed, ...)`: ViewModel đổi `revealed`, widget tự lật.

### Hero: chữ bay từ danh sách sang chi tiết

```dart
// Danh sách (word_list_screen.dart)
Hero(tag: 'word-${word.id}', child: Material(type: MaterialType.transparency, child: Text(word.text)))
// Chi tiết (word_detail_screen.dart)
Hero(tag: 'word-${word.id}', child: Material(type: MaterialType.transparency, child: Text(word.text, style: text.displaySmall)))
```

Hai `Hero` cùng `tag` ở hai route → Flutter tự vẽ chữ bay và phóng to khi chuyển trang. Bọc `Material` trong suốt
để chữ không bị gạch chân vàng khi đang bay (vì lúc bay không có `Material` tổ tiên).

### Test animation

```dart
testWidgets('AnimatedProgress chạy từ giá trị cũ tới mới trong 500ms', (tester) async {
  await pumpApp(tester, const AnimatedProgress(value: 0.2));
  await tester.pumpAndSettle();
  expect(find.text('20%'), findsOneWidget);
  await pumpApp(tester, const AnimatedProgress(value: 1));
  await tester.pump(const Duration(milliseconds: 100));
  final mid = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value!;
  expect(mid, inExclusiveRange(0.2, 1.0)); // đang ở giữa đường
  await tester.pumpAndSettle();
  expect(find.text('100%'), findsOneWidget);
});
```

Kết quả thật (2026-09-30, `flutter test --reporter expanded test/chapters/ch05_test.dart`):

```text
00:00 +0: Chương 5 — animation AnimatedProgress chạy từ giá trị cũ tới mới trong 500ms
00:00 +1: Chương 5 — animation FlipCard: nửa đường thì đổi mặt
00:00 +2: Chương 5 — animation Bài 1: PulsingDot lặp khi active, dừng khi tắt
00:00 +3: Chương 5 — animation Bài 2: AnimatedScore có cả chữ cũ và mới trong lúc chuyển
00:00 +4: All tests passed!
```

## Đi sâu

### `pump` vs `pumpAndSettle`

- `pump(d)`: cho thời gian trôi `d` rồi vẽ một frame — dùng để kiểm tra trạng thái **giữa** animation.
- `pumpAndSettle()`: vẽ liên tục tới khi hết frame cần vẽ. Nếu có animation **lặp vô hạn** (`repeat()`), nó **không
  bao giờ xong** và báo lỗi "pumpAndSettle timed out". Sách gặp thật lỗi này khi test tab Lab (có `PulsingDot`) và sửa
  bằng `pump(...)` thay vì `pumpAndSettle()` (xem `test/app_test.dart`, tham số `settle`).

### `vsync` và Ticker

`vsync: this` (từ `SingleTickerProviderStateMixin`) nối controller với **Ticker** — gọi callback mỗi frame, và tự dừng
khi widget không hiển thị (ví dụ tab khác). Nhiều controller trong một State → `TickerProviderStateMixin`.

### Hiệu năng

Animation chạy 60–120 frame/giây: phần build trong `AnimatedBuilder` phải nhẹ. Truyền phần không đổi vào tham số
`child` của `AnimatedBuilder` để khỏi build lại. Dùng `*Transition` (`FadeTransition`, `ScaleTransition`) khi có thể —
chúng chỉ đổi thuộc tính vẽ, không build lại cây.

### Giảm chuyển động

Người dùng bật "Giảm chuyển động" (iOS: Reduce Motion) → `MediaQuery.disableAnimationsOf(context)` trả `true`; nên rút
ngắn hoặc tắt animation không cần thiết.

## Lỗi và bẫy thường gặp

- **Quên `dispose()` AnimationController** → Ticker rò rỉ, test báo lỗi.
- **Tạo AnimationController trong `build`**.
- **`pumpAndSettle` với animation lặp** → timeout.
- **`AnimatedSwitcher` không chạy** vì con mới và cũ cùng loại, cùng key → thêm `key: ValueKey(giá trị)` (Bài 2).
- **Hero trùng tag** trên cùng một màn hình → lỗi "There are multiple heroes that share the same tag".
- **Build nặng trong `AnimatedBuilder`** → giật.

## Tóm tắt

- Implicit trước (`AnimatedContainer`, `TweenAnimationBuilder`, `AnimatedSwitcher`); explicit khi cần điều khiển.
- Explicit = `AnimationController` + `vsync` + `CurvedAnimation` + `AnimatedBuilder`; luôn `dispose`.
- Hero cho chuyển trang đẹp. Test bằng `pump(d)`; cẩn thận `pumpAndSettle` với animation lặp.

## Bài tập (có lời giải)

**Bài 1.** Làm `PulsingDot`: chấm đỏ nhấp nháy lặp lại khi `active = true`, dừng khi `false`.

<details>
<summary>Lời giải</summary>

`examples/lib/chapters/ch05/exercise_solution.dart` (phần chính):

```dart
class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    lowerBound: 0.3,
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      widget.active ? _controller.repeat(reverse: true) : _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _controller,
    child: Icon(Icons.circle, color: Theme.of(context).colorScheme.error, size: 16),
  );
}
```

Test: `tester.hasRunningAnimations` là `true` khi active, `false` sau khi đổi sang `active: false`, và khi đó
`pumpAndSettle()` xong bình thường.
</details>

**Bài 2.** Điểm số đổi thì chữ cũ mờ đi, chữ mới hiện lên.

<details>
<summary>Lời giải</summary>

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 250),
  // Key khác nhau → AnimatedSwitcher biết đây là widget MỚI và chạy animation chuyển.
  child: Text('$score điểm', key: ValueKey(score), style: Theme.of(context).textTheme.headlineMedium),
)
```

Test: đổi 10 → 20, sau 100 ms cả "10 điểm" và "20 điểm" cùng có trong cây (đang chuyển); sau `pumpAndSettle` chỉ còn "20 điểm".
Bỏ `key` đi thì test đầu sẽ thất bại vì không có animation.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30 (đọc file nguồn docs ở commit `ab59c61`):

- Tutorial: Add implicit animations — https://docs.flutter.dev/learn/pathway/tutorial/implicit-animations —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/learn/pathway/tutorial/implicit-animations.md
- Introduction to animations — https://docs.flutter.dev/ui/animations —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/ui/animations/index.md
- Implicit animations — https://docs.flutter.dev/ui/animations/implicit-animations —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/ui/animations/implicit-animations.md
- Animations tutorial (explicit) — https://docs.flutter.dev/ui/animations/tutorial —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/ui/animations/tutorial.md
- Hero animations — https://docs.flutter.dev/ui/animations/hero-animations —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/ui/animations/hero-animations.md
