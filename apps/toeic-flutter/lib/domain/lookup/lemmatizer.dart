// Port 1:1 từ Task 5: apps/toeic/src/features/lookup/lemmatize.ts
// Đổi một dạng từ thành các dạng gốc (lemma) có thể có, tốt nhất đứng đầu:
// "ran" -> run, "companies" -> company, "company's" -> company, "don't" -> do.
// Thứ tự luật: dạng đúng như gõ, bảng bất quy tắc (WordNet), rút gọn (contraction), sở hữu cách,
// rồi các luật hậu tố tiếng Anh (-ies, -es, -s, -ied, -ed, -ing, -er, -est).

class Normalized {
  const Normalized({required this.base, required this.full, this.contraction});

  /// chữ thường, đã bỏ sở hữu cách / phần rút gọn
  final String base;

  /// cả dạng như gõ, chữ thường (dấu nháy đã chuẩn hoá)
  final String full;

  /// ví dụ "don't = do not"
  final String? contraction;
}

const Map<String, (String, String)> _contractions = {
  "won't": ('will', 'will not'),
  "can't": ('can', 'cannot'),
  "shan't": ('shall', 'shall not'),
  "ain't": ('be', 'am not / is not'),
  "let's": ('let', 'let us'),
  "i'm": ('i', 'I am'),
};

const List<(String, String)> _suffixContractions = [
  ("n't", 'not'),
  ("'re", 'are'),
  ("'ve", 'have'),
  ("'ll", 'will'),
  ("'d", 'would / had'),
  ("'m", 'am'),
];

const Set<String> _sIsHas = {'it', 'he', 'she', 'that', 'what', 'there', 'here', 'who', 'where', 'how'};

final RegExp _curlyQuotes = RegExp('[’‘`]');
final RegExp _edges = RegExp(r"^[^A-Za-zÀ-ɏ]+|[^A-Za-zÀ-ɏ']+$");
final RegExp _leadingQuotes = RegExp(r"^'+");

Normalized normalizeToken(String raw) {
  final full = raw.replaceAll(_curlyQuotes, "'").replaceAll(_edges, '').replaceFirst(_leadingQuotes, '').toLowerCase();
  final special = _contractions[full];
  if (special != null) return Normalized(base: special.$1, full: full, contraction: '$full = ${special.$2}');
  for (final (suffix, meaning) in _suffixContractions) {
    if (full.endsWith(suffix) && full.length > suffix.length) {
      final stem = full.substring(0, full.length - suffix.length);
      return Normalized(base: stem, full: full, contraction: '$full = $stem $meaning');
    }
  }
  // sở hữu cách: company's -> company, companies' -> companies
  if (full.endsWith("'s")) {
    final stem = full.substring(0, full.length - 2);
    if (_sIsHas.contains(stem)) {
      return Normalized(base: stem, full: full, contraction: '$full = $stem is / $stem has');
    }
    return Normalized(base: stem, full: full);
  }
  if (full.endsWith("'")) return Normalized(base: full.substring(0, full.length - 1), full: full);
  return Normalized(base: full, full: full);
}

final RegExp _vowel = RegExp('[aeiou]');
final RegExp _esPlural = RegExp(r'(ss|sh|ch|x|z|o)es$');
final RegExp _doubleConsonant = RegExp(r'([bcdfghjklmnpqrstvz])\1$');

List<String> lemmaCandidates(String word, Map<String, String> irregular) {
  final w = word.toLowerCase();
  final out = <String>[w];
  void add(String? s) {
    if (s != null && s.length > 1 && !out.contains(s)) out.add(s);
  }

  String cut(int n) => w.substring(0, w.length - n);

  add(irregular[w]);
  final len = w.length;
  if (len > 3 && w.endsWith('ies')) add('${cut(3)}y');
  if (len > 3 && w.endsWith('ied')) add('${cut(3)}y');
  if (len > 4 && w.endsWith('iest')) add('${cut(4)}y');
  if (len > 3 && w.endsWith('ier')) add('${cut(3)}y');
  if (len > 3 && _esPlural.hasMatch(w)) add(cut(2));
  if (len > 2 && w.endsWith('s') && !w.endsWith('ss')) add(cut(1));
  if (len > 3 && w.endsWith('ed')) {
    final stem = cut(2);
    add(stem); // delivered -> deliver
    add(cut(1)); // approved -> approve
    if (_doubleConsonant.hasMatch(stem)) add(stem.substring(0, stem.length - 1)); // planned -> plan
  }
  if (len > 4 && w.endsWith('ing')) {
    final stem = cut(3);
    if (_vowel.hasMatch(stem)) {
      add(stem); // meeting -> meet
      add('${stem}e'); // negotiating -> negotiate
      if (_doubleConsonant.hasMatch(stem)) add(stem.substring(0, stem.length - 1)); // shipping -> ship
    }
  }
  if (len > 4 && w.endsWith('est')) {
    add(cut(3));
    add(cut(2));
  }
  if (len > 3 && w.endsWith('er')) {
    add(cut(2)); // cheaper -> cheap
    add(cut(1)); // safer -> safe
  }
  return out;
}
