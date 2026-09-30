import 'package:flutter/foundation.dart';

import '../../../data/repositories/dataset_repository.dart';
import '../../../domain/lookup/dictionary.dart';
import '../../../domain/models/dataset.dart';
import '../../../domain/vocabulary/search.dart';

/// Tính năng 1 — từ vựng theo unit/chủ đề + tìm kiếm (tiếng Anh, tiếng Việt có/không dấu).
class VocabularyViewModel extends ChangeNotifier {
  VocabularyViewModel({required this._dataset});

  final DatasetRepository _dataset;
  String _query = '';
  List<Word> _results = const [];

  String get query => _query;
  List<Word> get results => _results;
  bool get searching => _query.trim().isNotEmpty;
  bool get isSample => _dataset.isSample;
  List<TopicSummary> get topics => topicSummaries(_dataset.index);

  void search(String query) {
    _query = query;
    _results = searchWords(_dataset.index, query);
    notifyListeners();
  }
}

/// Dữ liệu cho màn hình một unit (chỉ đọc — không có trạng thái thay đổi).
class TopicViewModel {
  TopicViewModel({required this.code, required DatasetRepository dataset})
    : topic = dataset.index.topicsByCode[code],
      families = [
        for (final f in dataset.index.familiesInTopic(code)) (family: f, words: dataset.index.familyMembers(f.id)),
      ];

  final String code;
  final Topic? topic;
  final List<({Family family, List<Word> words})> families;

  int get wordCount => families.fold(0, (n, f) => n + f.words.length);
}

/// Dữ liệu cho màn hình chi tiết một từ.
class WordViewModel {
  WordViewModel({required String wordId, required DatasetRepository dataset}) {
    final w = dataset.index.wordsById[wordId];
    word = w;
    result = w == null
        ? NotFoundResult(wordId)
        : EntryResult(
            w.word,
            word: w,
            family: dataset.index.familyMembers(w.family),
            collocations: dataset.index.collocationsForWord(w),
          );
    topic = w == null ? null : dataset.index.topicsByCode[w.topic];
    final f = w == null ? null : dataset.index.familiesById[w.family];
    tip = f?.tip;
  }

  late final Word? word;
  late final LookupResult result;
  late final Topic? topic;
  late final String? tip;
}
