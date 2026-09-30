import 'package:flutter/foundation.dart';

import 'redact.dart';

enum LogLevel { debug, info, warning, error }

@immutable
class LogRecord {
  const LogRecord(this.time, this.level, this.message, {this.error, this.stackTrace});
  final DateTime time;
  final LogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  @override
  String toString() => '[${level.name}] $message${error == null ? '' : ' — $error'}';
}

/// Logger nhỏ giữ N bản ghi gần nhất trong bộ nhớ (ring buffer) và gửi lỗi cho [sink] (ví dụ Sentry).
/// Không bao giờ log dữ liệu nhạy cảm (PIN, nội dung ghi chú) — xem Tập 3, Chương 4 và 7.
class AppLogger extends ChangeNotifier {
  AppLogger({this.capacity = 200, this.sink, DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final int capacity;

  /// Nơi gửi lỗi ra ngoài (crash reporting). `null` = chỉ giữ trong máy.
  final void Function(LogRecord record)? sink;
  final DateTime Function() _clock;
  final List<LogRecord> _records = [];
  final Map<String, DateTime> _lastSent = {};

  List<LogRecord> get records => List.unmodifiable(_records);

  void debug(String message) => _add(LogRecord(_clock(), LogLevel.debug, message));
  void info(String message) => _add(LogRecord(_clock(), LogLevel.info, message));
  void warning(String message, [Object? error]) => _add(LogRecord(_clock(), LogLevel.warning, message, error: error));

  void error(String message, Object error, [StackTrace? stackTrace]) =>
      _add(LogRecord(_clock(), LogLevel.error, message, error: error, stackTrace: stackTrace));

  void _add(LogRecord raw) {
    // Luôn che email / dãy số dài trước khi lưu hoặc gửi đi.
    final record = LogRecord(raw.time, raw.level, redact(raw.message), error: raw.error, stackTrace: raw.stackTrace);
    _records.add(record);
    if (_records.length > capacity) _records.removeAt(0);
    if (kDebugMode && record.level.index >= LogLevel.warning.index) debugPrint(record.toString());
    if (record.level == LogLevel.error && sink != null && _shouldSend(record)) sink!(record);
    notifyListeners();
  }

  /// Chống "bão lỗi": cùng một lỗi chỉ gửi ra ngoài tối đa 1 lần mỗi phút.
  bool _shouldSend(LogRecord record) {
    final key = '${record.message}|${record.error.runtimeType}|${record.error}';
    final last = _lastSent[key];
    if (last != null && record.time.difference(last) < const Duration(minutes: 1)) return false;
    _lastSent[key] = record.time;
    return true;
  }

  void clear() {
    _records.clear();
    notifyListeners();
  }
}
