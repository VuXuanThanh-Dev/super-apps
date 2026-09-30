# Chương 6 — Danh sách và cuộn: ListView, GridView, Dismissible, slivers

## Mục tiêu

- Hiển thị danh sách dài hiệu quả bằng `ListView.builder` (chỉ tạo dòng đang hiện).
- Dùng `ListView.separated`, `GridView`, `Dismissible` (vuốt để xóa).
- Làm màn hình cuộn tùy biến bằng `CustomScrollView` + **slivers** (app bar co giãn, danh sách có tiêu đề nhóm).
- Test cuộn và vuốt.

## Giải thích đơn giản

| Angular / RN | Flutter |
|---|---|
| `@for` với vài phần tử | `Column(children: [for (...) ...])` (trong `SingleChildScrollView` nếu cần cuộn) |
| CDK virtual scroll / RN `FlatList` | `ListView.builder` |
| RN `SectionList` | `CustomScrollView` + nhiều `SliverList` + tiêu đề `SliverToBoxAdapter` |
| CSS grid | `GridView.count` / `GridView.builder` |
| `trackBy` / `key` | `ValueKey(item.id)` |

`ListView.builder` nhận `itemCount` và hàm `itemBuilder(context, index)`. Flutter chỉ gọi hàm cho các dòng
**đang nằm trong màn hình** (và một ít vùng đệm) — nên 1.000 hay 100.000 dòng vẫn mượt. Docs cookbook
"Work with long lists" dùng đúng cách này.

## Ví dụ

### Danh sách dài — ContactList

`examples/lib/chapters/ch06/lists_demo.dart`:

```dart
class ContactList extends StatelessWidget {
  const ContactList({super.key, this.count = 1000});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: count,
      itemExtent: 56, // biết trước chiều cao → cuộn nhanh hơn
      itemBuilder: (context, i) => ListTile(
        leading: CircleAvatar(child: Text('${(i % 26) + 1}')),
        title: Text('Liên hệ ${i + 1}'),
      ),
    );
  }
}
```

Test chứng minh tính "lười" (lazy):

```dart
testWidgets('ContactList chỉ build dòng đang hiện (lazy) và cuộn tới dòng 200', (tester) async {
  await pumpApp(tester, const ContactList());
  expect(find.text('Liên hệ 1'), findsOneWidget);
  expect(find.text('Liên hệ 200'), findsNothing); // chưa được tạo
  await tester.scrollUntilVisible(find.text('Liên hệ 200'), 500);
  expect(find.text('Liên hệ 200'), findsOneWidget);
});
```

### Vuốt để xóa — Dismissible

```dart
return ListView.separated(
  itemCount: _items.length,
  separatorBuilder: (context, i) => const Divider(height: 1),
  itemBuilder: (context, i) {
    final item = _items[i];
    return Dismissible(
      key: ValueKey(item),
      onDismissed: (_) => setState(() => _items.remove(item)),
      background: ColoredBox(color: Theme.of(context).colorScheme.errorContainer),
      child: ListTile(title: Text(item)),
    );
  },
);
```

`Dismissible` **bắt buộc** có `key` duy nhất, ổn định. Nếu dùng `ValueKey(i)` (theo index), sau khi xóa dòng 2 thì
dòng 3 nhận key "2" → Flutter nhầm, báo lỗi "A dismissed Dismissible widget is still part of the tree".
App mẫu (Chương 9) thêm SnackBar "Hoàn tác".

### Slivers — danh sách từ vựng có tiêu đề nhóm

```dart
return CustomScrollView(
  slivers: [
    const SliverAppBar.medium(title: Text('Từ vựng theo chữ cái'), pinned: true, automaticallyImplyLeading: false),
    for (final entry in groups.entries) ...[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(entry.key, style: text.titleMedium),
        ),
      ),
      SliverList.builder(
        itemCount: entry.value.length,
        itemBuilder: (context, i) => ListTile(title: Text(entry.value[i])),
      ),
    ],
  ],
);
```

Learning Pathway có bài "Scrolling and slivers": sliver là **mảnh** của một vùng cuộn. Ghép nhiều sliver
(app bar co giãn, lưới, danh sách) vào **một** `CustomScrollView` để cuộn chung. App TOEIC có thể dùng mẫu này
cho "từ vựng theo unit".

Kết quả thật (2026-09-30, `flutter test --reporter expanded test/chapters/ch06_test.dart`):

```text
00:00 +0: Chương 6 — danh sách ContactList chỉ build dòng đang hiện (lazy) và cuộn tới dòng 200
00:01 +1: Chương 6 — danh sách SwipeList: vuốt để xóa
00:02 +2: Chương 6 — danh sách SectionedWordList hiển thị tiêu đề nhóm
00:02 +3: Chương 6 — danh sách Bài 1: groupByInitial sắp xếp nhóm và từ
00:02 +4: Chương 6 — danh sách Bài 2: ColorGrid có 20 ô
00:02 +5: All tests passed!
```

## Đi sâu

### ListView có mấy kiểu?

