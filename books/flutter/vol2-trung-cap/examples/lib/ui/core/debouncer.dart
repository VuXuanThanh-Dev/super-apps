import 'dart:async';

import 'package:flutter/foundation.dart';

/// `debounceTime` của RxJS cho callback (Tập 1, Chương 2).
class Debouncer {
  Debouncer(this.delay);

  final Duration delay;
  Timer? _timer;

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() => _timer?.cancel();
}
