import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../data/repositories/dataset_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/stats/stats.dart';
import '../../../utils/command.dart';
import '../../../utils/dates.dart';
import '../../../utils/result.dart';

/// Tính năng 7 — thống kê tiến độ: đã thuộc, đã học, đến hạn, chuỗi ngày, 7 ngày qua, từ yếu.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this._dataset, required this._user, required this._clock}) {
    load = Command0(_load)..execute();
    _user.changes.addListener(_onChanged);
  }

  final DatasetRepository _dataset;
  final UserRepository _user;
  final Clock _clock;
  late final Command0<void> load;

  Summary _summary = const Summary(learned: 0, studied: 0, due: 0, streak: 0, totalReviews: 0, totalQuizzes: 0);
  List<({int day, int count})> _week = const [];
  List<WeakWord> _weak = const [];
  int _saved = 0;

  Summary get summary => _summary;
  List<({int day, int count})> get week => _week;
  List<WeakWord> get weak => _weak;
  int get savedCount => _saved;
  int get totalWords => _dataset.index.words.length;
  int get totalTopics => _dataset.index.topics.length;
  bool get isSample => _dataset.isSample;

  void _onChanged() => load.execute();

  Future<Result<void>> _load() async {
    final today = dayNumber(_clock());
    final cards = await _user.cards();
    final activity = await _user.activity();
    final stats = await _user.wordStats();
    final saved = await _user.savedWords();
    switch ((cards, activity, stats, saved)) {
      case (Ok(value: final c), Ok(value: final a), Ok(value: final s), Ok(value: final sv)):
        _summary = summarize(c, a, today);
        _week = lastDays(a, today);
        _weak = weakWords(s, c, limit: 8);
        _saved = sv.length;
        notifyListeners();
        return const Result.ok(null);
      case (Error(:final error), _, _, _) ||
          (_, Error(:final error), _, _) ||
          (_, _, Error(:final error), _) ||
          (_, _, _, Error(:final error)):
        return Result.error(error);
    }
  }

  @override
  void dispose() {
    _user.changes.removeListener(_onChanged);
    super.dispose();
  }
}
