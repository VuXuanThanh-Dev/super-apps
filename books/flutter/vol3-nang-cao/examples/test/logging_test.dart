import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap3_so_ghi_chu/chapters/ch07/exercise_solution.dart';
import 'package:tap3_so_ghi_chu/core/logging/app_logger.dart';
import 'package:tap3_so_ghi_chu/core/logging/error_handlers.dart';
import 'package:tap3_so_ghi_chu/core/logging/redact.dart';

void main() {
  test('redact che email và dãy số dài', () {
    expect(redact('Gửi cho nobin@example.com PIN 246810'), 'Gửi cho <email> PIN <số>');
    expect(redact('Lỗi 404 ở bước 3'), 'Lỗi 404 ở bước 3');
  });

  test('AppLogger: giữ tối đa capacity bản ghi, che dữ liệu, chống gửi trùng trong 1 phút', () {
    var now = DateTime(2026, 9, 30, 10);
    final sent = <LogRecord>[];
    final logger = AppLogger(capacity: 3, sink: sent.add, clock: () => now);
    for (var i = 0; i < 5; i++) {
      logger.info('dòng $i');
    }
    expect(logger.records.map((r) => r.message), ['dòng 2', 'dòng 3', 'dòng 4']);
    logger.error('Lưu thất bại cho 0912345678', StateError('x'));
    logger.error('Lưu thất bại cho 0912345678', StateError('x'));
    expect(sent, hasLength(1));
    expect(sent.single.message, 'Lưu thất bại cho <số>');
    now = now.add(const Duration(minutes: 2));
    logger.error('Lưu thất bại cho 0912345678', StateError('x'));
    expect(sent, hasLength(2));
  });

  test('installErrorHandlers: FlutterError và lỗi bất đồng bộ đều vào logger', () {
    final oldFlutter = FlutterError.onError;
    final oldPlatform = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = oldFlutter;
      PlatformDispatcher.instance.onError = oldPlatform;
    });
    final logger = AppLogger();
    installErrorHandlers(logger);
    FlutterError.onError = (details) =>
        logger.error('FlutterError: ${details.exceptionAsString()}', details.exception, details.stack);
    FlutterError.reportError(FlutterErrorDetails(exception: Exception('lỗi build')));
    final handled = PlatformDispatcher.instance.onError!(StateError('lỗi async'), StackTrace.empty);
    expect(handled, isTrue);
    expect(logger.records.map((r) => r.level), [LogLevel.error, LogLevel.error]);
    expect(logger.records.first.message, contains('lỗi build'));
  });

  test('Bài 1 (Ch.7): exportLogs lọc theo mức và che dữ liệu', () {
    final t = DateTime(2026, 9, 30, 8, 5, 9);
    final text = exportLogs([
      LogRecord(t, LogLevel.debug, 'bỏ qua'),
      LogRecord(t, LogLevel.info, 'Mở app'),
      LogRecord(t, LogLevel.error, 'Lưu lỗi', error: StateError('user a@b.co')),
    ]);
    expect(text, '08:05:09 [info] Mở app\n08:05:09 [error] Lưu lỗi — Bad state: user <email>');
  });
}
