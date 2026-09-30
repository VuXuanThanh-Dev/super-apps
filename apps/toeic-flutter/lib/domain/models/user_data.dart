// Dữ liệu người dùng lưu trên máy (SQLite trong app, bộ nhớ trong test) — port từ Task 5 (storage/types.ts).
// Khoá là chữ thường của từ, nên dữ liệu đã lưu vẫn còn sau khi build lại bộ dữ liệu.

/// Thẻ flashcard theo SM-2.
class Card {
  const Card({
    required this.word,
    this.ease = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    required this.due,
    this.lastReview,
    this.lapses = 0,
  });

  final String word;
  final double ease; // hệ số dễ (E-Factor) >= 1.3
  final int interval; // số ngày
  final int repetitions; // số lần nhớ đúng liên tiếp
  final int due; // số ngày (xem utils/dates.dart)
  final int? lastReview;
  final int lapses; // số lần quên sau khi đã nhớ

  Card copyWith({double? ease, int? interval, int? repetitions, int? due, int? lastReview, int? lapses}) => Card(
    word: word,
    ease: ease ?? this.ease,
    interval: interval ?? this.interval,
    repetitions: repetitions ?? this.repetitions,
    due: due ?? this.due,
    lastReview: lastReview ?? this.lastReview,
    lapses: lapses ?? this.lapses,
  );

  @override
  String toString() => 'Card($word, ease=$ease, interval=$interval, reps=$repetitions, due=$due, lapses=$lapses)';
}

/// Số câu trả lời đúng / sai của một từ (quiz).
class WordStat {
  const WordStat({required this.word, required this.correct, required this.wrong, required this.lastSeen});

  final String word;
  final int correct;
  final int wrong;
  final int lastSeen;
}

/// Hoạt động trong một ngày (YYYY-MM-DD, giờ địa phương).
class ActivityDay {
  const ActivityDay({required this.day, this.reviews = 0, this.quizzes = 0, this.reads = 0});

  final String day;
  final int reviews;
  final int quizzes;
  final int reads;

  int get total => reviews + quizzes + reads;
}

enum ActivityKind { review, quiz, read }

class SavedWord {
  const SavedWord({required this.word, required this.addedAt});

  final String word;
  final int addedAt; // millisecondsSinceEpoch
}
