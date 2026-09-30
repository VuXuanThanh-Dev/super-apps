# Chương 5 — Layout, styling, theming và adaptive layout

## Mục tiêu

- Hiểu quy tắc layout của Flutter: **"Constraints go down. Sizes go up. Parent sets position."**
- Dùng `Row`, `Column`, `Expanded`, `Padding`, `SizedBox`, `Wrap`, `Card`, `ListTile`.
- Tạo theme Material 3 sáng/tối từ một màu gốc (`ColorScheme.fromSeed`) và bật **dark mode**.
- Làm layout thích ứng (adaptive) theo bề rộng màn hình bằng `LayoutBuilder`.
- Sửa lỗi kinh điển "RenderFlex overflowed".

## Giải thích đơn giản

Không có CSS. Mỗi việc là một widget:

| CSS / Angular | Flutter |
|---|---|
| `display:flex; flex-direction:row` | `Row` |
| `flex-direction:column` | `Column` |
| `justify-content` / `align-items` | `mainAxisAlignment` / `crossAxisAlignment` |
| `flex: 1` | `Expanded` (hoặc `Flexible`) |
| `padding` | `Padding(padding: EdgeInsets.all(16))` |
| `margin`, `gap` | `SizedBox(height: 8)` giữa các con, hoặc `spacing:` của Row/Column/Wrap |
| `flex-wrap: wrap` | `Wrap` |
| `position:absolute` | `Stack` + `Positioned` |
| `@media (min-width: 600px)` | `LayoutBuilder` / `MediaQuery.sizeOf(context)` |
| CSS variables / theme SCSS | `ThemeData`, `ColorScheme`, `TextTheme` |

Quy tắc vàng từ docs (trang "Understanding constraints"): **cha đưa ràng buộc (constraints) xuống cho con;
con chọn kích thước trong ràng buộc đó và báo lên; cha quyết định vị trí của con.** Một widget không thể
"muốn" to hơn chỗ cha cho — đó là nguồn gốc của lỗi overflow.

## Ví dụ

### Row / Column / Expanded — PriceCard

`examples/lib/chapters/ch05/layout_demo.dart` (rút gọn):

```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Expanded chiếm hết chỗ còn lại (giống flex: 1).
            Expanded(child: Text(title, style: text.titleLarge)),
            Text(price, style: text.titleLarge?.copyWith(color: scheme.primary)),
          ],
        ),
        const SizedBox(height: 8),
        for (final f in features)
          Row(
            children: [
              Icon(Icons.check, size: 18, color: scheme.tertiary),
              const SizedBox(width: 6),
              Expanded(child: Text(f)),
            ],
          ),
      ],
    ),
  ),
);
```

`text` và `scheme` lấy từ `Theme.of(context).textTheme` / `.colorScheme` — không viết mã màu cứng.

### Theme sáng/tối — `examples/lib/theme.dart`

```dart
abstract final class AppTheme {
  static const Color seed = Color(0xFF1D4ED8);

  static ThemeData light = _build(Brightness.light);
  static ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      appBarTheme: AppBarTheme(backgroundColor: scheme.primaryContainer, foregroundColor: scheme.onPrimaryContainer),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
    );
  }
}
```

Và trong `app.dart`:

```dart
MaterialApp.router(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: mode,          // ThemeMode.system / light / dark — người dùng chọn ở tab Cài đặt
  routerConfig: _router,
)
```

- `ColorScheme.fromSeed` sinh cả bảng màu Material 3 (primary, secondary, tertiary, surface…, và các màu `on…`
  cho chữ) từ **một** màu gốc, cho cả sáng và tối.
- Material 3 là mặc định (`useMaterial3 == true` — test của sách kiểm tra điều này).
- `ThemeMode.system` theo cài đặt của iPhone (Settings → Display & Brightness).

### Adaptive layout — số cột theo bề rộng

