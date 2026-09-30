# Chương 3 — Dart cho TypeScript developer

## Mục tiêu

- Đọc và viết Dart nhanh nhờ kiến thức TypeScript.
- Nắm các điểm Dart **khác** TypeScript: null safety chặt, class/constructor, `final`/`const`,
  record, pattern + `switch` expression, sealed class, extension, collection `if`/`for`.
- Biết tính năng mới nhất: **primary constructor** (Dart 3.13).
- Viết `async`/`await` với `Future`.

## Giải thích đơn giản

Learning Pathway chính thức đặt bước "Dart Getting Started" trước Flutter, nhưng nói người đã quen ngôn ngữ
hướng đối tượng hiện đại có thể đi nhanh. Bạn biết TypeScript, nên hãy nghĩ:

> Dart ≈ TypeScript **có kiểu thật lúc chạy** + class kiểu Java/C# + pattern matching kiểu C#/Kotlin.

| TypeScript | Dart | Ghi chú |
|---|---|---|
| `let x = 1` / `const x = 1` | `var x = 1` / `final x = 1` | Dart `const` = hằng **lúc biên dịch** |
| `string`, `number`, `boolean` | `String`, `int`/`double`/`num`, `bool` | `int` và `double` tách riêng |
| `string \| null` | `String?` | Null safety: mặc định **không** null |
| `x!` | `x!` | Giống nhau (ném lỗi nếu null) |
| `a ?? b`, `a?.b` | `a ?? b`, `a?.b` | Giống nhau |
| `` `Hi ${name}` `` | `'Hi $name'` / `'Hi ${user.name}'` | Chuỗi nháy đơn là quy ước |
| `interface` | `abstract interface class` / mọi class đều là interface ngầm | |
| `type A = B \| C` (union) | `sealed class` + các lớp con | Compiler kiểm tra đủ nhánh |
| `[a, b]` tuple | Record `(a, b)` / `(x: 1, y: 2)` | |
| `Promise<T>` | `Future<T>` | `async`/`await` y hệt |
| `Observable<T>` (RxJS) | `Stream<T>` | Có sẵn trong ngôn ngữ (Tập 2) |
| `Array<T>`, `Map`, `Set` | `List<T>`, `Map<K, V>`, `Set<T>` | |
| `arr.map(...).filter(...)` | `list.map(...).where(...).toList()` | `map` trả về Iterable lười (lazy) |
| `export`/`import` | `import 'package:app/x.dart';` | Tên bắt đầu `_` = private trong **file** |
| `npm` | `dart pub` / `flutter pub` | |

## Ví dụ

Toàn bộ ví dụ nằm trong một file Dart thuần: `examples/lib/chapters/ch03/dart_basics.dart`.

### Null safety và record

```dart
/// `String?` có thể null; `??` giống TypeScript.
String greet(String? name) => 'Xin chào, ${name ?? 'bạn'}!';

/// `int.tryParse` trả về `int?` (null nếu không phải số).
int? parseScore(String input) => int.tryParse(input.trim());

/// Trả về 2 giá trị một lúc mà không cần tạo class.
(int min, int max) minMax(List<int> numbers) {
  if (numbers.isEmpty) throw ArgumentError('Danh sách rỗng');
  var min = numbers.first, max = numbers.first;
  for (final n in numbers) {
    if (n < min) min = n;
    if (n > max) max = n;
  }
  return (min, max);
}

/// Record có tên: `({String word, String pos})`. Tách "negotiate (v)" → word + từ loại.
({String word, String pos})? parseEntry(String raw) {
  final match = RegExp(r'^\s*(.+?)\s*\((\w+)\)\s*$').firstMatch(raw);
  if (match == null) return null;
  return (word: match.group(1)!, pos: match.group(2)!);
}
```

