import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' show Sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tap2_so_tu_vung/data/repositories/sqlite_word_repository.dart';
import 'package:tap2_so_tu_vung/data/repositories/word_repository.dart';
import 'package:tap2_so_tu_vung/data/services/database_service.dart';
import 'package:tap2_so_tu_vung/data/services/seed_words.dart';

import '../helpers.dart';

void main() {
  group('DatabaseService (SQLite thật qua FFI)', () {
    test('tạo mới: có bảng words + reviews và 24 từ mẫu', () async {
      final service = await openTestDatabase();
      final tables = await service.db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name");
      expect(tables.map((r) => r['name']), containsAll(['words', 'reviews']));
      expect(Sqflite.firstIntValue(await service.db.rawQuery('SELECT COUNT(*) FROM words')), seedWords.length);
      expect(await service.db.getVersion(), DatabaseService.schemaVersion);
      await service.close();
    });

    test('migration: file DB phiên bản 1 được nâng lên 2, dữ liệu cũ còn nguyên', () async {
      sqfliteFfiInit();
      final dir = await Directory.systemTemp.createTemp('so_tu_vung_');
      final path = p.join(dir.path, 'test.db');
      // 1) Tạo DB "cũ" phiên bản 1 (chưa có bảng reviews).
      final v1 = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await DatabaseService.createSchemaV1(db);
            await DatabaseService.seed(db);
          },
        ),
      );
      await v1.close();
      // 2) Mở bằng code mới → onUpgrade(1 → 2) chạy.
      final service = await DatabaseService.open(factory: databaseFactoryFfi, path: path);
      expect(await service.db.getVersion(), 2);
      final repo = SqliteWordRepository(service);
      final budget = (await repo.search(query: 'budget')).single;
      await repo.recordReview(budget.id, correct: true);
      expect((await repo.getById(budget.id))!.reviewCount, 1);
      await service.close();
      await dir.delete(recursive: true);
    });

    test('khóa ngoại: xóa từ thì xóa luôn lịch sử ôn (ON DELETE CASCADE)', () async {
      final service = await openTestDatabase();
      final repo = SqliteWordRepository(service);
      final w = (await repo.search(query: 'invoice')).single;
      await repo.recordReview(w.id, correct: false);
      await service.db.delete('words', where: 'id = ?', whereArgs: [w.id]);
      expect(Sqflite.firstIntValue(await service.db.rawQuery('SELECT COUNT(*) FROM reviews')), 0);
      await service.close();
    });
  });

  group('SqliteWordRepository', () {
    late DatabaseService service;
    late WordRepository repo;
    setUp(() async {
      service = await openTestDatabase();
      repo = SqliteWordRepository(service);
    });
    tearDown(() => service.close());

    test('search: theo từ, theo nghĩa có dấu và không dấu', () async {
      expect((await repo.search(query: 'nego')).map((w) => w.text), ['negotiate']);
      expect((await repo.search(query: 'đàm phán')).map((w) => w.text), ['negotiate']);
      expect((await repo.search(query: 'dam phan')).map((w) => w.text), ['negotiate']);
      expect((await repo.search(query: 'HÓA ĐƠN')).map((w) => w.text), ['invoice']);
      expect(await repo.search(), hasLength(24));
    });

    test('search an toàn với ký tự đặc biệt (tham số ?, không nối chuỗi SQL)', () async {
      expect(await repo.search(query: "' OR 1=1 --"), isEmpty);
    });

    test('toggleFavorite + lọc yêu thích', () async {
      final w = (await repo.search(query: 'deadline')).single;
      expect((await repo.toggleFavorite(w.id)).favorite, isTrue);
      expect((await repo.search(favoritesOnly: true)).map((w) => w.text), ['deadline']);
      expect((await repo.toggleFavorite(w.id)).favorite, isFalse);
      await expectLater(repo.toggleFavorite(9999), throwsA(isA<WordNotFoundException>()));
    });

    test('recordReview + dueForReview ưu tiên từ hay sai / chưa ôn', () async {
      final all = await repo.search();
      final agenda = all.firstWhere((w) => w.text == 'agenda');
      final approve = all.firstWhere((w) => w.text == 'approve');
      await repo.recordReview(agenda.id, correct: true);
      await repo.recordReview(agenda.id, correct: true);
      await repo.recordReview(approve.id, correct: false);
      final due = await repo.dueForReview(limit: 30);
      expect(due.first.text, 'approve'); // 0 đúng / 1 lần
      expect(due.last.text, 'agenda'); // 2 đúng / 2 lần
      final a = await repo.getById(agenda.id);
      expect((a!.reviewCount, a.correctCount, a.accuracy), (2, 2, 1.0));
    });

    test('Bài 1 (Ch.8): resetProgress xóa lịch sử ôn', () async {
      final w = (await repo.search(query: 'agenda')).single;
      await repo.recordReview(w.id, correct: true);
      await repo.recordReview(w.id, correct: false);
      expect(await repo.resetProgress(), 2);
      expect((await repo.getById(w.id))!.reviewCount, 0);
    });

    test('stats: tổng, yêu thích, ôn hôm nay', () async {
      final now = DateTime(2026, 9, 30, 20);
      final w = (await repo.search(query: 'survey')).single;
      await repo.toggleFavorite(w.id);
      await repo.recordReview(w.id, correct: true, at: now);
      await repo.recordReview(w.id, correct: true, at: now.subtract(const Duration(days: 1)));
      final s = await repo.stats(now: now);
      expect((s.totalWords, s.favorites, s.reviewedToday), (24, 1, 1));
    });
  });
}
