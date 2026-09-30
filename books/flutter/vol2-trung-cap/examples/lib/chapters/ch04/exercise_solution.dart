import 'package:sqflite/sqflite.dart';

/// Bài 1 Chương 4: migration phiên bản 3 — thêm cột `level` (1..3) cho bảng words.
/// ALTER TABLE ADD COLUMN phải có DEFAULT nếu cột NOT NULL (các dòng cũ cần giá trị).
Future<void> migrateToV3(Database db) async {
  await db.execute('ALTER TABLE words ADD COLUMN level INTEGER NOT NULL DEFAULT 1');
}

/// Bài 2: đổi tên hàng loạt trong MỘT transaction — lỗi giữa chừng thì không dòng nào bị đổi.
Future<void> renameAll(Database db, Map<String, String> renames) {
  return db.transaction((txn) async {
    for (final e in renames.entries) {
      final n = await txn.rawUpdate('UPDATE words SET text = ? WHERE text = ?', [e.value, e.key]);
      if (n == 0) throw StateError('Không có từ "${e.key}"');
    }
  });
}
