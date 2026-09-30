import 'package:flutter/material.dart' show TimeOfDay;
import 'package:toeic_flutter/data/repositories/user_repository.dart';
import 'package:toeic_flutter/data/services/reminder_service.dart';
import 'package:toeic_flutter/data/services/tts_service.dart';
import 'package:toeic_flutter/domain/models/user_data.dart';
import 'package:toeic_flutter/utils/change_signal.dart';
import 'package:toeic_flutter/utils/result.dart';

/// Fake = bản cài đặt thật nhưng đơn giản (trong bộ nhớ). Docs chính thức: "Make fakes for testing"
/// (app-architecture/case-study/testing).
class FakeUserRepository implements UserRepository {
  final ChangeSignal _changes = ChangeSignal();
  final Map<String, int> saved = {};
  final Map<String, Card> cardMap = {};
  final Map<String, WordStat> stats = {};
  final Map<String, ActivityDay> days = {};
  int _clock = 0;

  /// Nếu đặt, lời gọi tiếp theo trả về lỗi.
  Exception? failNext;

  @override
  ChangeSignal get changes => _changes;

  Result<T> _ok<T>(T value, {bool write = false}) {
    final e = failNext;
    if (e != null) {
      failNext = null;
      return Result.error(e);
    }
    if (write) _changes.emit();
    return Result.ok(value);
  }

  @override
  Future<Result<List<SavedWord>>> savedWords() async {
    final list = [for (final e in saved.entries) SavedWord(word: e.key, addedAt: e.value)]
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return _ok(list);
  }

  @override
  Future<Result<bool>> isSaved(String word) async => _ok(saved.containsKey(word.toLowerCase()));

  @override
  Future<Result<void>> setSaved(String word, {required bool saved}) async {
    if (saved) {
      this.saved[word.toLowerCase()] = ++_clock;
    } else {
      this.saved.remove(word.toLowerCase());
    }
    return _ok(null, write: true);
  }

  @override
  Future<Result<List<Card>>> cards() async => _ok(cardMap.values.toList());

  @override
  Future<Result<void>> saveCard(Card card) async {
    cardMap[card.word] = card;
    return _ok(null, write: true);
  }

  @override
  Future<Result<void>> recordAnswer(String word, {required bool correct, required int day}) async {
    final s = stats[word] ?? WordStat(word: word, correct: 0, wrong: 0, lastSeen: day);
    stats[word] = WordStat(
      word: word,
      correct: s.correct + (correct ? 1 : 0),
      wrong: s.wrong + (correct ? 0 : 1),
      lastSeen: day,
    );
    return _ok(null, write: true);
  }

  @override
  Future<Result<List<WordStat>>> wordStats() async => _ok(stats.values.toList());

  @override
  Future<Result<void>> recordActivity(String day, ActivityKind kind) async {
    final a = days[day] ?? ActivityDay(day: day);
    days[day] = ActivityDay(
      day: day,
      reviews: a.reviews + (kind == ActivityKind.review ? 1 : 0),
      quizzes: a.quizzes + (kind == ActivityKind.quiz ? 1 : 0),
      reads: a.reads + (kind == ActivityKind.read ? 1 : 0),
    );
    return _ok(null, write: true);
  }

  @override
  Future<Result<List<ActivityDay>>> activity() async =>
      _ok(days.values.toList()..sort((a, b) => a.day.compareTo(b.day)));

  @override
  Future<Result<void>> reset() async {
    saved.clear();
    cardMap.clear();
    stats.clear();
    days.clear();
    return _ok(null, write: true);
  }
}

class FakeTts implements TtsService {
  final List<String> spoken = [];
  double rate = 0.5;

  @override
  Future<void> speak(String text) async => spoken.add(text);

  @override
  Future<void> stop() async {}

  @override
  Future<void> setRate(double rate) async => this.rate = rate;
}

class FakeReminderService implements ReminderService {
  FakeReminderService({this.isSupported = true, this.grant = true});

  @override
  final bool isSupported;
  bool grant;
  TimeOfDay? scheduled;
  String? body;
  int cancelCalls = 0;

  @override
  Future<bool> requestPermission() async => grant;

  @override
  Future<void> scheduleDaily(TimeOfDay time, {required String body}) async {
    scheduled = time;
    this.body = body;
  }

  @override
  Future<void> cancel() async {
    cancelCalls++;
    scheduled = null;
  }
}
