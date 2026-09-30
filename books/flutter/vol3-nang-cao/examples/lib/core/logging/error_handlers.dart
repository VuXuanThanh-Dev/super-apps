import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_logger.dart';

/// Gắn các "lưới bắt lỗi" toàn app (docs "Handling errors in Flutter"):
/// - FlutterError.onError: lỗi trong lúc build/layout/paint của framework.
/// - PlatformDispatcher.instance.onError: lỗi bất đồng bộ không ai bắt (Future lỗi…).
/// - ErrorWidget.builder: thay "màn hình đỏ" bằng giao diện thân thiện ở bản release.
void installErrorHandlers(AppLogger logger) {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    logger.error('FlutterError: ${details.exceptionAsString()}', details.exception, details.stack);
    if (kDebugMode) previous?.call(details); // debug: vẫn in ra console như mặc định
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Lỗi bất đồng bộ không được bắt', error, stack);
    return true; // đã xử lý → không làm app dừng
  };
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const Material(child: Center(child: Text('Đã có lỗi ở phần này. Hãy thử lại.')));
  }
}
