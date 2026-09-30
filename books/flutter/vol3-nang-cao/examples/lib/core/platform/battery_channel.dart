import 'package:flutter/services.dart';

/// Platform channel tự viết — theo đúng ví dụ "battery" của docs "Writing custom platform-specific code".
/// Phía native: ios/Runner/AppDelegate.swift và android/.../MainActivity.kt (cùng tên kênh).
class BatteryChannel {
  const BatteryChannel([this._channel = const MethodChannel(channelName)]);

  static const channelName = 'dev.nobin.notes/battery';
  final MethodChannel _channel;

  /// Phần trăm pin, hoặc `null` nếu nền tảng không hỗ trợ (web, máy ảo không có pin…).
  Future<int?> batteryLevel() async {
    try {
      return await _channel.invokeMethod<int>('getBatteryLevel');
    } on PlatformException {
      return null; // native báo lỗi, ví dụ UNAVAILABLE
    } on MissingPluginException {
      return null; // không có code native cho kênh này (web, test)
    }
  }

  /// Bài tập Chương 3: chế độ tiết kiệm pin (iOS: Low Power Mode, Android: Battery Saver). `null` = không hỗ trợ.
  Future<bool?> lowPowerMode() async {
    try {
      return await _channel.invokeMethod<bool>('isLowPowerMode');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
