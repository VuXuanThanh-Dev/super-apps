// Port từ Task 5: apps/toeic/src/features/lookup/dictionary.ts
import '../models/data_index.dart';
import '../models/dataset.dart';
import 'lemmatizer.dart';

/// Kết quả tra từ. `sealed` → `switch` phải xử lý đủ 4 trường hợp.
sealed class LookupResult {
  const LookupResult(this.query);

  /// Chữ người dùng đã chạm (đã bỏ khoảng trắng hai đầu).
  final String query;
}

/// Từ có trong bộ dữ liệu TOEIC (đầy đủ: nghĩa Việt, IPA, họ từ, collocation, ví dụ).
final class EntryResult extends LookupResult {
  const EntryResult(
    super.query, {
    required this.word,
    required this.family,
    required this.collocations,
    this.via,
    this.contraction,
  });

  final Word word;
  final List<Word> family;
  final List<Collocation> collocations;

  /// cách khớp dạng từ, ví dụ "ran → run"
  final String? via;
  final String? contraction;
}

/// Từ chức năng thường gặp (the, do, of…).
final class FunctionWordResult extends LookupResult {
  const FunctionWordResult(super.query, {required this.lemma, required this.info, this.via, this.contraction});

  final String lemma;
  final FunctionWord info;
  final String? via;
  final String? contraction;
}

/// Định nghĩa dự phòng từ WordNet 3.0 (chưa có nghĩa tiếng Việt).
final class GlossResult extends LookupResult {
  const GlossResult(super.query, {required this.lemma, required this.gloss, this.via, this.contraction});

  final String lemma;
  final Gloss gloss;
  final String? via;
  final String? contraction;
}

final class NotFoundResult extends LookupResult {
  const NotFoundResult(super.query);
}

/// Từ điển offline: từ trong sách trước, rồi từ chức năng, rồi WordNet; không có → "not found".
/// Chỉ đọc dữ liệu trong bộ nhớ — không gọi mạng.
class Dictionary {
  const Dictionary({
    required this.index,
    required this.functionWords,
    required this.genericGlosses,
    required this.irregular,
  });

  final DataIndex index;
  final Map<String, FunctionWord> functionWords;
  final Map<String, Gloss> genericGlosses;
  final Map<String, String> irregular;

  LookupResult lookup(String raw) {
    final query = raw.trim();
    final norm = normalizeToken(query);
    if (norm.base.isEmpty) return NotFoundResult(query);
    final candidates = <String>[];
    for (final c in [norm.full, ...lemmaCandidates(norm.base, irregular)]) {
      if (c.isNotEmpty && !candidates.contains(c)) candidates.add(c);
    }
    String? via(String c) => c != norm.full ? '${norm.full} → $c' : null;

    for (final c in candidates) {
      final word = index.wordsByText[c];
      if (word != null) {
        return EntryResult(
          query,
          word: word,
          family: index.familyMembers(word.family),
          collocations: index.collocationsForWord(word),
          via: via(c),
          contraction: norm.contraction,
        );
      }
    }
    for (final c in candidates) {
      final info = functionWords[c];
      if (info != null) {
        return FunctionWordResult(query, lemma: c, info: info, via: via(c), contraction: norm.contraction);
      }
    }
    for (final c in candidates) {
      final gloss = index.dataset.glosses[c] ?? genericGlosses[c];
      if (gloss != null) return GlossResult(query, lemma: c, gloss: gloss, via: via(c), contraction: norm.contraction);
    }
    return NotFoundResult(query);
  }
}
