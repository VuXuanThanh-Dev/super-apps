import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/user_data.dart';
import '../../utils/change_signal.dart';
import '../../utils/dates.dart';
import '../../utils/result.dart';
import '../services/user_database_service.dart';
import 'user_repository.dart';

/// [UserRepository] lưu trong SQLite trên máy (offline). Mọi câu SQL dùng tham số `?`.
class SqliteUserRepository implements UserRepository {
  SqliteUserRepository(this._service, {Clock? clock}) : _clock = clock ?? DateTime.now;

  final UserDatabaseService _service;
  final Clock _clock;
  final ChangeSignal _changes = ChangeSignal();

  Database get _db => _service.db;

  @override
  Listenable get changes => _changes;

  Future<Result<T>> _run<T>(Future<T> Function() action, {bool write = false}) async {
    try {
      final value = await action();
      if (write) _changes.emit();
      return Result.ok(value);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<SavedWord>>> savedWords() => _run(() async {
    final rows = await _db.query('saved_words', orderBy: 'added_at DESC, word ASC');
    return [for (final r in rows) SavedWord(word: r['word']! as String, addedAt: r['added_at']! as int)];
  });

  @override
  Future<Result<bool>> isSaved(String word) => _run(() async {
    final rows = await _db.query('saved_words', where: 'word = ?', whereArgs: [word.toLowerCase()], limit: 1);
    return rows.isNotEmpty;
  });

  @override
  Future<Result<void>> setSaved(String word, {required bool saved}) => _run(() async {
    if (saved) {
      await _db.insert('saved_words', {
        'word': word.toLowerCase(),
        'added_at': _clock().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await _db.delete('saved_words', where: 'word = ?', whereArgs: [word.toLowerCase()]);
    }
  }, write: true);

  @override
  Future<Result<List<Card>>> cards() => _run(() async {
    final rows = await _db.query('cards');
    return [
      for (final r in rows)
        Card(
          word: r['word']! as String,
          ease: (r['ease']! as num).toDouble(),
          interval: r['interval']! as int,
          repetitions: r['repetitions']! as int,
          due: r['due']! as int,
          lastReview: r['last_review'] as int?,
          lapses: r['lapses']! as int,
        ),
    ];
  });

  @override
  Future<Result<void>> saveCard(Card c) => _run(() async {
    await _db.insert('cards', {
      'word': c.word.toLowerCase(),
      'ease': c.ease,
      'interval': c.interval,
      'repetitions': c.repetitions,
      'due': c.due,
      'last_review': c.lastReview,
      'lapses': c.lapses,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }, write: true);

  @override
  Future<Result<void>> recordAnswer(String word, {required bool correct, required int day}) => _run(() async {
    await _db.rawInsert(
      '''INSERT INTO word_stats (word, correct, wrong, last_seen) VALUES (?, ?, ?, ?)
         ON CONFLICT(word) DO UPDATE SET correct = correct + excluded.correct,
           wrong = wrong + excluded.wrong, last_seen = excluded.last_seen''',
      [word.toLowerCase(), correct ? 1 : 0, correct ? 0 : 1, day],
    );
  }, write: true);

  @override
  Future<Result<List<WordStat>>> wordStats() => _run(() async {
    final rows = await _db.query('word_stats');
    return [
      for (final r in rows)
        WordStat(
          word: r['word']! as String,
          correct: r['correct']! as int,
          wrong: r['wrong']! as int,
          lastSeen: r['last_seen']! as int,
        ),
    ];
  });

  @override
  Future<Result<void>> recordActivity(String day, ActivityKind kind) => _run(() async {
    // Tên cột lấy từ enum (không từ người dùng) nên nối chuỗi ở đây là an toàn.
    final col = switch (kind) {
      ActivityKind.review => 'reviews',
      ActivityKind.quiz => 'quizzes',
      ActivityKind.read => 'reads',
    };
    await _db.rawInsert(
      'INSERT INTO activity (day, $col) VALUES (?, 1) ON CONFLICT(day) DO UPDATE SET $col = $col + 1',
      [day],
    );
  }, write: true);

  @override
  Future<Result<List<ActivityDay>>> activity() => _run(() async {
    final rows = await _db.query('activity', orderBy: 'day ASC');
    return [
      for (final r in rows)
        ActivityDay(
          day: r['day']! as String,
          reviews: r['reviews']! as int,
          quizzes: r['quizzes']! as int,
          reads: r['reads']! as int,
        ),
    ];
  });

  @override
  Future<Result<void>> reset() => _run(() async {
    final batch = _db.batch()
      ..delete('saved_words')
      ..delete('cards')
      ..delete('word_stats')
      ..delete('activity');
    await batch.commit(noResult: true);
  }, write: true);
}
