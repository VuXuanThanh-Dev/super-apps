import 'package:flutter/foundation.dart';

/// Lời giải Bài 1 Chương 2: `computed()` của Angular bằng ValueListenable.
/// Tính lại khi một nguồn đổi; chỉ báo listener khi KẾT QUẢ đổi.
class Computed<T> extends ChangeNotifier implements ValueListenable<T> {
  Computed(this._sources, this._compute) : _value = _compute() {
    for (final s in _sources) {
      s.addListener(_recompute);
    }
  }

  final List<Listenable> _sources;
  final T Function() _compute;
  T _value;

  @override
  T get value => _value;

  void _recompute() {
    final next = _compute();
    if (next == _value) return;
    _value = next;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _sources) {
      s.removeListener(_recompute);
    }
    super.dispose();
  }
}
