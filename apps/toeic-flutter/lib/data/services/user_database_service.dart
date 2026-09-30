import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Mở / tạo cơ sở dữ liệu người dùng `toeic_user.db` (từ đã lưu, thẻ SM-2, kết quả quiz,
/// hoạt động mỗi ngày). Theo cookbook "Persist data with SQLite": `getDatabasesPath()` + `join`,
/// tạo bảng trong `onCreate`. [factory] cho test dùng `databaseFactoryFfi`, web dùng `databaseFactoryFfiWeb`.
class UserDatabaseService {
  UserDatabaseService._(this.db);

  final Database db;

  static const int schemaVersion = 1;
  static const String fileName = 'toeic_user.db';

  static Future<UserDatabaseService> open({DatabaseFactory? factory, String? path}) async {
    final f = factory ?? databaseFactory;
    final dbPath = path ?? (kIsWeb ? fileName : p.join(await f.getDatabasesPath(), fileName));
    final db = await f.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(version: schemaVersion, onCreate: (db, version) => createSchema(db)),
    );
    return UserDatabaseService._(db);
  }

  @visibleForTesting
  static Future<void> createSchema(DatabaseExecutor db) async {
    final batch = db.batch()
      ..execute('CREATE TABLE saved_words (word TEXT PRIMARY KEY NOT NULL, added_at INTEGER NOT NULL)')
      ..execute('''
        CREATE TABLE cards (
          word TEXT PRIMARY KEY NOT NULL, ease REAL NOT NULL, interval INTEGER NOT NULL,
          repetitions INTEGER NOT NULL, due INTEGER NOT NULL, last_review INTEGER, lapses INTEGER NOT NULL DEFAULT 0)''')
      ..execute(
        '''
        CREATE TABLE word_stats (
          word TEXT PRIMARY KEY NOT NULL, correct INTEGER NOT NULL, wrong INTEGER NOT NULL, last_seen INTEGER NOT NULL)''',
      )
      ..execute('''
        CREATE TABLE activity (
          day TEXT PRIMARY KEY NOT NULL, reviews INTEGER NOT NULL DEFAULT 0, quizzes INTEGER NOT NULL DEFAULT 0,
          reads INTEGER NOT NULL DEFAULT 0)''');
    await batch.commit(noResult: true);
  }

  Future<void> close() => db.close();
}
