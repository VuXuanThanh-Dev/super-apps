import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tap2_so_tu_vung/config/dependencies.dart';
import 'package:tap2_so_tu_vung/data/repositories/settings_repository.dart';
import 'package:tap2_so_tu_vung/data/services/database_service.dart';
import 'package:tap2_so_tu_vung/data/services/dictionary_client.dart';
import 'package:tap2_so_tu_vung/data/services/key_value_store.dart';
import 'package:tap2_so_tu_vung/ui/core/theme.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'fakes/fakes.dart';

/// SQLite THẬT chạy trên máy tính (qua FFI), trong bộ nhớ — mỗi lần gọi là một DB mới.
Future<DatabaseService> openTestDatabase() {
  sqfliteFfiInit();
  return DatabaseService.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
}

Future<void> pumpApp(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: child),
  ),
);

/// Bộ phụ thuộc giả cho test toàn app.
AppDependencies fakeDependencies({
  FakeWordRepository? words,
  FakeTts? tts,
  FakeReminderService? reminders,
  http.Client? httpClient,
}) => AppDependencies(
  words: words ?? FakeWordRepository(),
  settings: SettingsRepository(MemoryStore()),
  tts: tts ?? FakeTts(),
  reminders: reminders ?? FakeReminderService(),
  dictionary: DictionaryClient(client: httpClient ?? MockClient((_) async => http.Response('[]', 200))),
);
