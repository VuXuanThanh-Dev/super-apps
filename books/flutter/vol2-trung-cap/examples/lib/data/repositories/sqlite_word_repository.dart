import 'package:sqflite/sqflite.dart';

import '../../domain/models/word.dart';
import '../../utils/vietnamese.dart';
import '../services/database_service.dart';
import 'word_repository.dart';

/// WordRepository dùng SQLite (sqflite). Luôn dùng tham số `?` — không nối chuỗi SQL (tránh SQL injection).
class SqliteWordRepository implements WordRepository {
  SqliteWordRepository(this._service);

  final DatabaseService _service;
  Database get _db => _service.db;

  static const _select = '''
    SELECT w.*, COUNT(r.id) AS review_count, COALESCE(SUM(r.correct), 0) AS correct_count
    FROM words w LEFT JOIN reviews r ON r.word_id = w.id''';

  @override
  Future<List<Word>> search({String query = '', bool favoritesOnly = false}) async {
    final where = <String>[];
    final args = <Object?>[];
    final q = query.trim().withoutAccents;
    if (q.isNotEmpty) {
      where.add('w.search_key LIKE ?');
      args.add('%$q%');
    }
    if (favoritesOnly) where.add('w.favorite = 1');
    final sql = StringBuffer(_select);
    if (where.isNotEmpty) sql.write(' WHERE ${where.join(' AND ')}');
    sql.write(' GROUP BY w.id ORDER BY w.text COLLATE NOCASE');
    final rows = await _db.rawQuery(sql.toString(), args);
    return rows.map(Word.fromRow).toList();
  }

  @override
  Future<Word?> getById(int id) async {
    final rows = await _db.rawQuery('$_select WHERE w.id = ? GROUP BY w.id', [id]);
    return rows.isEmpty ? null : Word.fromRow(rows.first);
  }

  @override
  Future<Word> toggleFavorite(int id) async {
    final changed = await _db.rawUpdate(
      'UPDATE words SET favorite = CASE favorite WHEN 1 THEN 0 ELSE 1 END WHERE id = ?',
      [id],
    );
    if (changed == 0) throw WordNotFoundException(id);
    return (await getById(id))!;
  }

  @override
  Future<void> recordReview(int wordId, {required bool correct, DateTime? at}) async {
    await _db.insert('reviews', {
      'word_id': wordId,
      'correct': correct ? 1 : 0,
      'reviewed_at': (at ?? DateTime.now()).millisecondsSinceEpoch,
    });
  }

  @override
  Future<List<Word>> dueForReview({int limit = 10}) async {
    final rows = await _db.rawQuery(
      '$_select GROUP BY w.id '
      // Điểm "đã thuộc" = (đúng + 1) / (số lần ôn + 2): từ hay sai < từ mới (0.5) < từ đã thuộc.
      'ORDER BY (COALESCE(SUM(r.correct), 0) + 1.0) / (COUNT(r.id) + 2) ASC, w.text COLLATE NOCASE '
      'LIMIT ?',
      [limit],
    );
    return rows.map(Word.fromRow).toList();
  }

  @override
  Future<ReviewStats> stats({DateTime? now}) async {
    final n = now ?? DateTime.now();
    final startOfDay = DateTime(n.year, n.month, n.day).millisecondsSinceEpoch;
    final total = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM words')) ?? 0;
    final favorites = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM words WHERE favorite = 1')) ?? 0;
    final today =
        Sqflite.firstIntValue(
          await _db.rawQuery('SELECT COUNT(*) FROM reviews WHERE reviewed_at >= ?', [startOfDay]),
        ) ??
        0;
    return ReviewStats(totalWords: total, favorites: favorites, reviewedToday: today);
  }

  @override
  Future<int> resetProgress() => _db.delete('reviews');
}
