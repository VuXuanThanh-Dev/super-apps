import 'package:flutter/foundation.dart';

import '../../data/repositories/word_repository.dart';
import '../../data/services/dictionary_client.dart';
import '../../data/services/tts_service.dart';
import '../../domain/models/word.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// ViewModel màn hình chi tiết — dùng mẫu Command của docs chính thức.
class WordDetailViewModel extends ChangeNotifier {
  WordDetailViewModel({
    required this.wordId,
    required this._repository,
    required this._tts,
    required this._dictionary,
  }) {
    load = Command0(_load)..execute();
    toggleFavorite = Command0(_toggleFavorite);
    speak = Command0(_speak);
    lookup = Command0(_lookup);
  }

  final int wordId;
  final WordRepository _repository;
  final TtsService _tts;
  final DictionaryClient _dictionary;

  late final Command0<Word> load;
  late final Command0<Word> toggleFavorite;
  late final Command0<void> speak;
  late final Command0<List<Definition>> lookup;

  Word? _word;
  Word? get word => _word;

  Future<Result<Word>> _load() async {
    try {
      final w = await _repository.getById(wordId);
      if (w == null) return Result.error(WordNotFoundException(wordId));
      _word = w;
      return Result.ok(w);
    } on Exception catch (e) {
      return Result.error(e);
    } finally {
      notifyListeners();
    }
  }

  Future<Result<Word>> _toggleFavorite() async {
    try {
      _word = await _repository.toggleFavorite(wordId);
      return Result.ok(_word!);
    } on Exception catch (e) {
      return Result.error(e);
    } finally {
      notifyListeners();
    }
  }

  Future<Result<void>> _speak() async {
    final w = _word;
    if (w == null) return const Result.ok(null);
    try {
      await _tts.speak(w.text);
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<List<Definition>>> _lookup() async {
    final w = _word;
    if (w == null) return const Result.ok([]);
    return _dictionary.lookup(w.text);
  }
}
