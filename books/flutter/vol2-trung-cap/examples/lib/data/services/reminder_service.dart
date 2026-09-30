import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Nhắc ôn bài hằng ngày bằng thông báo cục bộ (local notification). Interface để test dùng bản giả.
abstract interface class ReminderService {
  /// Nền tảng hiện tại có hỗ trợ nhắc theo lịch không (web: không).
  bool get isSupported;
  Future<bool> requestPermission();
  Future<void> scheduleDaily(TimeOfDay time);
  Future<void> cancel();
}

/// Lần tới của giờ [time] tính từ [now] (hôm nay nếu chưa qua, không thì ngày mai). Hàm thuần — dễ test.
tz.TZDateTime nextInstanceOf(TimeOfDay time, tz.TZDateTime now) {
  var scheduled = tz.TZDateTime(now.location, now.year, now.month, now.day, time.hour, time.minute);
  if (!scheduled.isAfter(now)) scheduled = scheduled.add(const Duration(days: 1));
  return scheduled;
}

/// Bản thật: flutter_local_notifications + timezone.
class LocalNotificationReminderService implements ReminderService {
  LocalNotificationReminderService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  static const int _id = 1;
  bool _initialized = false;

  @override
  bool get isSupported => !kIsWeb;

  Future<void> _init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Không xin quyền ngay khi mở app; xin khi người dùng bật nhắc (requestPermission).
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await _init();
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) return await ios.requestPermissions(alert: true, sound: true) ?? false;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;
    return false;
  }

  @override
  Future<void> scheduleDaily(TimeOfDay time) async {
    if (!isSupported) return;
    await _init();
    await _plugin.zonedSchedule(
      id: _id,
      title: 'Đến giờ ôn từ vựng',
      body: 'Dành 5 phút ôn lại các từ hôm nay nhé!',
      scheduledDate: nextInstanceOf(time, tz.TZDateTime.now(tz.local)),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('daily_review', 'Nhắc ôn hằng ngày'),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // lặp lại mỗi ngày cùng giờ
    );
  }

  @override
  Future<void> cancel() async {
    if (!isSupported) return;
    await _init();
    await _plugin.cancel(id: _id);
  }
}
