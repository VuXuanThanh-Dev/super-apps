import 'package:flutter/foundation.dart';

import '../../../data/repositories/dataset_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/tts_service.dart';
import '../../../domain/lookup/dictionary.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// ViewModel của popup tra từ. Giữ lịch sử tra (chạm từ trong popup → mở từ mới, có Back).
class WordPopupViewModel extends ChangeNotifier {
  WordPopupViewModel({required String initialWord, required this._dataset, required this._user, required this._tts}) {
    toggleSave = Command0(_toggleSave);
    open(initialWord);
  }

  final DatasetRepository _dataset;
  final UserRepository _user;
  final TtsService _tts;

  final List<LookupResult> _history = [];
  bool _saved = false;
  late final Command0<void> toggleSave;

  LookupResult get current => _history.last;
  bool get canGoBack => _history.length > 1;
  bool get saved => _saved;

  /// Từ dùng làm tiêu đề và khoá "đã lưu" (lemma đã tìm được), `null` nếu không tìm thấy.
  String? get headword => switch (current) {
    EntryResult(:final word) => word.word,
    FunctionWordResult(:final lemma) => lemma,
    GlossResult(:final lemma) => lemma,
    NotFoundResult() => null,
  };

  void open(String raw) {
    _history.add(_dataset.lookup(raw));
    notifyListeners();
    _loadSaved();
  }

  void back() {
    if (!canGoBack) return;
    _history.removeLast();
    notifyListeners();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final key = headword;
    final before = current;
    final result = key == null ? const Result.ok(false) : await _user.isSaved(key);
    if (!identical(before, current)) return; // đã chuyển sang từ khác
    _saved = switch (result) {
      Ok(:final value) => value,
      Error() => false,
    };
    notifyListeners();
  }

  Future<Result<void>> _toggleSave() async {
    final key = headword;
    if (key == null) return const Result.ok(null);
    final result = await _user.setSaved(key, saved: !_saved);
    if (result is Ok) {
      _saved = !_saved;
      notifyListeners();
    }
    return result;
  }

  Future<void> speak(String text) => _tts.speak(text);
}
