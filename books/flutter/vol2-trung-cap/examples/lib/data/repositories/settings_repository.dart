import 'package:flutter/material.dart';

import '../services/key_value_store.dart';

/// Cài đặt của app, lưu bền qua [KeyValueStore].
class SettingsRepository {
  SettingsRepository(this._store);

  final KeyValueStore _store;

  static const _themeKey = 'theme_mode';
  static const _reminderKey = 'reminder_time';
  static const _rateKey = 'speech_rate';

  Future<ThemeMode> themeMode() async {
    final name = await _store.getString(_themeKey);
    return ThemeMode.values.where((m) => m.name == name).firstOrNull ?? ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) => _store.setString(_themeKey, mode.name);

  /// Giờ nhắc ôn hằng ngày, `null` = tắt. Lưu dạng "HH:mm".
  Future<TimeOfDay?> reminderTime() async => parseTime(await _store.getString(_reminderKey));

  Future<void> setReminderTime(TimeOfDay? time) =>
      time == null ? _store.remove(_reminderKey) : _store.setString(_reminderKey, formatTime(time));

  Future<double> speechRate() async => double.tryParse(await _store.getString(_rateKey) ?? '') ?? 0.5;

  Future<void> setSpeechRate(double rate) => _store.setString(_rateKey, rate.toStringAsFixed(2));

  static String formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay? parseTime(String? s) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s ?? '');
    if (m == null) return null;
    final h = int.parse(m.group(1)!), min = int.parse(m.group(2)!);
    if (h > 23 || min > 59) return null;
    return TimeOfDay(hour: h, minute: min);
  }
}
