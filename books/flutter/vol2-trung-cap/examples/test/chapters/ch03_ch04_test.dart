import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tap2_so_tu_vung/chapters/ch03/exercise_solution.dart';
import 'package:tap2_so_tu_vung/chapters/ch04/exercise_solution.dart';
import 'package:tap2_so_tu_vung/data/services/database_service.dart';

import '../data/services_test.dart' show sampleJson;

void main() {
  group('Chương 3 — HTTP + JSON', () {
    test('Bài 1: firstAudioUrl bỏ qua audio rỗng và thêm https:', () {
      expect(firstAudioUrl(sampleJson), 'https://ssl.example/negotiate.mp3');
      expect(firstAudioUrl('[{"phonetics":[]}]'), isNull);
      expect(firstAudioUrl('{}'), isNull);
    });
  });

  group('Chương 4 — SQLite', () {
    late Database db;
    setUp(() async {
      sqfliteFfiInit();
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await DatabaseService.createSchemaV1(db);
            await DatabaseService.seed(db);
          },
        ),
      );
    });
    tearDown(() => db.close());

    test('Bài 1: migrateToV3 thêm cột level với giá trị mặc định 1', () async {
      await migrateToV3(db);
      final row = (await db.query('words', where: 'text = ?', whereArgs: ['budget'])).single;
      expect(row['level'], 1);
    });

    test('Bài 2: transaction — lỗi giữa chừng thì không đổi gì', () async {
      await expectLater(renameAll(db, {'budget': 'Budget', 'khong-co': 'x'}), throwsStateError);
      expect(await db.query('words', where: 'text = ?', whereArgs: ['budget']), hasLength(1));
      await renameAll(db, {'budget': 'Budget'});
      expect(await db.query('words', where: 'text = ?', whereArgs: ['Budget']), hasLength(1));
    });
  });
}
