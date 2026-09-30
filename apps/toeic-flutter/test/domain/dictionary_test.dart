// Port từ Task 5: apps/toeic/src/features/lookup/__tests__/dictionary.test.ts (+ bộ dữ liệu riêng nếu có).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:toeic_flutter/data/repositories/dataset_repository.dart';
import 'package:toeic_flutter/data/services/dataset_service.dart';
import 'package:toeic_flutter/domain/lookup/dictionary.dart';

import '../../testing/sample_data.dart';

void main() {
  late DatasetRepository repo;
  setUpAll(() async => repo = await loadSampleRepository());

  EntryResult entry(String q) {
    final r = repo.lookup(q);
    expect(r, isA<EntryResult>(), reason: q);
    return r as EntryResult;
  }

  group('Dictionary (sample dataset, offline)', () {
    test('finds a dataset word with family and collocations', () {
      final r = entry('manage');
      expect(r.word.vi, 'quản lý');
      expect(r.word.definition, isNotEmpty);
      expect(r.word.ipa, startsWith('/'));
      expect(r.family.map((w) => w.word), ['manage', 'manager', 'management']);
      expect(r.collocations, isNotEmpty);
    });

    test('maps irregular forms to the lemma: ran -> run', () {
      final r = entry('ran');
      expect(r.word.word, 'run');
      expect(r.via, 'ran → run');
    });

    test("maps plurals and possessives: companies, company's -> company", () {
      for (final q in ['companies', "company's", 'Company', 'COMPANIES', "companies'", 'company’s']) {
        expect(entry(q).word.word, 'company', reason: q);
      }
    });

    test('strips punctuation around the word', () {
      expect(entry('"meetings,"').word.word, 'meeting');
    });

    test('handles verb forms: delayed, booking, reports, met', () {
      for (final (q, lemma) in [
        ('delayed', 'delayed'),
        ('delays', 'delay'),
        ('booking', 'booking'),
        ('booked', 'book'),
        ('reports', 'report'),
        ('met', 'meet'),
        ('managed', 'manage'),
        ('managing', 'manage'),
      ]) {
        expect(entry(q).word.word, lemma, reason: q);
      }
    });

    test("explains contractions: don't -> do (function word)", () {
      final r = repo.lookup("don't");
      expect(r, isA<FunctionWordResult>());
      r as FunctionWordResult;
      expect(r.lemma, 'do');
      expect(r.contraction, "don't = do not");
    });

    test('uses WordNet glosses for other words in the app texts', () {
      expect(repo.lookup('printer'), isA<GlossResult>());
    });

    test('shows not found for unknown words', () {
      expect(repo.lookup('blorptastic'), isA<NotFoundResult>());
      expect(repo.lookup('   '), isA<NotFoundResult>());
      expect(repo.lookup('...'), isA<NotFoundResult>());
    });
  });

  // Chỉ chạy trên máy đã build dữ liệu riêng (tools/build_data.sh) — giống Task 5.
  final privateDb = File(DatasetService.privateAsset);
  group('private dataset (only when private-data/toeic.db exists)', () {
    test('is complete and maps word forms to book entries', () async {
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase(
        privateDb.absolute.path,
        options: OpenDatabaseOptions(readOnly: true),
      );
      final ds = await DatasetService.readDataset(db);
      await db.close();
      expect(ds.source, 'private');
      expect(ds.families.where((f) => f.book == 'tap1' || f.book == 'tap2'), hasLength(312));
      expect(ds.words.length, greaterThanOrEqualTo(1100));
      final full = DatasetRepository(dataset: ds, content: loadPublicContent());
      for (final (q, lemma) in [
        ('negotiations', 'negotiation'),
        ('complied', 'comply'),
        ('Agreements', 'agreement'),
        ("supplier's", 'supplier'),
        ('shipped', 'ship'),
        ('renewing', 'renew'),
      ]) {
        final r = full.lookup(q);
        expect(r, isA<EntryResult>(), reason: q);
        expect((r as EntryResult).word.word, lemma);
      }
    });
  }, skip: privateDb.existsSync() ? false : 'private-data/toeic.db not found (private-data empty)');
}
