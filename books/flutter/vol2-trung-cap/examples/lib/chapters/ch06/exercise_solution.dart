import 'package:flutter/material.dart' show TimeOfDay;
import 'package:timezone/timezone.dart' as tz;

/// Bài 1 Chương 6: lần tới của [weekday] (DateTime.monday..sunday) lúc [time], tính từ [now].
/// Dùng cho nhắc ôn "mỗi thứ Hai 8:00" (zonedSchedule + DateTimeComponents.dayOfWeekAndTime).
tz.TZDateTime nextWeeklyInstance(TimeOfDay time, int weekday, tz.TZDateTime now) {
  var d = tz.TZDateTime(now.location, now.year, now.month, now.day, time.hour, time.minute);
  while (d.weekday != weekday || !d.isAfter(now)) {
    d = tz.TZDateTime(d.location, d.year, d.month, d.day + 1, time.hour, time.minute);
  }
  return d;
}
