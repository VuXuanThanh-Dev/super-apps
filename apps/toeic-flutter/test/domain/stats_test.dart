// Port 1:1 từ Task 5: apps/toeic/src/features/stats/__tests__/stats.test.ts
import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_flutter/domain/models/user_data.dart';
import 'package:toeic_flutter/domain/srs/sm2.dart';
import 'package:toeic_flutter/domain/stats/stats.dart';
import 'package:toeic_flutter/utils/dates.dart';

ActivityDay day(String s, [int reviews = 1]) => ActivityDay(day: s, reviews: reviews);

void main() {
  final today = dayNumberFromString('2026-09-28');

  group('streak', () {
    test('counts consecutive days ending today', () {
      expect(computeStreak([day('2026-09-26'), day('2026-09-27'), day('2026-09-28')], today), 3);
    });
    test('still counts if today is not done yet (ends yesterday)', () {
      expect(computeStreak([day('2026-09-26'), day('2026-09-27')], today), 2);
    });
    test('breaks on a missing day and ignores empty days', () {
      expect(computeStreak([day('2026-09-25'), day('2026-09-27', 0), day('2026-09-28')], today), 1);
      expect(computeStreak([], today), 0);
    });
  });

  group('words learned, weak words, summary', () {
    final cards = [
      newCard('run', 0).copyWith(repetitions: 2),
      newCard('book', 0).copyWith(repetitions: 1, due: today - 1),
      newCard('delay', 0).copyWith(repetitions: 0, lapses: 2, due: today + 3),
    ];
    test('counts cards with 2+ successful reviews as learned', () {
      expect(wordsLearned(cards), 1);
    });
    test('orders weak words by accuracy then wrong count, adding flashcard lapses', () {
      final w = weakWords(const [
        WordStat(word: 'run', correct: 5, wrong: 1, lastSeen: 1),
        WordStat(word: 'delay', correct: 1, wrong: 1, lastSeen: 1),
        WordStat(word: 'ticket', correct: 0, wrong: 2, lastSeen: 1),
        WordStat(word: 'book', correct: 3, wrong: 0, lastSeen: 1),
      ], cards);
      expect(w.map((x) => x.word), ['ticket', 'delay', 'run']);
      expect((w[1].word, w[1].wrong, w[1].correct, w[1].accuracy), ('delay', 3, 1, 0.25));
    });
    test('summarizes progress', () {
      final s = summarize(cards, [day('2026-09-28', 4)], today);
      expect((s.learned, s.studied, s.due, s.streak, s.totalReviews), (1, 3, 2, 1, 4));
    });
    test('builds the last 7 days chart data', () {
      final d = lastDays([day('2026-09-28', 3), day('2026-09-22', 2)], today);
      expect(d, hasLength(7));
      expect(dayStringFromNumber(d.first.day), '2026-09-22');
      expect(d.map((x) => x.count), [2, 0, 0, 0, 0, 0, 3]);
    });
  });

  group('dates', () {
    test('local day string and day numbers round trip', () {
      expect(localDayString(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
      expect(dayNumber(DateTime(2026, 1, 5, 23, 59)) + 1, dayNumber(DateTime(2026, 1, 6, 0, 1)));
      expect(dayStringFromNumber(dayNumberFromString('2026-09-28')), '2026-09-28');
    });
  });
}
