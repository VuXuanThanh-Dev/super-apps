import 'package:flutter/foundation.dart';

import '../../data/repositories/word_repository.dart';
import '../../domain/models/word.dart';

/// ViewModel của màn hình danh sách từ (MVVM). View chỉ đọc getter và gọi hàm.
class WordListViewModel extends ChangeNotifier {
  WordListViewModel({required this._repository}) {
    refresh();
  }

  final WordRepository _repository;

  List<Word> _words = const [];
  String _query = '';
  bool _favoritesOnly = false;
  bool _loading = false;
  Object? _error;
  int _requestId = 0; // chống "kết quả cũ về sau" (giống switchMap của RxJS)

  List<Word> get words => _words;
  String get query => _query;
  bool get favoritesOnly => _favoritesOnly;
  bool get loading => _loading;
  Object? get error => _error;

  Future<void> refresh() async {
    final id = ++_requestId;
    _loading = true;
    notifyListeners();
    try {
      final result = await _repository.search(query: _query, favoritesOnly: _favoritesOnly);
      if (id != _requestId) return; // đã có yêu cầu mới hơn → bỏ kết quả này
      _words = result;
      _error = null;
    } on Exception catch (e) {
      if (id != _requestId) return;
      _error = e;
    } finally {
      if (id == _requestId) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> search(String query) {
    _query = query;
    return refresh();
  }

  Future<void> setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    return refresh();
  }

  Future<void> toggleFavorite(int id) async {
    final updated = await _repository.toggleFavorite(id);
    _words = [
      for (final w in _words)
        if (w.id != id) w else updated,
    ];
    if (_favoritesOnly && !updated.favorite) _words = _words.where((w) => w.id != id).toList();
    notifyListeners();
  }
}
