import 'dart:async';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:tap2_so_tu_vung/data/repositories/word_repository.dart';
import 'package:tap2_so_tu_vung/data/services/reminder_service.dart';
import 'package:tap2_so_tu_vung/data/services/tts_service.dart';
import 'package:tap2_so_tu_vung/domain/models/word.dart';
import 'package:tap2_so_tu_vung/utils/vietnamese.dart';

/// Fake = bản cài đặt thật nhưng đơn giản (trong bộ nhớ). Docs chính thức: "Make fakes for testing".
class FakeWordRepository implements WordRepository {
  FakeWordRepository([List<Word>? words])
    : _words = {
        for (final w
            in words ??
                const [
                  Word(id: 1, text: 'budget', partOfSpeech: 'n', meaning: 'ngân sách', example: 'Stay within budget.'),
                  Word(id: 2, text: 'negotiate', partOfSpeech: 'v', meaning: 'đàm phán', example: 'We negotiated.'),
                  Word(id: 3, text: 'invoice', partOfSpeech: 'n', meaning: 'hóa đơn', example: 'Send the invoice.'),
                ])
          w.id: w,
      };

  final Map<int, Word> _words;
  final List<(int, bool)> reviews = [];

  /// Nếu đặt, `search` sẽ chờ Completer này — để test tình huống "kết quả về chậm".
  Completer<void>? searchGate;
  Exception? failNextSearch;
  int searchCalls = 0;

  @override
  Future<List<Word>> search({String query = '', bool favoritesOnly = false}) async {
    searchCalls++;
    final gate = searchGate;
    if (gate != null) await gate.future;
    final error = failNextSearch;
    if (error != null) {
      failNextSearch = null;
      throw error;
    }
    final q = query.trim().withoutAccents;
    return _words.values
        .where((w) => q.isEmpty || '${w.text} ${w.meaning}'.withoutAccents.contains(q))
        .where((w) => !favoritesOnly || w.favorite)
        .toList()
      ..sort((a, b) => a.text.compareTo(b.text));
  }

  @override
  Future<Word?> getById(int id) async => _words[id];

  @override
  Future<Word> toggleFavorite(int id) async {
    final w = _words[id];
    if (w == null) throw WordNotFoundException(id);
    return _words[id] = w.copyWith(favorite: !w.favorite);
  }

  @override
  Future<void> recordReview(int wordId, {required bool correct, DateTime? at}) async {
    reviews.add((wordId, correct));
    final w = _words[wordId]!;
    _words[wordId] = w.copyWith(reviewCount: w.reviewCount + 1, correctCount: w.correctCount + (correct ? 1 : 0));
  }

  @override
  Future<List<Word>> dueForReview({int limit = 10}) async => (await search()).take(limit).toList();

  @override
  Future<ReviewStats> stats({DateTime? now}) async => ReviewStats(
    totalWords: _words.length,
    favorites: _words.values.where((w) => w.favorite).length,
    reviewedToday: reviews.length,
  );

  @override
  Future<int> resetProgress() async {
    final n = reviews.length;
    reviews.clear();
    _words.updateAll((_, w) => w.copyWith(reviewCount: 0, correctCount: 0));
    return n;
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
  int cancelCalls = 0;

  @override
  Future<bool> requestPermission() async => grant;

  @override
  Future<void> scheduleDaily(TimeOfDay time) async => scheduled = time;

  @override
  Future<void> cancel() async {
    cancelCalls++;
    scheduled = null;
  }
}