| Constructor | Dùng khi |
|---|---|
| `ListView(children: [...])` | Ít phần tử, biết trước (tạo hết ngay) |
| `ListView.builder` | Nhiều / không biết trước — lazy |
| `ListView.separated` | Lazy + có đường kẻ giữa các dòng |
| `ListView.custom` | Tùy biến sâu (hiếm dùng) |

`itemExtent` (hoặc `prototypeItem`) giúp Flutter không phải đo từng dòng → nhảy tới vị trí xa nhanh hơn.

### Cuộn và bàn phím, SafeArea

`Scaffold` tự tránh bàn phím (`resizeToAvoidBottomInset`) và `AppBar`/`NavigationBar` tự tránh tai thỏ. Nếu tự
dựng màn hình không có `Scaffold`, bọc bằng `SafeArea`.

### Kéo để làm mới, cuộn vô hạn

- `RefreshIndicator(onRefresh: () async {...}, child: ListView(...))` — kéo xuống để tải lại.
- Cuộn vô hạn: trong `itemBuilder`, khi `index` gần cuối thì gọi tải trang tiếp (Tập 2, HTTP).

### Hiệu năng

Danh sách lớn chậm thường do: tạo widget nặng trong mỗi dòng, ảnh lớn không cache, hoặc `shrinkWrap: true`
(bắt ListView đo **mọi** phần tử — mất tính lazy). Tập 3 (Performance) có thêm.

## Lỗi và bẫy thường gặp

- **`ListView` trong `Column`** không có `Expanded` → "unbounded height".
- **`shrinkWrap: true` cho danh sách dài** → mất lazy, giật.
- **Key theo index** cho `Dismissible` / danh sách sắp xếp lại → State bị lẫn.
- **Sửa list trong `onDismissed` mà quên `setState`** → lỗi "dismissed Dismissible still in tree".
- **Lồng ListView cùng chiều** mà không dùng sliver → cuộn "giành nhau".

## Tóm tắt

- `ListView.builder` = danh sách lazy; `separated` có đường kẻ; `GridView` cho lưới.
- `Dismissible` + `ValueKey(id)` để vuốt xóa.
- `CustomScrollView` + slivers cho màn hình cuộn phức tạp.
- Test cuộn bằng `scrollUntilVisible`, vuốt bằng `tester.drag`.

## Bài tập (có lời giải)

**Bài 1.** Viết `groupByInitial(words)` → `Map<String, List<String>>`: nhóm theo chữ cái đầu (viết hoa), bỏ chuỗi
rỗng, các nhóm A→Z, từ trong nhóm A→Z không phân biệt hoa thường. Dùng kết quả cho `SectionedWordList`.

<details>
<summary>Lời giải</summary>

`examples/lib/chapters/ch06/exercise_solution.dart`:

```dart
Map<String, List<String>> groupByInitial(Iterable<String> words) {
  final groups = <String, List<String>>{};
  for (final w in words.map((w) => w.trim()).where((w) => w.isNotEmpty)) {
    final key = w.characters.first.toUpperCase();
    groups.putIfAbsent(key, () => []).add(w);
  }
  final keys = groups.keys.toList()..sort();
  return {for (final k in keys) k: (groups[k]!..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())))};
}
```

`..sort()` là **cascade**: gọi `sort()` trên list rồi trả về chính list đó. Map literal của Dart **giữ thứ tự
chèn**, nên thứ tự khóa là A→Z. Test: `['delay','Budget','approve','agenda',' ','deadline']` →
`{A: [agenda, approve], B: [Budget], D: [deadline, delay]}`.
</details>

**Bài 2.** Làm lưới 20 ô màu; số cột = `columnsForWidth(bề rộng) + 1` (dùng lại hàm của Chương 5).

<details>
<summary>Lời giải</summary>

```dart
LayoutBuilder(
  builder: (context, constraints) => GridView.builder(
    padding: const EdgeInsets.all(8),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columnsForWidth(constraints.maxWidth) + 1,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
    ),
    itemCount: 20,
    itemBuilder: (context, i) => Container(
      color: Colors.primaries[i % Colors.primaries.length],
      alignment: Alignment.center,
      child: Text('Ô ${i + 1}', style: const TextStyle(color: Colors.white)),
    ),
  ),
)
```

`GridView.builder` cũng lazy như `ListView.builder`. Test kiểm tra thấy "Ô 1" (`ch06_test.dart`).
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30 (đọc file nguồn docs ở commit `ab59c61`):

- Cookbook: Use lists — https://docs.flutter.dev/cookbook/lists/basic-list —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/lists/basic-list.md
- Cookbook: Work with long lists — https://docs.flutter.dev/cookbook/lists/long-lists —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/lists/long-lists.md
- Cookbook: Create a grid list — https://docs.flutter.dev/cookbook/lists/grid-lists —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/lists/grid-lists.md
- Cookbook: Implement swipe to dismiss — https://docs.flutter.dev/cookbook/gestures/dismissible —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/gestures/dismissible.md
- Tutorial: Scrolling and slivers — https://docs.flutter.dev/learn/pathway/tutorial/slivers —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/learn/pathway/tutorial/slivers.md
- Flutter for React Native developers (FlatList/SectionList) — https://docs.flutter.dev/flutter-for/react-native-devs —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/flutter-for/react-native-devs.md
