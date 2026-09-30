import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../utils/vietnamese.dart';
import 'seed_words.dart';

/// Mở / tạo / nâng cấp (migrate) cơ sở dữ liệu SQLite của app.
///
/// - Phiên bản 1: bảng `words`.
/// - Phiên bản 2: thêm bảng `reviews` (lịch sử ôn tập) — minh họa `onUpgrade`.
///
/// [factory] cho phép test dùng `databaseFactoryFfi` (SQLite thật chạy trên máy tính),
/// web dùng `databaseFactoryFfiWeb` (SQLite biên dịch sang WebAssembly).
class DatabaseService {
  DatabaseService._(this.db);

  final Database db;

  static const int schemaVersion = 2;
  static const String fileName = 'so_tu_vung.db';

  static Future<DatabaseService> open({DatabaseFactory? factory, String? path}) async {
    final f = factory ?? databaseFactory;
    final dbPath = path ?? (kIsWeb ? fileName : p.join(await f.getDatabasesPath(), fileName));
    final db = await f.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          await createSchemaV1(db);
          await migrateToV2(db);
          await seed(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) await migrateToV2(db);
        },
      ),
    );
    return DatabaseService._(db);
  }

  @visibleForTesting
  static Future<void> createSchemaV1(Database db) async {
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL UNIQUE,
        pos TEXT NOT NULL,
        meaning TEXT NOT NULL,
        example TEXT NOT NULL DEFAULT '',
        search_key TEXT NOT NULL,
        favorite INTEGER NOT NULL DEFAULT 0
      )''');
  }

  @visibleForTesting
  static Future<void> migrateToV2(Database db) async {
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER NOT NULL REFERENCES words(id) ON DELETE CASCADE,
        correct INTEGER NOT NULL,
        reviewed_at INTEGER NOT NULL
      )''');
    await db.execute('CREATE INDEX idx_reviews_word ON reviews(word_id)');
  }

  /// Chèn dữ liệu mẫu trong MỘT transaction (nhanh và "tất cả hoặc không gì cả").
  @visibleForTesting
  static Future<void> seed(DatabaseExecutor db) async {
    final batch = db.batch();
    for (final (text, pos, meaning, example) in seedWords) {
      batch.insert('words', {
        'text': text,
        'pos': pos,
        'meaning': meaning,
        'example': example,
        'search_key': searchKey(text, meaning),
      });
    }
    await batch.commit(noResult: true);
  }

  /// Chuỗi dùng để tìm kiếm: từ + nghĩa, viết thường, bỏ dấu.
  static String searchKey(String text, String meaning) => '$text $meaning'.withoutAccents;

  Future<void> close() => db.close();
}
