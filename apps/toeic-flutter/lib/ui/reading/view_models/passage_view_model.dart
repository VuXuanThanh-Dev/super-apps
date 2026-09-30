import 'package:flutter/foundation.dart';

import '../../../data/repositories/dataset_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/dataset.dart';
import '../../../domain/models/user_data.dart';
import '../../../utils/dates.dart';

/// Tính năng 4 — bài đọc ngắn kiểu TOEIC + câu hỏi.
class PassageViewModel extends ChangeNotifier {
  PassageViewModel({
    required String passageId,
    required DatasetRepository dataset,
    required UserRepository user,
    required Clock clock,
  }) : passage = dataset.passageById(passageId) {
    final p = passage;
    topic = p == null ? null : dataset.index.topicsByCode[p.topic];
    unitWords = p == null ? const {} : {for (final w in dataset.index.wordsInTopic(p.topic)) w.key};
    _answers = List<int?>.filled(p?.questions.length ?? 0, null);
    // Mở bài đọc = một hoạt động "read" trong thống kê.
    if (p != null) user.recordActivity(localDayString(clock()), ActivityKind.read);
  }

  final Passage? passage;
  late final Topic? topic;

  /// Từ của unit → in đậm trong bài đọc.
  late final Set<String> unitWords;
  late List<int?> _answers;

  List<int?> get answers => _answers;
  int get correctCount {
    final p = passage;
    if (p == null) return 0;
    var n = 0;
    for (var i = 0; i < p.questions.length; i++) {
      if (_answers[i] == p.questions[i].answer) n++;
    }
    return n;
  }

  void answer(int question, int option) {
    if (_answers[question] != null) return;
    _answers = [...(_answers..[question] = option)];
    notifyListeners();
  }
}
