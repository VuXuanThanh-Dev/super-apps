// Port 1:1 từ Task 5: apps/toeic/src/features/lookup/tokenize.ts

/// Một mảnh chữ để hiển thị. [isWord] = có thể chạm để tra nghĩa.
class Token {
  const Token(this.text, {required this.isWord});

  final String text;
  final bool isWord;

  @override
  bool operator ==(Object other) => other is Token && other.text == text && other.isWord == isWord;

  @override
  int get hashCode => Object.hash(text, isWord);

  @override
  String toString() => isWord ? 'W($text)' : 'T($text)';
}

/// Một từ = chữ cái, có thể nối bằng dấu nháy hoặc gạch nối: "company's", "don't", "long-term", "Ms".
/// Số và dấu câu không phải là từ.
final RegExp wordPattern = RegExp(r"[A-Za-zÀ-ɏ]+(?:['’\-][A-Za-zÀ-ɏ]+)*");

/// Tách [text] thành các token. Giữ MỌI ký tự: nối tất cả token lại sẽ được đúng chuỗi ban đầu.
List<Token> tokenize(String text) {
  final tokens = <Token>[];
  var last = 0;
  for (final m in wordPattern.allMatches(text)) {
    if (m.start > last) tokens.add(Token(text.substring(last, m.start), isWord: false));
    tokens.add(Token(m.group(0)!, isWord: true));
    last = m.end;
  }
  if (last < text.length) tokens.add(Token(text.substring(last), isWord: false));
  return tokens;
}
