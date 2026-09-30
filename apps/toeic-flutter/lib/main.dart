import 'package:flutter/material.dart';

import 'app.dart';
import 'config/dependencies.dart';
import 'data/repositories/dataset_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/sqlite_user_repository.dart';
import 'data/services/content_service.dart';
import 'data/services/dataset_service.dart';
// Import có điều kiện: trên web dùng SQLite bản WebAssembly, trên iOS/Android không làm gì.
import 'data/services/db_factory_stub.dart' if (dart.library.js_interop) 'data/services/db_factory_web.dart';
import 'data/services/key_value_store.dart';
import 'data/services/reminder_service.dart';
import 'data/services/tts_service.dart';
import 'data/services/user_database_service.dart';
import 'utils/result.dart';

Future<void> main() async {
  // Bắt buộc trước khi dùng plugin (sqflite, shared_preferences…) trước runApp.
  WidgetsFlutterBinding.ensureInitialized();
  configureDatabaseFactory();
  final dataset = switch (await DatasetService().load()) {
    Ok(:final value) => value,
    Error(:final error) => throw StateError('Cannot load dataset: $error'),
  };
  final content = await ContentService().load();
  final userDb = await UserDatabaseService.open();
  runApp(
    ToeicApp(
      dependencies: AppDependencies(
        dataset: DatasetRepository(dataset: dataset, content: content),
        user: SqliteUserRepository(userDb),
        settings: SettingsRepository(SharedPreferencesStore()),
        tts: FlutterTtsService(),
        reminders: LocalNotificationReminderService(),
      ),
    ),
  );
}