Dùng: `final (min, max) = minMax([5, 1, 9, 3]);` — đây là **destructuring** bằng pattern, giống
`const [min, max] = ...` của TS. `r'...'` là chuỗi "raw" (không xử lý `\`), tiện cho RegExp.

### Pattern + `switch` expression

```dart
String describeScore(int score) => switch (score) {
  < 0 || > 990 => 'Điểm không hợp lệ',
  >= 900 => 'Xuất sắc',
  >= 785 => 'Tốt',
  >= 600 => 'Khá',
  _ => 'Cần cố gắng',
};
```

`switch` expression **trả về giá trị**, không có `break`, và dùng được *relational pattern* (`>= 900`),
*logical-or pattern* (`||`), và `_` (mặc định).

### Sealed class — "discriminated union" có kiểm tra đủ nhánh

```dart
sealed class LoadState<T> {
  const LoadState();
}

final class Loading<T> extends LoadState<T> {
  const Loading();
}

final class Success<T> extends LoadState<T> {
  const Success(this.data);
  final T data;
}

final class Failure<T> extends LoadState<T> {
  const Failure(this.message);
  final String message;
}

/// Thiếu một nhánh → lỗi compile (exhaustiveness checking).
String renderState(LoadState<List<String>> state) => switch (state) {
  Loading() => 'Đang tải…',
  Success(data: final words) when words.isEmpty => 'Chưa có từ nào',
  Success(data: final words) => 'Có ${words.length} từ: ${words.join(', ')}',
  Failure(:final message) => 'Lỗi: $message',
};
```

Trong TS bạn viết `type LoadState = {kind:'loading'} | {kind:'success', data} | ...` rồi `switch (s.kind)`.
Dart làm điều đó bằng `sealed class`: nếu bạn thêm lớp con mới mà quên xử lý, **compiler báo lỗi**.
`Failure(:final message)` là cú pháp ngắn của `Failure(message: final message)`. Mẫu `Result` trong kiến
trúc chính thức (Tập 3) dùng đúng kỹ thuật này.

### Class và constructor

```dart
class Vocabulary {
  const Vocabulary(this.word, this.meaning, {this.level = 1});

  final String word;
  final String meaning;
  final int level;

  /// Named constructor — TS không có; thường dùng cho fromJson.
  Vocabulary.fromMap(Map<String, Object?> map)
    : word = map['word'] as String,
      meaning = map['meaning'] as String,
      level = (map['level'] as int?) ?? 1;
}
```

- `this.word` trong tham số = gán thẳng vào field (ngắn gọn).
- `{this.level = 1}` = **named parameter** tùy chọn có giá trị mặc định. Gọi: `Vocabulary('a', 'b', level: 2)`.
  Muốn bắt buộc: `{required this.level}`. Flutter dùng named parameter ở khắp nơi (`Text('x', style: ...)`).
- `const` constructor: tạo đối tượng hằng lúc biên dịch → Flutter tái sử dụng, không build lại (Tập 3).
- **Dart 3.13 — primary constructor** (giống "parameter properties" của TypeScript):

```dart
class const WordPair(final String english, final String vietnamese) {
  String get display => '$english → $vietnamese';
}
```

Một dòng khai báo cả field lẫn constructor. `class const` cho constructor `const`. Tính năng này cần
`sdk: ^3.13.0` trong `pubspec.yaml` (dự án của sách: `^3.13.4`). Sách vẫn dùng cú pháp cổ điển là chính
vì hầu hết tài liệu và package hiện nay viết theo kiểu đó.

### Extension method — bỏ dấu tiếng Việt

```dart
extension VietnameseText on String {
  /// Bỏ dấu tiếng Việt: "Đàm phán" → "dam phan". Dùng cho tìm kiếm không dấu.
  String get withoutAccents {
    final buffer = StringBuffer();
    for (final ch in toLowerCase().split('')) {
      var out = ch;
      for (final entry in _accents.entries) {
        if (entry.value.contains(ch)) {
          out = entry.key;
          break;
        }
      }
      buffer.write(out);
    }
    return buffer.toString();
  }
}
```

(`_accents` là bảng `'a': 'àáạảã…'`, … trong cùng file.) Gọi như một getter có sẵn: `'Đàm phán'.withoutAccents`.
App TOEIC cần đúng hàm này để tìm từ "có dấu hoặc không dấu".

### Collection `if` / `for` / spread

```dart
List<String> buildMenu({required bool loggedIn, List<String> extra = const []}) => [
  'Trang chủ',
  if (loggedIn) 'Hồ sơ' else 'Đăng nhập',
  for (final item in extra) item.toUpperCase(),
  ...['Giới thiệu'],
];
```

Đây là "template" của Flutter: `children: [ if (x) A(), for (...) B(), ]` thay cho `@if`/`@for`.

### `async` / `await`

```dart
Future<Vocabulary> fetchWord(String word) async {
  await Future<void>.delayed(const Duration(milliseconds: 10)); // giả lập gọi mạng
  if (word.isEmpty) throw ArgumentError('word rỗng');
  return Vocabulary(word, 'nghĩa của $word');
}
```

Giống hệt TS. Khác: không có `Promise.all` mà là `Future.wait([...])`; lỗi bắt bằng `try/catch` hoặc
`.catchError`. Tập 2, Chương 2 đi sâu về Future, Stream, isolate.

### Kết quả test thật

`flutter test --reporter expanded test/chapters/ch03_test.dart` (2026-09-30):

```text
00:00 +0: Chương 3 — Dart cho TypeScript developer null safety: ?? và tryParse
00:00 +1: Chương 3 — Dart cho TypeScript developer record: minMax và parseEntry
00:00 +2: Chương 3 — Dart cho TypeScript developer switch expression với relational pattern
00:00 +3: Chương 3 — Dart cho TypeScript developer sealed class + pattern matching
00:00 +4: Chương 3 — Dart cho TypeScript developer class: named constructor, primary constructor (Dart 3.13)
00:00 +5: Chương 3 — Dart cho TypeScript developer extension: bỏ dấu tiếng Việt
00:00 +6: Chương 3 — Dart cho TypeScript developer collection if / for / spread
00:00 +7: Chương 3 — Dart cho TypeScript developer async/await
00:00 +8: Chương 3 — Dart cho TypeScript developer Bài 1: diện tích Shape
00:00 +9: Chương 3 — Dart cho TypeScript developer Bài 2: countWords
00:00 +10: All tests passed!
```

## Đi sâu

### `final` vs `const`

- `final x = DateTime.now();` — gán **một lần**, giá trị có thể tính lúc chạy (giống `const` của TS).
- `const x = Duration(seconds: 1);` — giá trị phải biết **lúc biên dịch**; mọi `const` giống nhau là **cùng một
  đối tượng**. Trong Flutter, `const Text('Lưu')` giúp framework bỏ qua việc build lại.
- Lint `prefer_const_constructors` (trong `flutter_lints`) nhắc bạn thêm `const`.

### Kiểu thật lúc chạy (reified generics)

TS xóa kiểu khi biên dịch sang JS; Dart **giữ** kiểu lúc chạy: `list is List<String>` hoạt động. Ép kiểu sai
(`map['x'] as int` khi giá trị là chuỗi) ném `TypeError` ngay. Dự án của sách bật `strict-casts` và
`strict-raw-types` trong `analysis_options.yaml` để bắt lỗi sớm hơn.

### Class modifier

Dart 3 có `sealed`, `final`, `base`, `interface`, `abstract`, `mixin`. Người mới chỉ cần nhớ:
`abstract interface class` ≈ `interface` của TS; `sealed` = union đóng; `final class` = không cho kế thừa bên ngoài thư viện.

### Mọi thứ là object, không có `undefined`

Không có `undefined`, chỉ có `null`. Không có "truthy/falsy": `if (list)` là lỗi; phải viết `if (list.isNotEmpty)`.
`==` gọi `operator ==` (so sánh giá trị nếu class override, như `Task` ở Chương 9).

## Lỗi và bẫy thường gặp

- **Dùng `!` bừa bãi** để "tắt" lỗi null → crash lúc chạy. Ưu tiên `??`, `?.`, hoặc kiểm tra `if (x != null)`.
- **Quên `.toList()`** sau `map`/`where`: nhận `Iterable` lười; mỗi lần duyệt lại tính lại.
- **`int` chia `int`**: `7 / 2 == 3.5` (double); chia lấy nguyên dùng `7 ~/ 2 == 3`.
- **Truthy như JS**: `if (name)` không biên dịch.
- **Dart 3.13 breaking change**: không viết `final`/`var` trước tham số thường nữa (`void f(final int x)` lỗi) —
  hai từ này giờ dành cho primary constructor.
- **Chuỗi tiếng Việt dạng tổ hợp (NFD)**: "á" có thể là 1 ký tự (NFC) hoặc "a" + dấu rời (NFD). Hàm
  `withoutAccents` ở trên chỉ xử lý NFC — dữ liệu từ nguồn lạ nên chuẩn hóa trước.

## Tóm tắt

- Dart ≈ TypeScript có kiểu thật lúc chạy, null safety chặt, class kiểu Java/C#.
- `final` (gán một lần) vs `const` (hằng biên dịch). Named parameter `{required ...}` có mặt khắp Flutter.
- Record + pattern + `switch` expression + `sealed class` = mô hình dữ liệu an toàn, gọn.
- Extension method thêm hàm vào kiểu có sẵn. Collection `if`/`for` là "template" của Flutter.
- Dart 3.13 có primary constructor.

## Bài tập (có lời giải)

**Bài 1.** Viết `sealed class Shape` với `Circle(radius)` và `Rectangle(width, height)`, và hàm `area(Shape)`
dùng `switch` expression.

<details>
<summary>Lời giải</summary>

`examples/lib/chapters/ch03/exercise_solution.dart`:

```dart
sealed class Shape {
  const Shape();
}

final class Circle extends Shape {
  const Circle(this.radius);
  final double radius;
}

final class Rectangle extends Shape {
  const Rectangle(this.width, this.height);
  final double width, height;
}

double area(Shape shape) => switch (shape) {
  Circle(:final radius) => math.pi * radius * radius,
  Rectangle(:final width, :final height) => width * height,
};
```

Thử thêm `final class Triangle extends Shape {}` mà không sửa `area` → `dart analyze` báo lỗi (chạy thật):

```text
error - bin/a.dart:4:25 - The type 'Shape' isn't exhaustively matched by the switch cases since it doesn't match
the pattern 'Triangle()'. Try adding a wildcard pattern or cases that match 'Triangle()'. - non_exhaustive_switch_expression
```

Đó là lợi ích của `sealed`.
</details>

**Bài 2.** Viết `countWords(String text) → Map<String, int>`: đếm số lần mỗi từ xuất hiện, không phân biệt
hoa thường, bỏ dấu câu, giữ chữ tiếng Việt có dấu.

<details>
<summary>Lời giải</summary>

```dart
Map<String, int> countWords(String text) {
  final counts = <String, int>{};
  final words = text.toLowerCase().split(RegExp(r"[^a-zA-ZÀ-ỹ']+")).where((w) => w.isNotEmpty);
  for (final w in words) {
    counts.update(w, (n) => n + 1, ifAbsent: () => 1);
  }
  return counts;
}
```

Test: `countWords('Deadline, deadline! Hạn chót.')` → `{'deadline': 2, 'hạn': 1, 'chót': 1}`.
`Map.update(..., ifAbsent:)` thay cho `counts[w] = (counts[w] ?? 0) + 1`. Dải ký tự `À-ỹ` bao gồm các chữ
Latin có dấu dùng trong tiếng Việt (kể cả `đ`, U+0111).
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30 (dart.dev bị chặn trong sandbox; đọc file nguồn repo `dart-lang/site-www` ở commit `001b59a`):

- Records — https://dart.dev/language/records —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/language/records.md
- Patterns — https://dart.dev/language/patterns —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/language/patterns.md
- Branches (switch expression) — https://dart.dev/language/branches —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/language/branches.md
- Class modifiers — https://dart.dev/language/class-modifiers —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/language/class-modifiers.md
- Primary constructors — https://dart.dev/language/primary-constructors —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/language/primary-constructors.md
- Extension methods — https://dart.dev/language/extension-methods —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/language/extension-methods.md
- Collections — https://dart.dev/language/collections —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/language/collections.md
- Asynchronous programming — https://dart.dev/language/async —
  https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/src/content/language/async.md
- Dart SDK CHANGELOG (3.13.0: primary constructors, breaking change `final`/`var`): https://github.com/dart-lang/sdk/blob/main/CHANGELOG.md
- Flutter for React Native developers (phần "Introduction to Dart for JavaScript Developers") — https://docs.flutter.dev/flutter-for/react-native-devs —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/flutter-for/react-native-devs.md
- Learning pathway (bước 2: Dart tutorial) — https://docs.flutter.dev/learn/pathway —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/learn/pathway/index.md
