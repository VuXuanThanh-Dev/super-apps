import 'package:flutter/foundation.dart';

import '../../../data/repositories/dataset_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/tts_service.dart';
import '../../../domain/models/user_data.dart';
import '../../../domain/quiz/quiz_generator.dart';
import '../../../domain/stats/stats.dart';
import '../../../domain/vocabulary/search.dart';
import '../../../utils/command.dart';
import '../../../utils/dates.dart';
import '../../../utils/random.dart';
import '../../../utils/result.dart';

/// Tính năng 3 — quiz: nghĩa, điền chỗ trống, dạng từ, nối collocation, nghe.
class QuizViewModel extends ChangeNotifier {
  QuizViewModel({
    required this.type,
    required this.scope,
    required this._dataset,
    required this._user,
    required this._tts,
    required this._clock,
    int? seed,
    this.count = 10,
  }) : _rng = mulberry32(seed ?? _clock().millisecondsSinceEpoch) {
    load = Command0(_load)..execute();
  }

  final QuizType type;
  final StudyScope scope;
  final int count;
  final DatasetRepository _dataset;
  final UserRepository _user;
  final TtsService _tts;
  final Clock _clock;
  final Rng _rng;

  late final Command0<void> load;

  List<QuizQuestion> _questions = const [];
  int _index = 0;
  int _score = 0;
  int? _chosen; // câu chọn: đáp án đã chọn
  List<int?> _matches = const []; // câu nối: left[i] → right[_matches[i]]
  int? _selectedLeft;
  bool _checked = false;

  String get title => '${type.title} · ${scopeLabel(scope, _dataset.index)}';
  List<QuizQuestion> get questions => _questions;
  int get index => _index;
  int get score => _score;
  bool get done => _questions.isNotEmpty && _index >= _questions.length;
  bool get empty => !load.running && _questions.isEmpty;
  QuizQuestion? get current => _index < _questions.length ? _questions[_index] : null;
  int? get chosen => _chosen;
  bool get checked => _checked;
  List<int?> get matches => _matches;
  int? get selectedLeft => _selectedLeft;

  Future<Result<void>> _load() async {
    var saved = const <String>[];
    var weak = const <String>[];
    if (scope is SavedWords) {
      if (await _user.savedWords() case Ok(:final value)) saved = [for (final s in value) s.word];
    } else if (scope is WeakWordsScope) {
      final stats = await _user.wordStats();
      final cards = await _user.cards();
      if ((stats, cards) case (Ok(value: final s), Ok(value: final c))) {
        weak = [for (final w in weakWords(s, c, limit: 50)) w.word];
      }
    }
    final words = wordsForScope(scope, _dataset.index, saved: saved, weak: weak);
    _questions = generateQuiz(type, words, _dataset.index, _rng, count);
    _startQuestion();
    return const Result.ok(null);
  }

  void _startQuestion() {
    _chosen = null;
    _checked = false;
    _selectedLeft = null;
    final q = current;
    _matches = q is MatchQuestion ? List<int?>.filled(q.left.length, null) : const [];
    notifyListeners();
    if (q is ChoiceQuestion && q.speakText != null) _tts.speak(q.speakText!);
  }

  Future<void> speakCurrent() async {
    final q = current;
    if (q is ChoiceQuestion && q.speakText != null) await _tts.speak(q.speakText!);
  }

  /// Câu chọn: chọn đáp án [option] → chấm ngay.
  Future<void> choose(int option) async {
    final q = current;
    if (q is! ChoiceQuestion || _checked) return;
    _chosen = option;
    _checked = true;
    final correct = option == q.answer;
    if (correct) _score += 1;
    notifyListeners();
    await _record(q.word, correct);
  }

  /// Câu nối: chạm một cụm bên trái rồi một nghĩa bên phải.
  void selectLeft(int i) {
    if (_checked) return;
    _selectedLeft = i;
    notifyListeners();
  }

  void selectRight(int j) {
    final left = _selectedLeft;
    if (_checked || left == null) return;
    _matches = [
      for (var i = 0; i < _matches.length; i++)
        if (i == left) j else (_matches[i] == j ? null : _matches[i]),
    ];
    _selectedLeft = null;
    notifyListeners();
  }

  bool get canCheckMatch => current is MatchQuestion && !_checked && _matches.every((m) => m != null);

  Future<void> checkMatch() async {
    final q = current;
    if (q is! MatchQuestion || !canCheckMatch) return;
    _checked = true;
    final correct = q.isCorrect(_matches);
    if (correct) _score += 1;
    notifyListeners();
    for (var i = 0; i < q.left.length; i++) {
      await _record(q.words[i], _matches[i] == q.answer[i]);
    }
  }

  Future<void> _record(String word, bool correct) async {
    final now = _clock();
    if (word.isNotEmpty) await _user.recordAnswer(word, correct: correct, day: dayNumber(now));
    await _user.recordActivity(localDayString(now), ActivityKind.quiz);
  }

  void next() {
    if (!_checked) return;
    _index += 1;
    _startQuestion();
  }
}
