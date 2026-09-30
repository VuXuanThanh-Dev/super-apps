import 'package:flutter/foundation.dart';

import '../../../data/repositories/dataset_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/tts_service.dart';
import '../../../domain/models/dataset.dart';
import '../../../domain/models/user_data.dart';
import '../../../domain/srs/queue.dart';
import '../../../domain/srs/sm2.dart';
import '../../../domain/stats/stats.dart';
import '../../../domain/vocabulary/search.dart';
import '../../../utils/command.dart';
import '../../../utils/dates.dart';
import '../../../utils/result.dart';

/// Tính năng 2 — flashcard lặp lại ngắt quãng (SM-2).
class FlashcardsViewModel extends ChangeNotifier {
  FlashcardsViewModel({
    required this.scope,
    required this._dataset,
    required this._user,
    required this._tts,
    required this._clock,
    this.newLimit = 10,
  }) {
    load = Command0(_load)..execute();
    grade = Command1(_grade);
  }

  final StudyScope scope;
  final int newLimit;
  final DatasetRepository _dataset;
  final UserRepository _user;
  final TtsService _tts;
  final Clock _clock;

  late final Command0<void> load;
  late final Command1<void, Grade> grade;

  List<Word> _queue = const [];
  final Map<String, Card> _cards = {};
  int _index = 0;
  int _reviewed = 0;
  bool _showAnswer = false;

  String get title => scopeLabel(scope, _dataset.index);
  int get today => dayNumber(_clock());
  List<Word> get queue => _queue;
  int get position => _index;
  int get reviewed => _reviewed;
  bool get showAnswer => _showAnswer;
  bool get done => _index >= _queue.length;
  Word? get current => done ? null : _queue[_index];
  Card get currentCard => _cards[current?.key] ?? newCard(current?.word ?? '', today);

  /// Số ngày cho nút, ví dụ Good → 6.
  int preview(Grade g) => previewInterval(currentCard, g, today);

  Future<Result<void>> _load() async {
    final cards = await _user.cards();
    if (cards is Error<List<Card>>) return Result.error(cards.error);
    final all = (cards as Ok<List<Card>>).value;
    _cards
      ..clear()
      ..addAll({for (final c in all) c.word: c});
    var saved = const <String>[];
    var weak = const <String>[];
    if (scope is SavedWords) {
      final r = await _user.savedWords();
      if (r is Ok<List<SavedWord>>) saved = [for (final s in r.value) s.word];
    } else if (scope is WeakWordsScope) {
      final r = await _user.wordStats();
      if (r is Ok<List<WordStat>>) weak = [for (final w in weakWords(r.value, all, limit: 50)) w.word];
    }
    final words = wordsForScope(scope, _dataset.index, saved: saved, weak: weak);
    _queue = buildQueue(words, all, today: today, newLimit: newLimit);
    _index = 0;
    _showAnswer = false;
    notifyListeners();
    return const Result.ok(null);
  }

  void reveal() {
    _showAnswer = true;
    notifyListeners();
  }

  Future<Result<void>> _grade(Grade g) async {
    final word = current;
    if (word == null) return const Result.ok(null);
    final updated = review(currentCard, g, today);
    final saved = await _user.saveCard(updated);
    if (saved is Error) return saved;
    _cards[updated.word] = updated;
    await _user.recordActivity(localDayString(_clock()), ActivityKind.review);
    _reviewed += 1;
    // "Again" → cho thẻ quay lại cuối hàng đợi trong buổi học này.
    if (g == Grade.again) _queue = [..._queue, word];
    _index += 1;
    _showAnswer = false;
    notifyListeners();
    return const Result.ok(null);
  }

  Future<void> speak(String text) => _tts.speak(text);
}
