import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tap2_so_tu_vung/data/repositories/settings_repository.dart';
import 'package:tap2_so_tu_vung/data/services/key_value_store.dart';
import 'package:tap2_so_tu_vung/data/services/reminder_service.dart';
import 'package:tap2_so_tu_vung/ui/review/review_viewmodel.dart';
import 'package:tap2_so_tu_vung/ui/settings/settings_viewmodel.dart';
import 'package:tap2_so_tu_vung/ui/word_list/word_list_viewmodel.dart';

import '../fakes/fakes.dart';

/// Mock bằng mocktail: dùng khi cần KIỂM TRA LỜI GỌI (verify), không cần viết cài đặt.
class MockReminderService extends Mock implements ReminderService {}

void main() {
  setUpAll(() => registerFallbackValue(const TimeOfDay(hour: 0, minute: 0)));

  group('WordListViewModel', () {
    test('tải lần đầu, tìm không dấu, lọc yêu thích', () async {
      final repo = FakeWordRepository();
      final vm = WordListViewModel(repository: repo);
      await pumpEventQueue();
      expect(vm.words.map((w) => w.text), ['budget', 'invoice', 'negotiate']);
      await vm.search('dam phan');
      expect(vm.words.single.text, 'negotiate');
      await vm.search('');
      await vm.toggleFavorite(3);
      await vm.setFavoritesOnly(true);
      expect(vm.words.single.text, 'invoice');
      await vm.toggleFavorite(3); // bỏ yêu thích khi đang lọc → biến khỏi danh sách
      expect(vm.words, isEmpty);
    });

    test('bỏ qua kết quả CŨ về muộn (giống switchMap)', () async {
      final repo = FakeWordRepository();
      final vm = WordListViewModel(repository: repo);
      await pumpEventQueue();
      final slow = Completer<void>();
      repo.searchGate = slow;
      final first = vm.search('b'); // chờ cổng
      repo.searchGate = null;
      await vm.search('inv'); // yêu cầu mới xong trước
      expect(vm.words.single.text, 'invoice');
      slow.complete();
      await first; // kết quả cũ ('budget') về sau → phải bị bỏ
      expect(vm.words.single.text, 'invoice');
      expect(vm.loading, isFalse);
    });

    test('lỗi → error, thử lại → hết lỗi', () async {
      final repo = FakeWordRepository()..failNextSearch = Exception('ổ đĩa hỏng');
      final vm = WordListViewModel(repository: repo);
      await pumpEventQueue();
      expect(vm.error, isNotNull);
      await vm.refresh();
      expect(vm.error, isNull);
      expect(vm.words, hasLength(3));
    });
  });

  group('ReviewViewModel (Command)', () {
    test('lật thẻ, trả lời, hết lượt, thống kê', () async {
      final repo = FakeWordRepository();
      final vm = ReviewViewModel(repository: repo, batchSize: 2);
      await pumpEventQueue();
      expect(vm.start.completed, isTrue);
      expect(vm.current!.text, 'budget');
      await vm.answer.execute(true); // chưa lật → bỏ qua
      expect(repo.reviews, isEmpty);
      vm.reveal();
      await vm.answer.execute(true);
      vm.reveal();
      await vm.answer.execute(false);
      expect(vm.finished, isTrue);
      expect((vm.correct, vm.total), (1, 2));
      expect(repo.reviews, [(1, true), (3, false)]);
      expect(vm.stats!.reviewedToday, 2);
    });
  });

  group('SettingsViewModel', () {
    test('theme đổi ngay và được lưu', () async {
      final store = MemoryStore();
      final vm = SettingsViewModel(
        settings: SettingsRepository(store),
        reminders: FakeReminderService(),
        tts: FakeTts(),
      );
      await vm.setThemeMode(ThemeMode.dark);
      expect(vm.themeMode, ThemeMode.dark);
      expect(await SettingsRepository(store).themeMode(), ThemeMode.dark);
    });

    test('bật nhắc: xin quyền → đặt lịch (verify bằng mocktail)', () async {
      final reminders = MockReminderService();
      when(() => reminders.isSupported).thenReturn(true);
      when(reminders.requestPermission).thenAnswer((_) async => true);
      when(() => reminders.scheduleDaily(any())).thenAnswer((_) async {});
      final vm = SettingsViewModel(settings: SettingsRepository(MemoryStore()), reminders: reminders, tts: FakeTts());
      await vm.setReminder(const TimeOfDay(hour: 20, minute: 0));
      verify(reminders.requestPermission).called(1);
      verify(() => reminders.scheduleDaily(const TimeOfDay(hour: 20, minute: 0))).called(1);
      expect(vm.message, 'Sẽ nhắc lúc 20:00 mỗi ngày');
    });

    test('không có quyền / web → không đặt lịch, có thông báo', () async {
      final denied = FakeReminderService(grant: false);
      final vm = SettingsViewModel(settings: SettingsRepository(MemoryStore()), reminders: denied, tts: FakeTts());
      await vm.setReminder(const TimeOfDay(hour: 7, minute: 0));
      expect(denied.scheduled, isNull);
      expect(vm.message, contains('Chưa được cấp quyền'));

      final web = FakeReminderService(isSupported: false);
      final vm2 = SettingsViewModel(settings: SettingsRepository(MemoryStore()), reminders: web, tts: FakeTts());
      await vm2.setReminder(const TimeOfDay(hour: 7, minute: 0));
      expect(vm2.message, 'Bản web không hỗ trợ nhắc theo lịch');
    });

    test('tốc độ đọc được truyền cho TTS', () async {
      final tts = FakeTts();
      final vm = SettingsViewModel(
        settings: SettingsRepository(MemoryStore()),
        reminders: FakeReminderService(),
        tts: tts,
      );
      await vm.setSpeechRate(0.8);
      expect(tts.rate, 0.8);
    });
  });
}
