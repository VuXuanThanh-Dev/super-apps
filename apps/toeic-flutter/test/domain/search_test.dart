// Port từ Task 5: apps/toeic/src/features/vocabulary/__tests__/search.test.ts (+ scope.ts)
import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_flutter/data/repositories/dataset_repository.dart';
import 'package:toeic_flutter/domain/reminders/reminder_text.dart';
import 'package:toeic_flutter/domain/vocabulary/search.dart';
import 'package:toeic_flutter/utils/vietnamese.dart';

import '../../testing/sample_data.dart';

void main() {
  late DatasetRepository repo;
  setUpAll(() async => repo = await loadSampleRepository());

  group('vocabulary search', () {
    test('finds English words, exact match first', () {
      final r = searchWords(repo.index, 'manage');
      expect(r.first.word, 'manage');
      expect(r.map((w) => w.word), containsAll(['manager', 'management']));
    });

    test('is case-insensitive and trims', () {
      expect(searchWords(repo.index, '  TICKET ').first.word, 'ticket');
    });

    test('finds Vietnamese meanings with or without accents', () {
      expect(searchWords(repo.index, 'công ty').first.word, 'company');
      expect(searchWords(repo.index, 'cong ty').first.word, 'company');
      expect('Đặt chỗ'.withoutAccents, 'dat cho');
    });

    test('can filter by unit', () {
      final r = searchWords(repo.index, 'e', topic: 'S2');
      expect(r, isNotEmpty);
      expect(r.every((w) => w.topic == 'S2'), isTrue);
    });

    test('returns nothing for an empty query', () {
      expect(searchWords(repo.index, '   '), isEmpty);
    });

    test('summarizes units with counts', () {
      final s = topicSummaries(repo.index);
      expect(s.map((t) => t.topic.code), ['S1', 'S2']);
      expect(s.first.families, 5);
      expect(s.first.words, 9);
    });
  });

  group('study scope', () {
    test('parses and labels scopes', () {
      expect(StudyScope.parse('all'), isA<AllWords>());
      expect(StudyScope.parse('saved'), isA<SavedWords>());
      expect(StudyScope.parse('weak'), isA<WeakWordsScope>());
      expect(scopeLabel(StudyScope.parse('S1'), repo.index), 'S1 · Office Basics');
    });

    test('selects words for a scope', () {
      expect(wordsForScope(const AllWords(), repo.index), hasLength(16));
      expect(wordsForScope(const TopicScope('S2'), repo.index).every((w) => w.topic == 'S2'), isTrue);
      expect(wordsForScope(const SavedWords(), repo.index, saved: ['Ticket', 'nope']).map((w) => w.word), ['ticket']);
    });
  });

  group('reminder text (port of reminders.test.ts)', () {
    test('writes a helpful message', () {
      expect(reminderBody(savedCount: 3, dueCount: 5), contains('5 cards'));
      expect(reminderBody(savedCount: 3, dueCount: 0), contains('3 saved'));
      expect(reminderBody(savedCount: 0, dueCount: 0), contains('10 minutes'));
    });
  });
}