```dart
/// Adaptive layout: số cột theo bề rộng (breakpoint giống Material 3 window size classes).
int columnsForWidth(double width) {
  if (width >= 840) return 3; // expanded
  if (width >= 600) return 2; // medium
  return 1; // compact (điện thoại dọc)
}

class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder cho biết ràng buộc (constraints) mà cha trao cho widget này.
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsForWidth(constraints.maxWidth);
        return GridView.count(
          crossAxisCount: columns,
          childAspectRatio: columns == 1 ? 2.4 : 1.4,
          padding: const EdgeInsets.all(8),
          children: children,
        );
      },
    );
  }
}
```

Docs ("Adaptive and responsive design") gợi ý ví dụ: dưới 600 px logic dùng bottom navigation bar, từ 600 trở
lên dùng navigation rail. Mốc 840 lấy theo Material 3 window size classes (**UNVERIFIED** — trang m3.material.io
không mở được trong sandbox).

Test đổi kích thước màn hình ảo:

```dart
testWidgets('AdaptiveGrid đổi số cột theo bề rộng', (tester) async {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpApp(tester, const LayoutDemo());
  final grid = tester.widget<GridView>(find.byType(GridView));
  final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
  expect(delegate.crossAxisCount, 3);
});
```

Kết quả thật (2026-09-30, `flutter test --reporter expanded test/chapters/ch05_test.dart`):

```text
00:00 +0: Chương 5 — layout, theme, adaptive columnsForWidth theo breakpoint
00:00 +1: Chương 5 — layout, theme, adaptive AdaptiveGrid đổi số cột theo bề rộng
00:00 +2: Chương 5 — layout, theme, adaptive AppTheme: dark theme có Brightness.dark, cùng seed
00:01 +3: Chương 5 — layout, theme, adaptive Bài 1: colorForPriority lấy màu từ ColorScheme
00:01 +4: Chương 5 — layout, theme, adaptive Bài 2: chữ dài trong Row không gây overflow
00:01 +5: All tests passed!
```

## Đi sâu

### Vì sao `Text` dài trong `Row` bị tràn?

`Row` cho con **không giới hạn** chiều ngang (unbounded) để con tự đo. `Text` rất dài đo ra rộng hơn màn hình
→ Row không chứa nổi → vạch sọc vàng-đen và lỗi "A RenderFlex overflowed by N pixels". Cách sửa: bọc bằng
`Expanded`/`Flexible` để con nhận ràng buộc **có giới hạn** (phần còn lại của Row), rồi `Text` tự xuống dòng
hoặc cắt bằng `overflow: TextOverflow.ellipsis`.

### `MediaQuery` vs `LayoutBuilder`

- `MediaQuery.sizeOf(context)` — kích thước **cả cửa sổ**.
- `LayoutBuilder` — kích thước **chỗ cha cho widget này** (chính xác hơn khi widget nằm trong một cột bên).
  Docs khuyên nghĩ theo không gian được cấp, không theo loại thiết bị.

### Tùy biến theme theo component

`ThemeData` có `appBarTheme`, `inputDecorationTheme`, `filledButtonTheme`, `cardTheme`… Đặt ở một chỗ, cả app theo.
Muốn một nhánh dùng theme khác: bọc bằng `Theme(data: ..., child: ...)` (giống `:host` trong Angular nhưng theo cây).

### Material hay Cupertino?

Sách dùng Material 3 cho cả iOS (đơn giản, một bộ widget). Nhiều widget có bản `.adaptive` (ví dụ
`Switch.adaptive`, `CircularProgressIndicator.adaptive`) tự dùng giao diện iOS trên iPhone.

### Font tiếng Việt

Trên iPhone/Android, font hệ thống hiển thị tốt tiếng Việt. Trên **web**, Flutter tải font dự phòng từ
Google Fonts khi gặp ký tự lạ; không có mạng thì có thể hiện ô vuông. Muốn chắc chắn, thêm font (ví dụ Noto
Sans, giấy phép OFL) vào `assets` và khai báo trong `pubspec.yaml` (docs cookbook "Use a custom font").

