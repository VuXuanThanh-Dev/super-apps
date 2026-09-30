// Port từ Task 5: apps/toeic/src/features/quiz/__tests__/generators.test.ts
import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_flutter/data/repositories/dataset_repository.dart';
import 'package:toeic_flutter/domain/quiz/quiz_generator.dart';
import 'package:toeic_flutter/utils/random.dart';

import '../../testing/sample_data.dart';

void main() {
  late DatasetRepository repo;
  setUpAll(() async => repo = await loadSampleRepository());

  group('quiz helpers', () {
    test('blanks out the exact word only', () {
      expect(blankOut('The manager met the management.', 'manager'), 'The $blank met the management.');
      expect(blankOut('Book a room.', 'book'), '$blank a room.');
      expect(blankOut('No match here.', 'ticket'), isNull);
    });

    test('shuffle is deterministic with a seed and keeps all items', () {
      final a = shuffle([1, 2, 3, 4, 5], mulberry32(7));
      final b = shuffle([1, 2, 3, 4, 5], mulberry32(7));
      expect(a, b);
      expect([...a]..sort(), [1, 2, 3, 4, 5]);
    });

    test('mulberry32 matches the JavaScript version of Task 5 (same seed, same numbers)', () {
      // Giá trị tham chiếu tính bằng Node 22 với hàm mulberry32 của apps/toeic/src/features/quiz/random.ts.
      final r = mulberry32(42);
      expect([r(), r(), r()], [0.6011037519201636, 0.44829055899754167, 0.8524657934904099]);
    });
  });

  for (final type in QuizType.values.where((t) => t != QuizType.collocation)) {
    group('${type.name} quiz', () {
      late List<ChoiceQuestion> qs;
      setUpAll(() => qs = generateQuiz(type, repo.index.words, repo.index, mulberry32(42), 6).cast<ChoiceQuestion>());

      test('makes questions with a valid answer among unique options', () {
        expect(qs, isNotEmpty);
        for (final q in qs) {
          expect(q.options.length, greaterThanOrEqualTo(2));
          expect(q.options.map((o) => o.toLowerCase()).toSet().length, q.options.length);
          expect(q.answer, inInclusiveRange(0, q.options.length - 1));
        }
      });

      test('points the answer at the right word', () {
        for (final q in qs) {
          final w = repo.index.wordsByText[q.word];
          expect(w, isNotNull);
          if (type == QuizType.meaning) {
            expect(q.options[q.answer], w!.vi);
          } else {
            expect(q.options[q.answer].toLowerCase(), q.word);
          }
          if (type == QuizType.blank || type == QuizType.family) expect(q.prompt, contains(blank));
          if (type == QuizType.listening) expect(q.speakText, w!.word);
        }
      });
    });
  }

  group('word family quiz', () {
    test('uses members of the same family as options', () {
      final qs = generateQuiz(QuizType.family, repo.index.words, repo.index, mulberry32(3), 10).cast<ChoiceQuestion>();
      for (final q in qs) {
        final fam = repo.index.familyMembers(repo.index.wordsByText[q.word]!.family).map((w) => w.word);
        for (final o in q.options) {
          expect(fam, contains(o));
        }
      }
    });
  });

  group('collocation matching quiz', () {
    test('makes matching sets whose answer key is a permutation', () {
      final qs = generateQuiz(QuizType.collocation, repo.index.words, repo.index, mulberry32(5), 8).cast<MatchQuestion>();
      expect(qs, isNotEmpty);
      for (final q in qs) {
        expect(q.left.length, q.right.length);
        expect([...q.answer]..sort(), List.generate(q.left.length, (i) => i));
        for (var i = 0; i < q.left.length; i++) {
          final col = repo.index.dataset.collocations.firstWhere((c) => c.phrase == q.left[i]);
          expect(q.right[q.answer[i]], col.vi);
        }
        expect(q.isCorrect(q.answer), isTrue);
        expect(q.isCorrect(q.answer.reversed.toList()), q.answer.length == 1);
      }
    });
  });
}
