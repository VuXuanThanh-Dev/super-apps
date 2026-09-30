// Port từ Task 5 (vocabulary/search.ts, practice/scope.ts).
import '../../utils/vietnamese.dart';
import '../models/data_index.dart';
import '../models/dataset.dart';

/// Tìm theo từ tiếng Anh, nghĩa tiếng Việt (có/không dấu) và định nghĩa.
/// Thứ tự: đúng từ, bắt đầu bằng, chứa, khớp nghĩa Việt, khớp định nghĩa.
List<Word> searchWords(DataIndex index, String query, {String? topic, int limit = 100}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final qFold = q.withoutAccents;
  final scored = <(Word, int)>[];
  for (final w in index.words) {
    if (topic != null && w.topic != topic) continue;
    final word = w.word.toLowerCase();
    var score = -1;
    if (word == q) {
      score = 0;
    } else if (word.startsWith(q)) {
      score = 1;
    } else if (word.contains(q)) {
      score = 2;
    } else if (w.vi != null && w.vi!.withoutAccents.contains(qFold)) {
      score = 3;
    } else if (w.definition != null && w.definition!.toLowerCase().contains(q)) {
      score = 4;
    }
    if (score >= 0) scored.add((w, score));
  }
  scored.sort((a, b) => a.$2 != b.$2 ? a.$2.compareTo(b.$2) : a.$1.word.compareTo(b.$1.word));
  return [for (final s in scored.take(limit)) s.$1];
}

class TopicSummary {
  const TopicSummary({required this.topic, required this.families, required this.words});

  final Topic topic;
  final int families;
  final int words;
}

List<TopicSummary> topicSummaries(DataIndex index) => [
  for (final t in index.topics)
    TopicSummary(topic: t, families: index.familiesInTopic(t.code).length, words: index.wordsInTopic(t.code).length),
];

String bookLabel(String book) => switch (book) {
  'tap1' => 'Tập 1',
  'tap2' => 'Tập 2',
  'mine' => 'My words',
  _ => 'Sample',
};

/// Phạm vi học: tất cả, từ đã lưu, từ yếu, hoặc một unit (mã chủ đề).
sealed class StudyScope {
  const StudyScope();

  static StudyScope parse(String value) => switch (value) {
    'all' => const AllWords(),
    'saved' => const SavedWords(),
    'weak' => const WeakWordsScope(),
    _ => TopicScope(value),
  };

  String get id;
}

final class AllWords extends StudyScope {
  const AllWords();
  @override
  String get id => 'all';
}

final class SavedWords extends StudyScope {
  const SavedWords();
  @override
  String get id => 'saved';
}

final class WeakWordsScope extends StudyScope {
  const WeakWordsScope();
  @override
  String get id => 'weak';
}

final class TopicScope extends StudyScope {
  const TopicScope(this.code);
  final String code;
  @override
  String get id => code;
}

String scopeLabel(StudyScope scope, DataIndex index) => switch (scope) {
  AllWords() => 'All words',
  SavedWords() => 'Saved words',
  WeakWordsScope() => 'Weak words',
  TopicScope(:final code) => switch (index.topicsByCode[code]) {
    final t? => '${t.code} · ${t.en}',
    null => code,
  },
};

List<Word> wordsForScope(
  StudyScope scope,
  DataIndex index, {
  List<String> saved = const [],
  List<String> weak = const [],
}) => switch (scope) {
  AllWords() => index.words,
  SavedWords() => [for (final k in saved) ?index.wordByKey(k)],
  WeakWordsScope() => [for (final k in weak) ?index.wordByKey(k)],
  TopicScope(:final code) => index.wordsInTopic(code),
};
