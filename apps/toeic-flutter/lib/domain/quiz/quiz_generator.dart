// Port từ Task 5 (quiz/generators.ts): 5 loại quiz.
import '../../utils/random.dart';
import '../models/data_index.dart';
import '../models/dataset.dart';

enum QuizType {
  meaning('Meaning', 'Chọn nghĩa đúng'),
  blank('Fill in the blank', 'Điền từ vào chỗ trống'),
  family('Word family form', 'Chọn dạng từ đúng'),
  collocation('Collocation matching', 'Nối cụm từ với nghĩa'),
  listening('Listening', 'Nghe và chọn từ');

  const QuizType(this.title, this.vi);
  final String title;
  final String vi;
}

sealed class QuizQuestion {
  const QuizQuestion(this.type);
  final QuizType type;
}

/// Câu hỏi chọn 1 trong nhiều đáp án.
final class ChoiceQuestion extends QuizQuestion {
  const ChoiceQuestion(
    super.type, {
    required this.prompt,
    required this.options,
    required this.answer,
    required this.word,
    this.hint,
    this.speakText,
  });

  final String prompt;
  final String? hint;
  final List<String> options;
  final int answer;

  /// khoá của từ (chữ thường) để thống kê
  final String word;

  /// chữ cần đọc to (quiz nghe)
  final String? speakText;
}

/// Nối cụm từ (trái) với nghĩa (phải): left[i] khớp right[answer[i]].
final class MatchQuestion extends QuizQuestion {
  const MatchQuestion({required this.left, required this.right, required this.answer, required this.words})
    : super(QuizType.collocation);

  final List<String> left;
  final List<String> right;
  final List<int> answer;
  final List<String> words;

  bool isCorrect(List<int?> chosen) {
    for (var i = 0; i < answer.length; i++) {
      if (i >= chosen.length || chosen[i] != answer[i]) return false;
    }
    return true;
  }
}

const String blank = '_____';

/// Tìm đúng từ [form] (không phân biệt hoa thường) trong câu và thay bằng chỗ trống.
String? blankOut(String sentence, String form) {
  final re = RegExp("(^|[^A-Za-z'-])(${RegExp.escape(form)})(?=\$|[^A-Za-z'-])", caseSensitive: false);
  final m = re.firstMatch(sentence);
  if (m == null) return null;
  return sentence.replaceRange(m.start, m.end, '${m.group(1)}$blank');
}

List<String> _distinct(Iterable<String> values) => {
  for (final v in values)
    if (v.trim().isNotEmpty) v,
}.toList();

({List<String> options, int answer})? _choiceFrom(String correct, Iterable<String> distractors, Rng rng, [int n = 4]) {
  final others = pick(_distinct(distractors).where((d) => d.toLowerCase() != correct.toLowerCase()), n - 1, rng);
  if (others.isEmpty) return null;
  final options = shuffle([correct, ...others], rng);
  return (options: options, answer: options.indexOf(correct));
}

List<Word> _samePosFirst(Word word, List<Word> pool) {
  final main = word.pos.split('/').first;
  final same = pool.where((w) => w.pos.split('/').first == main).toList();
  return same.length >= 3 ? same : pool;
}

ChoiceQuestion? meaningQuestion(Word word, List<Word> pool, Rng rng) {
  final correct = word.vi ?? word.definition;
  if (correct == null) return null;
  final others = pool.where((w) => w.family != word.family).map((w) => (word.vi != null ? w.vi : w.definition) ?? '');
  final c = _choiceFrom(correct, others, rng);
  if (c == null) return null;
  return ChoiceQuestion(
    QuizType.meaning,
    prompt: word.word,
    hint: [word.pos, word.ipa].whereType<String>().where((s) => s.isNotEmpty).join('  '),
    options: c.options,
    answer: c.answer,
    word: word.key,
  );
}

ChoiceQuestion? blankQuestion(Word word, List<Word> pool, Rng rng) {
  final example = word.example;
  if (example == null) return null;
  final sentence = blankOut(example, word.word);
  if (sentence == null) return null;
  final others = _samePosFirst(word, pool.where((w) => w.family != word.family).toList()).map((w) => w.word);
  final c = _choiceFrom(word.word, others, rng);
  if (c == null) return null;
  return ChoiceQuestion(
    QuizType.blank,
    prompt: sentence,
    hint: word.vi,
    options: c.options,
    answer: c.answer,
    word: word.key,
  );
}

ChoiceQuestion? familyQuestion(Word word, DataIndex index, Rng rng) {
  final example = word.example;
  if (example == null) return null;
  final members = index.familyMembers(word.family).where((m) => !m.word.contains(' ')).toList();
  if (members.length < 2) return null;
  final sentence = blankOut(example, word.word);
  if (sentence == null) return null;
  final c = _choiceFrom(word.word, members.map((m) => m.word), rng);
  if (c == null) return null;
  return ChoiceQuestion(
    QuizType.family,
    prompt: sentence,
    hint: 'Word family: ${index.familiesById[word.family]?.headword ?? ''}',
    options: c.options,
    answer: c.answer,
    word: word.key,
  );
}

ChoiceQuestion? listeningQuestion(Word word, List<Word> pool, Rng rng) {
  final c = _choiceFrom(word.word, pool.where((w) => w.id != word.id).map((w) => w.word), rng);
  if (c == null) return null;
  return ChoiceQuestion(
    QuizType.listening,
    prompt: 'Listen and choose the word you hear.',
    options: c.options,
    answer: c.answer,
    word: word.key,
    speakText: word.word,
  );
}

MatchQuestion? collocationQuestion(List<Collocation> collocations, DataIndex index, Rng rng, [int size = 4]) {
  final unique = <String, Collocation>{};
  for (final c in shuffle(collocations, rng)) {
    if (c.vi.isNotEmpty) unique.putIfAbsent(c.vi, () => c);
  }
  final chosen = unique.values.take(size).toList();
  if (chosen.length < 2) return null;
  final order = shuffle(List.generate(chosen.length, (i) => i), rng);
  return MatchQuestion(
    left: [for (final c in chosen) c.phrase],
    right: [for (final i in order) chosen[i].vi],
    answer: [for (var i = 0; i < chosen.length; i++) order.indexOf(i)],
    words: [for (final c in chosen) (index.familiesById[c.family]?.headword ?? '').toLowerCase()],
  );
}

/// Tạo quiz [count] câu từ danh sách từ (ví dụ một unit).
List<QuizQuestion> generateQuiz(QuizType type, List<Word> words, DataIndex index, Rng rng, [int count = 10]) {
  final pool = words.length >= 4 ? words : index.words;
  final out = <QuizQuestion>[];
  if (type == QuizType.collocation) {
    final famIds = {for (final w in words) w.family};
    final cols = index.dataset.collocations.where((c) => famIds.contains(c.family)).toList();
    final source = cols.length >= 4 ? cols : index.dataset.collocations;
    final rounds = (count / 4).ceil().clamp(1, 1 << 30);
    for (var i = 0; i < rounds * 3 && out.length < rounds; i++) {
      final q = collocationQuestion(source, index, rng);
      if (q != null) out.add(q);
    }
    return out;
  }
  for (final w in shuffle(words, rng)) {
    if (out.length >= count) break;
    final q = switch (type) {
      QuizType.meaning => meaningQuestion(w, pool, rng),
      QuizType.blank => blankQuestion(w, pool, rng),
      QuizType.family => familyQuestion(w, index, rng),
      _ => listeningQuestion(w, pool, rng),
    };
    if (q != null) out.add(q);
  }
  return out;
}
