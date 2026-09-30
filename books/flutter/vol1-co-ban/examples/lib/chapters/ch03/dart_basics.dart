// Chương 3 — Dart cho TypeScript developer. File này chỉ dùng Dart thuần (không Flutter).

// ---------- 1. Null safety ----------
/// `String?` có thể null; `??` giống TypeScript.
String greet(String? name) => 'Xin chào, ${name ?? 'bạn'}!';

/// `int.tryParse` trả về `int?` (null nếu không phải số).
int? parseScore(String input) => int.tryParse(input.trim());

// ---------- 2. Record (giống tuple của TS) ----------
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

// ---------- 3. Pattern + switch expression ----------
/// Không có `break`, trả về giá trị, và compiler kiểm tra đủ trường hợp.
String describeScore(int score) => switch (score) {
  < 0 || > 990 => 'Điểm không hợp lệ',
  >= 900 => 'Xuất sắc',
  >= 785 => 'Tốt',
  >= 600 => 'Khá',
  _ => 'Cần cố gắng',
};

// ---------- 4. Sealed class (giống discriminated union của TS) ----------
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

// ---------- 5. Class: constructor ngắn, named/optional params, const ----------
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

  @override
  String toString() => '$word = $meaning (cấp $level)';
}

/// Dart 3.13: primary constructor — giống "parameter properties" của TypeScript
/// (`constructor(public readonly word: string) {}`). Viết `class const` để có const constructor.
class const WordPair(final String english, final String vietnamese) {
  String get display => '$english → $vietnamese';
}

// ---------- 6. Extension method ----------
const _accents = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'e': 'èéẹẻẽêềếệểễ',
  'i': 'ìíịỉĩ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'u': 'ùúụủũưừứựửữ',
  'y': 'ỳýỵỷỹ',
  'd': 'đ',
};

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

// ---------- 7. Collection if / for / spread ----------
List<String> buildMenu({required bool loggedIn, List<String> extra = const []}) => [
  'Trang chủ',
  if (loggedIn) 'Hồ sơ' else 'Đăng nhập',
  for (final item in extra) item.toUpperCase(),
  ...['Giới thiệu'],
];

// ---------- 8. async / await (Future ~ Promise) ----------
Future<Vocabulary> fetchWord(String word) async {
  await Future<void>.delayed(const Duration(milliseconds: 10)); // giả lập gọi mạng
  if (word.isEmpty) throw ArgumentError('word rỗng');
  return Vocabulary(word, 'nghĩa của $word');
}
