// Port từ Task 5 (stats/stats.ts): thống kê tiến độ.
import '../../utils/dates.dart';
import '../models/user_data.dart';
import '../srs/sm2.dart';

/// Số ngày liên tiếp có học (tính tới hôm nay, hoặc hôm qua nếu hôm nay chưa học).
int computeStreak(List<ActivityDay> activity, int today) {
  final days = {
    for (final a in activity)
      if (a.total > 0) dayNumberFromString(a.day),
  };
  var d = days.contains(today) ? today : today - 1;
  var streak = 0;
  while (days.contains(d)) {
    streak += 1;
    d -= 1;
  }
  return streak;
}

int wordsLearned(List<Card> cards) => cards.where(isLearned).length;

int dueCount(List<Card> cards, int today) => cards.where((c) => c.due <= today).length;

class WeakWord {
  const WeakWord({required this.word, required this.wrong, required this.correct, required this.accuracy});

  final String word;
  final int wrong;
  final int correct;
  final double accuracy; // 0..1
}

/// Từ yếu: sai ít nhất một lần; độ chính xác thấp nhất trước, rồi sai nhiều nhất.
List<WeakWord> weakWords(List<WordStat> stats, List<Card> cards, {int limit = 10}) {
  final lapses = {for (final c in cards) c.word: c.lapses};
  final list = [
    for (final s in stats)
      () {
        final wrong = s.wrong + (lapses[s.word] ?? 0);
        final total = s.correct + wrong;
        return WeakWord(word: s.word, wrong: wrong, correct: s.correct, accuracy: total > 0 ? s.correct / total : 1);
      }(),
  ].where((w) => w.wrong > 0).toList();
  list.sort((a, b) {
    final byAcc = a.accuracy.compareTo(b.accuracy);
    if (byAcc != 0) return byAcc;
    final byWrong = b.wrong.compareTo(a.wrong);
    return byWrong != 0 ? byWrong : a.word.compareTo(b.word);
  });
  return list.take(limit).toList();
}

class Summary {
  const Summary({
    required this.learned,
    required this.studied,
    required this.due,
    required this.streak,
    required this.totalReviews,
    required this.totalQuizzes,
  });

  final int learned;
  final int studied;
  final int due;
  final int streak;
  final int totalReviews;
  final int totalQuizzes;
}

Summary summarize(List<Card> cards, List<ActivityDay> activity, int today) => Summary(
  learned: wordsLearned(cards),
  studied: cards.length,
  due: dueCount(cards, today),
  streak: computeStreak(activity, today),
  totalReviews: activity.fold(0, (n, a) => n + a.reviews),
  totalQuizzes: activity.fold(0, (n, a) => n + a.quizzes),
);

/// N ngày gần nhất (cũ nhất trước), ngày trống = 0.
List<({int day, int count})> lastDays(List<ActivityDay> activity, int today, [int n = 7]) {
  final byDay = {for (final a in activity) dayNumberFromString(a.day): a.total};
  return [for (var i = 0; i < n; i++) (day: today - (n - 1 - i), count: byDay[today - (n - 1 - i)] ?? 0)];
}