## Lỗi và bẫy thường gặp

- **Overflow**: `Text` dài trong `Row` → bọc `Expanded`.
- **`Expanded` ngoài `Row`/`Column`/`Flex`** → lỗi "Incorrect use of ParentDataWidget".
- **ListView trong Column không có chiều cao** → lỗi "Vertical viewport was given unbounded height". Bọc ListView bằng `Expanded`.
- **Viết màu cứng** (`Colors.white`) → dark mode xấu. Dùng `colorScheme.onSurface`, `surface`…
- **Quên `const`** cho widget tĩnh → build lại không cần thiết (lint nhắc).

## Tóm tắt

- Constraints đi xuống, kích thước đi lên, cha đặt vị trí.
- Row/Column/Expanded ≈ Flexbox. Padding/SizedBox thay margin/padding.
- `ColorScheme.fromSeed` + `theme`/`darkTheme`/`themeMode` = dark mode đầy đủ.
- `LayoutBuilder` để thích ứng theo bề rộng.

## Bài tập (có lời giải)

**Bài 1.** Viết `colorForPriority(ColorScheme, Priority)`: cao → `error`, bình thường → `primary`, thấp → `outline`.
Vì sao lấy từ `ColorScheme` thay vì `Colors.red`?

<details>
<summary>Lời giải</summary>

`examples/lib/chapters/ch05/exercise_solution.dart`:

```dart
Color colorForPriority(ColorScheme scheme, Priority p) => switch (p) {
  Priority.high => scheme.error,
  Priority.normal => scheme.primary,
  Priority.low => scheme.outline,
};
```

Màu trong `ColorScheme` được tính cho **cả** sáng và tối, đủ tương phản với `surface`. `Colors.red` giữ nguyên ở
dark mode nên có thể quá chói hoặc khó đọc. Test dùng `AppTheme.dark.colorScheme` để kiểm tra.
</details>

**Bài 2.** Dòng sau bị overflow trên iPhone nhỏ. Sửa để chữ bị cắt bằng "…" thay vì tràn:

```dart
Row(children: [Icon(Icons.label_outline), SizedBox(width: 8), Text(title), Icon(Icons.chevron_right)])
```

<details>
<summary>Lời giải</summary>

```dart
Row(
  children: [
    const Icon(Icons.label_outline),
    const SizedBox(width: 8),
    Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
    const Icon(Icons.chevron_right),
  ],
)
```

Test đặt màn hình 320 px, `title` dài 240 ký tự, rồi `expect(tester.takeException(), isNull)` — nếu còn overflow,
`takeException()` trả về lỗi FlutterError.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30 (đọc file nguồn docs ở commit `ab59c61`):

- Tutorial: Layout widgets on a screen — https://docs.flutter.dev/learn/pathway/tutorial/layout —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/learn/pathway/tutorial/layout.md
- Layouts in Flutter — https://docs.flutter.dev/ui/layout —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/ui/layout/index.md
- Understanding constraints — https://docs.flutter.dev/ui/layout/constraints —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/ui/layout/constraints.md
- Organize a theme (cookbook) — https://docs.flutter.dev/cookbook/design/themes —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/design/themes.md
- Tutorial: Adaptive layouts — https://docs.flutter.dev/learn/pathway/tutorial/adaptive-layout —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/learn/pathway/tutorial/adaptive-layout.md
- Adaptive and responsive design — general approach — https://docs.flutter.dev/ui/adaptive-responsive/general —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/ui/adaptive-responsive/general.md
- Use a custom font (cookbook) — https://docs.flutter.dev/cookbook/design/fonts —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/design/fonts.md
- Flutter for web developers — https://docs.flutter.dev/flutter-for/web-devs —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/flutter-for/web-devs.md
