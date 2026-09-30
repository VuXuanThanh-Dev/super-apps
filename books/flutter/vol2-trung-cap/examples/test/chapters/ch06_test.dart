import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tap2_so_tu_vung/chapters/ch06/exercise_solution.dart';
import 'package:tap2_so_tu_vung/chapters/ch06/speak_button.dart';
import 'package:tap2_so_tu_vung/data/services/tts_service.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../fakes/fakes.dart';
import '../helpers.dart';

void main() {
  group('Chương 6 — device APIs', () {
    testWidgets('SpeakButton gọi TtsService lấy từ provider', (tester) async {
      final tts = FakeTts();
      await pumpApp(
        tester,
        Provider<TtsService>.value(
          value: tts,
          child: const SpeakButton(text: 'deadline'),
        ),
      );
      await tester.tap(find.text('Đọc "deadline"'));
      await tester.pump();
      expect(tts.spoken, ['deadline']);
    });

    test('Bài 1: nextWeeklyInstance — thứ Hai tới lúc 8:00', () {
      tzdata.initializeTimeZones();
      final hcm = tz.getLocation('Asia/Ho_Chi_Minh');
      final wed = tz.TZDateTime(hcm, 2026, 9, 30, 10); // 30/9/2026 là thứ Tư
      expect(wed.weekday, DateTime.wednesday);
      expect(
        nextWeeklyInstance(const TimeOfDay(hour: 8, minute: 0), DateTime.monday, wed),
        tz.TZDateTime(hcm, 2026, 10, 5, 8),
      );
      // Cùng thứ nhưng đã qua giờ → tuần sau
      expect(
        nextWeeklyInstance(const TimeOfDay(hour: 9, minute: 0), DateTime.wednesday, wed),
        tz.TZDateTime(hcm, 2026, 10, 7, 9),
      );
    });
  });
}
