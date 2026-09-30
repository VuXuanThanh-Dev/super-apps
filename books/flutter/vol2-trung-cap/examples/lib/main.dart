import 'package:flutter/material.dart';

import 'app.dart';
import 'config/dependencies.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/sqlite_word_repository.dart';
import 'data/services/database_service.dart';
// Import có điều kiện: trên web dùng bản WebAssembly của SQLite, trên iOS/Android không làm gì.
import 'data/services/db_factory_stub.dart' if (dart.library.js_interop) 'data/services/db_factory_web.dart';
import 'data/services/dictionary_client.dart';
import 'data/services/key_value_store.dart';
import 'data/services/reminder_service.dart';
import 'data/services/tts_service.dart';

Future<void> main() async {
  // Bắt buộc trước khi gọi plugin (sqflite, shared_preferences…) trước runApp.
  WidgetsFlutterBinding.ensureInitialized();
  configureDatabaseFactory();
  final database = await DatabaseService.open();
  runApp(
    VocabApp(
      dependencies: AppDependencies(
        words: SqliteWordRepository(database),
        settings: SettingsRepository(SharedPreferencesStore()),
        tts: FlutterTtsService(),
        reminders: LocalNotificationReminderService(),
        dictionary: DictionaryClient(),
      ),
    ),
  );
}
