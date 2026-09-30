// Port 1:1 từ Task 5: apps/toeic/src/features/flashcards/__tests__/sm2.test.ts
import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_flutter/data/repositories/dataset_repository.dart';
import 'package:toeic_flutter/domain/models/user_data.dart';
import 'package:toeic_flutter/domain/srs/queue.dart';
import 'package:toeic_flutter/domain/srs/sm2.dart';

import '../../testing/sample_data.dart';

void main() {
  group('SM-2', () {
    const today = 20000;

    test('starts with ease 2.5 and due today', () {
      final c = newCard('Run', today);
      expect((c.word, c.ease, c.interval, c.repetitions, c.due), ('run', 2.5, 0, 0, today));
    });

    test('follows the 1 day, 6 days, then interval × ease schedule', () {
      var c = newCard('run', today);
      c = review(c, Grade.good, today);
      expect((c.interval, c.repetitions, c.due, c.ease), (1, 1, today + 1, 2.5));
      c = review(c, Grade.good, today + 1);
      expect((c.interval, c.repetitions, c.due), (6, 2, today + 7));
      c = review(c, Grade.good, today + 7);
      expect(c.interval, 15); // round(6 * 2.5)
      expect(isLearned(c), isTrue);
    });

    test('easy raises ease, hard lowers it, never below 1.3', () {
      expect(review(newCard('a', today), Grade.easy, today).ease, 2.6);
      expect(review(newCard('a', today), Grade.hard, today).ease, 2.36);
      var c = newCard('a', today);
      for (var i = 0; i < 20; i++) {
        c = review(c, Grade.hard, today);
      }
      expect(c.ease, 1.3);
    });

    test('again does not change the ease factor (original SM-2)', () {
      expect(review(newCard('a', today), Grade.again, today).ease, 2.5);
    });

    test('again resets repetitions and counts a lapse', () {
      var c = review(review(newCard('a', today), Grade.good, today), Grade.good, today + 1);
      c = review(c, Grade.again, today + 7);
      expect((c.repetitions, c.interval, c.lapses, c.due), (0, 1, 1, today + 8));
      expect(isLearned(c), isFalse);
    });

    test('preview shows the next interval for each button', () {
      final c = newCard('a', today);
      expect([for (final g in Grade.values) previewInterval(c, g, today)], [1, 1, 1, 1]);
    });
  });

  group('study queue', () {
    late DatasetRepository repo;
    setUpAll(() async => repo = await loadSampleRepository());
    const today = 100;

    test('puts due cards first (oldest first), then new words up to the limit', () {
      final cards = <Card>[
        newCard('meeting', 0).copyWith(due: 99, repetitions: 1, interval: 1),
        newCard('company', 0).copyWith(due: 90, repetitions: 1, interval: 1),
        newCard('ticket', 0).copyWith(due: 150, repetitions: 3, interval: 20),
      ];
      final q = buildQueue(repo.index.words, cards, today: today, newLimit: 3);
      expect(q.take(2).map((w) => w.word), ['company', 'meeting']);
      expect(q, hasLength(5));
      expect(q.map((w) => w.word), isNot(contains('ticket')));
    });
  });
}
