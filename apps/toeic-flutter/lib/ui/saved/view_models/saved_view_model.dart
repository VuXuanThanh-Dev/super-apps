import 'package:flutter/foundation.dart';

import '../../../data/repositories/dataset_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/dataset.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

typedef SavedItem = ({String key, Word? word});

/// Tính năng 6 — từ đã lưu (+ nhắc ôn hằng ngày ở SettingsViewModel).
class SavedViewModel extends ChangeNotifier {
  SavedViewModel({required this._dataset, required this._user}) {
    load = Command0(_load)..execute();
    remove = Command1(_remove);
    _user.changes.addListener(_onChanged);
  }

  final DatasetRepository _dataset;
  final UserRepository _user;
  late final Command0<void> load;
  late final Command1<void, String> remove;

  List<SavedItem> _items = const [];
  List<SavedItem> get items => _items;

  void _onChanged() => load.execute();

  Future<Result<void>> _load() async {
    switch (await _user.savedWords()) {
      case Ok(:final value):
        _items = [for (final s in value) (key: s.word, word: _dataset.index.wordByKey(s.word))];
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _remove(String key) => _user.setSaved(key, saved: false);

  @override
  void dispose() {
    _user.changes.removeListener(_onChanged);
    super.dispose();
  }
}
