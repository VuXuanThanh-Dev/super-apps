import 'package:flutter/material.dart';

import '../../data/repositories/settings_repository.dart';
import '../../data/services/reminder_service.dart';
import '../../data/services/tts_service.dart';

/// Cài đặt: theme, nhắc ôn hằng ngày, tốc độ đọc. Được cung cấp ở gốc app vì MaterialApp cần themeMode.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required this._settings, required this._reminders, required this._tts});

  final SettingsRepository _settings;
  final ReminderService _reminders;
  final TtsService _tts;

  ThemeMode _themeMode = ThemeMode.system;
  TimeOfDay? _reminder;
  double _speechRate = 0.5;
  String? _message;

  ThemeMode get themeMode => _themeMode;
  TimeOfDay? get reminder => _reminder;
  double get speechRate => _speechRate;
  bool get remindersSupported => _reminders.isSupported;

  /// Thông báo một lần cho View (SnackBar). View gọi [consumeMessage] sau khi hiện.
  String? get message => _message;
  void consumeMessage() => _message = null;

  Future<void> load() async {
    _themeMode = await _settings.themeMode();
    _reminder = await _settings.reminderTime();
    _speechRate = await _settings.speechRate();
    await _tts.setRate(_speechRate);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners(); // đổi giao diện ngay, lưu sau
    await _settings.setThemeMode(mode);
  }

  Future<void> setReminder(TimeOfDay? time) async {
    if (time == null) {
      await _reminders.cancel();
      await _settings.setReminderTime(null);
      _reminder = null;
      _message = 'Đã tắt nhắc ôn';
    } else if (!_reminders.isSupported) {
      _message = 'Bản web không hỗ trợ nhắc theo lịch';
    } else if (!await _reminders.requestPermission()) {
      _message = 'Chưa được cấp quyền thông báo. Hãy bật trong Cài đặt của máy.';
    } else {
      await _reminders.scheduleDaily(time);
      await _settings.setReminderTime(time);
      _reminder = time;
      _message = 'Sẽ nhắc lúc ${SettingsRepository.formatTime(time)} mỗi ngày';
    }
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    notifyListeners();
    await _tts.setRate(rate);
    await _settings.setSpeechRate(rate);
  }
}
