import 'dart:async';

/// Bài 1: thử lại với thời gian chờ tăng dần (exponential backoff): 100ms, 200ms, 400ms…
Future<T> retry<T>(
  Future<T> Function() action, {
  int attempts = 3,
  Duration initialDelay = const Duration(milliseconds: 100),
}) async {
  var delay = initialDelay;
  for (var i = 1; ; i++) {
    try {
      return await action();
    } on Exception {
      if (i >= attempts) rethrow;
      await Future<void>.delayed(delay);
      delay *= 2;
    }
  }
}

/// Bài 2: biến API kiểu callback thành Future bằng Completer.
typedef LegacyCallback = void Function(String? result, Object? error);

void legacyLoad(String key, LegacyCallback done) {
  Timer(const Duration(milliseconds: 10), () => key.isEmpty ? done(null, 'rỗng') : done('giá trị của $key', null));
}

Future<String> loadAsFuture(String key) {
  final completer = Completer<String>();
  legacyLoad(key, (result, error) {
    if (error != null) {
      completer.completeError(StateError('$error'));
    } else {
      completer.complete(result);
    }
  });
  return completer.future;
}
