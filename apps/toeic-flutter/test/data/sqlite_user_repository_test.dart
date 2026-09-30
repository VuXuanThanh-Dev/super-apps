import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:toeic_flutter/data/repositories/settings_repository.dart';
import 'package:toeic_flutter/data/repositories/sqlite_user_repository.dart';
import 'package:toeic_flutter/data/services/key_value_store.dart';
import 'package:toeic_flutter/data/services/user_database_service.dart';
import 'package:toeic_flutter/domain/models/user_data.dart';
import 'package:toeic_flutter/domain/srs/sm2.dart';
import 'package:toeic_flutter/utils/result.dart';
import 'package:flutter/material.dart' show ThemeMode, TimeOfDay;

T ok<T>(Result<T> r) => switch (r) {
  Ok(:final value) => value,
  Error(:final error) => throw error,
};

void main() {
  late UserDatabaseService service;
  late SqliteUserRepository repo;
  var notified = 0;

  setUp(() async {
    sqfliteFfiInit();
    // SQLite THẬT (FFI), trong bộ nhớ — mỗi test một DB mới.
    service = await UserDatabaseService.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    repo = SqliteUserRepository(service, clock: () => DateTime(2026, 9, 28));
    notified = 0;
    repo.changes.addListener(() => notified++);
  });
  tearDown(() => service.close());

  test('saved words: add (case-insensitive), list, remove', () async {
    ok(await repo.setSaved('Company', saved: true));
    ok(await repo.setSaved('ticket', saved: true));
    expect(ok(await repo.isSaved('COMPANY')), isTrue);
    expect(ok(await repo.savedWords()).map((s) => s.word), containsAll(['company', 'ticket']));
    ok(await repo.setSaved('company', saved: false));
    expect(ok(await repo.isSaved('company')), isFalse);
    expect(notified, 3);
  });

  test('cards: save and read back (insert or replace)', () async {
    var c = newCard('run', 100);
    ok(await repo.saveCard(c));
    c = review(c, Grade.good, 100);
    ok(await repo.saveCard(c));
    final cards = ok(await repo.cards());
    expect(cards, hasLength(1));
    expect((cards.single.word, cards.single.interval, cards.single.due, cards.single.lastReview), ('run', 1, 101, 100));
  });

  test('answers are counted per word (UPSERT)', () async {
    ok(await repo.recordAnswer('delay', correct: true, day: 1));
    ok(await repo.recordAnswer('delay', correct: false, day: 2));
    ok(await repo.recordAnswer('Delay', correct: false, day: 3));
    final s = ok(await repo.wordStats()).single;
    expect((s.word, s.correct, s.wrong, s.lastSeen), ('delay', 1, 2, 3));
  });

  test('activity per day and kind', () async {
    ok(await repo.recordActivity('2026-09-28', ActivityKind.review));
    ok(await repo.recordActivity('2026-09-28', ActivityKind.review));
    ok(await repo.recordActivity('2026-09-28', ActivityKind.quiz));
    ok(await repo.recordActivity('2026-09-27', ActivityKind.read));
    final a = ok(await repo.activity());
    expect(a.map((d) => d.day), ['2026-09-27', '2026-09-28']);
    expect((a[1].reviews, a[1].quizzes, a[1].reads), (2, 1, 0));
  });

  test('reset deletes all progress', () async {
    ok(await repo.setSaved('run', saved: true));
    ok(await repo.saveCard(newCard('run', 1)));
    ok(await repo.reset());
    expect(ok(await repo.savedWords()), isEmpty);
    expect(ok(await repo.cards()), isEmpty);
  });

  test('errors become Result.error (closed database)', () async {
    await service.close();
    expect(await repo.cards(), isA<Error<List<Card>>>());
    service = await UserDatabaseService.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
  });

  test('settings repository keeps theme and reminder time', () async {
    final settings = SettingsRepository(MemoryStore());
    expect(await settings.themeMode(), ThemeMode.system);
    await settings.setThemeMode(ThemeMode.dark);
    expect(await settings.themeMode(), ThemeMode.dark);
    await settings.setReminderTime(const TimeOfDay(hour: 7, minute: 5));
    expect(SettingsRepository.formatTime((await settings.reminderTime())!), '07:05');
  });
}
