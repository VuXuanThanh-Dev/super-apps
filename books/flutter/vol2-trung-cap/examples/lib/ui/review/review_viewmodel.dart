import 'package:flutter/foundation.dart';

import '../../data/repositories/word_repository.dart';
import '../../domain/models/word.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Ôn tập bằng thẻ lật: xem từ → lật xem nghĩa → tự đánh giá "Đã nhớ" / "Chưa nhớ".
class ReviewViewModel extends ChangeNotifier {
  // Dart 3.12+: tham số có tên "private" (`this._repository`) — người gọi vẫn viết `repository:`.
  ReviewViewModel({required this._repository, this.batchSize = 5, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    start = Command0(_start)..execute();
    answer = Command1(_answer);
  }

  final WordRepository _repository;
  final DateTime Function() _clock;
  final int batchSize;

  late final Command0<void> start;
  late final Command1<void, bool> answer;

  List<Word> _queue = const [];
  int _index = 0;
  int _correct = 0;
  bool _revealed = false;
  ReviewStats? _stats;

  Word? get current => _index < _queue.length ? _queue[_index] : null;
  bool get revealed => _revealed;
  bool get finished => _queue.isNotEmpty && _index >= _queue.length;
  int get position => _index;
  int get total => _queue.length;
  int get correct => _correct;
  ReviewStats? get stats => _stats;

  Future<Result<void>> _start() async {
    try {
      _queue = await _repository.dueForReview(limit: batchSize);
      _stats = await _repository.stats(now: _clock());
      _index = 0;
      _correct = 0;
      _revealed = false;
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } finally {
      notifyListeners();
    }
  }

  void reveal() {
    if (current == null || _revealed) return;
    _revealed = true;
    notifyListeners();
  }

  Future<Result<void>> _answer(bool remembered) async {
    final word = current;
    if (word == null || !_revealed) return const Result.ok(null);
    try {
      await _repository.recordReview(word.id, correct: remembered, at: _clock());
      if (remembered) _correct++;
      _index++;
      _revealed = false;
      _stats = await _repository.stats(now: _clock());
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    } finally {
      notifyListeners();
    }
  }
}
