import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tap2_so_tu_vung/data/repositories/settings_repository.dart';
import 'package:tap2_so_tu_vung/data/services/dictionary_client.dart';
import 'package:tap2_so_tu_vung/data/services/key_value_store.dart';
import 'package:tap2_so_tu_vung/data/services/reminder_service.dart';
import 'package:tap2_so_tu_vung/utils/result.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const sampleJson = '''
[{"word":"negotiate","phonetics":[{"text":"x","audio":""},{"audio":"//ssl.example/negotiate.mp3"}],
  "meanings":[{"partOfSpeech":"verb","definitions":[
    {"definition":"try to reach an agreement by discussion","example":"we negotiated a deal"},
    {"definition":"find a way over or through"}]}]}]
''';

void main() {
  group('SettingsRepository (key-value)', () {
    test('mặc định và lưu lại theme, giờ nhắc, tốc độ đọc', () async {
      final repo = SettingsRepository(MemoryStore());
      expect(await repo.themeMode(), ThemeMode.system);
      expect(await repo.reminderTime(), isNull);
      expect(await repo.speechRate(), 0.5);
      await repo.setThemeMode(ThemeMode.dark);
      await repo.setReminderTime(const TimeOfDay(hour: 7, minute: 5));
      await repo.setSpeechRate(0.75);
      expect(await repo.themeMode(), ThemeMode.dark);
      expect(await repo.reminderTime(), const TimeOfDay(hour: 7, minute: 5));
      expect(await repo.speechRate(), 0.75);
      await repo.setReminderTime(null);
      expect(await repo.reminderTime(), isNull);
    });

    test('parseTime bỏ qua dữ liệu hỏng', () {
      expect(SettingsRepository.parseTime('25:00'), isNull);
      expect(SettingsRepository.parseTime('abc'), isNull);
      expect(SettingsRepository.parseTime('9:30'), const TimeOfDay(hour: 9, minute: 30));
      expect(SettingsRepository.formatTime(const TimeOfDay(hour: 9, minute: 5)), '09:05');
    });
  });

  group('nextInstanceOf (lịch nhắc hằng ngày)', () {
    setUpAll(tzdata.initializeTimeZones);

    test('hôm nay nếu chưa tới giờ, ngày mai nếu đã qua', () {
      final hcm = tz.getLocation('Asia/Ho_Chi_Minh');
      final now = tz.TZDateTime(hcm, 2026, 9, 30, 19, 0);
      expect(nextInstanceOf(const TimeOfDay(hour: 20, minute: 0), now), tz.TZDateTime(hcm, 2026, 9, 30, 20));
      expect(nextInstanceOf(const TimeOfDay(hour: 19, minute: 0), now), tz.TZDateTime(hcm, 2026, 10, 1, 19));
      expect(nextInstanceOf(const TimeOfDay(hour: 6, minute: 30), now), tz.TZDateTime(hcm, 2026, 10, 1, 6, 30));
    });
  });

  group('DictionaryClient (HTTP + JSON, MockClient)', () {
    test('200: tách định nghĩa, gọi đúng URL', () async {
      Uri? called;
      final client = DictionaryClient(
        client: MockClient((req) async {
          called = req.url;
          return http.Response(sampleJson, 200);
        }),
      );
      final result = await client.lookup('negotiate');
      expect(called.toString(), 'https://api.dictionaryapi.dev/api/v2/entries/en/negotiate');
      switch (result) {
        case Ok(:final value):
          expect(value, hasLength(2));
          expect(value.first.partOfSpeech, 'verb');
          expect(value.first.example, 'we negotiated a deal');
          expect(value.last.example, isNull);
        case Error():
          fail('không mong đợi lỗi: $result');
      }
    });

    test('404, 500, JSON hỏng, mất mạng → Result.error với thông báo tiếng Việt', () async {
      Future<String> errorOf(http.Response Function() respond) async {
        final r = await DictionaryClient(client: MockClient((_) async => respond())).lookup('x');
        return (r as Error).error.toString();
      }

      expect(await errorOf(() => http.Response('', 404)), contains('Không tìm thấy'));
      expect(await errorOf(() => http.Response('', 500)), contains('500'));
      expect(await errorOf(() => http.Response('{not json', 200)), contains('định dạng'));
      final offline = await DictionaryClient(client: MockClient((_) async => throw http.ClientException('offline')))
          .lookup('x');
      expect((offline as Error).error.toString(), contains('Không kết nối được'));
    });

    test('hết thời gian chờ', () async {
      final client = DictionaryClient(
        timeout: const Duration(milliseconds: 20),
        client: MockClient((_) => Future.delayed(const Duration(seconds: 1), () => http.Response('[]', 200))),
      );
      expect(((await client.lookup('x')) as Error).error.toString(), contains('Hết thời gian'));
    });
  });
}
