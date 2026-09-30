import 'package:flutter/material.dart';

import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/reminder_service.dart';
import '../../../data/services/tts_service.dart';
import '../../../domain/reminders/reminder_text.dart';
import '../../../domain/stats/stats.dart' show dueCount;
import '../../../utils/dates.dart';
import '../../../utils/result.dart';

/// Cài đặt: chế độ tối (tính năng 8), nhắc ôn hằng ngày (tính năng 6), tốc độ đọc.
/// Cung cấp ở gốc app vì MaterialApp cần `themeMode` (giống app mẫu Tập 2 của sách).
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required this._settings,
    required this._reminders,
    required this._tts,
    required this._user,
    Clock? clock,
  }) : _clock = clock ?? DateTime.now;

  final SettingsRepository _settings;
  final ReminderService _reminders;
  final TtsService _tts;
  final UserRepository _user;
  final Clock _clock;

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
      _message = 'Reminder off · Đã tắt nhắc ôn';
    } else if (!_reminders.isSupported) {
      _message = 'Web version: no scheduled reminders · Bản web không hỗ trợ nhắc theo lịch';
    } else if (!await _reminders.requestPermission()) {
      _message = 'No notification permission · Hãy bật quyền thông báo trong Cài đặt của máy';
    } else {
      await _reminders.scheduleDaily(time, body: await _body());
      await _settings.setReminderTime(time);
      _reminder = time;
      _message = 'Daily reminder at ${SettingsRepository.formatTime(time)} · Sẽ nhắc mỗi ngày';
    }
    notifyListeners();
  }

  Future<String> _body() async {
    final saved = switch (await _user.savedWords()) {
      Ok(:final value) => value.length,
      Error() => 0,
    };
    final today = dayNumber(_clock());
    final due = switch (await _user.cards()) {
      Ok(:final value) => dueCount(value, today),
      Error() => 0,
    };
    return reminderBody(savedCount: saved, dueCount: due);
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    notifyListeners();
    await _tts.setRate(rate);
    await _settings.setSpeechRate(rate);
  }
}
