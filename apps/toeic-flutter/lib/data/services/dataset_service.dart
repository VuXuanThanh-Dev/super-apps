import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../domain/models/dataset.dart';
import '../../utils/result.dart';

/// Đọc bộ dữ liệu TOEIC (chỉ đọc) từ file SQLite đóng gói trong app (asset).
///
/// - Nếu có `private-data/toeic.db` (dữ liệu từ sách, tạo bằng `tools/build_data.sh`) → dùng nó.
/// - Nếu không (private-data rỗng) → dùng bộ mẫu công khai `assets/data/sample.db`.
///
/// sqflite chỉ mở được FILE, nên ta ghi bytes của asset ra một file DB (`writeDatabaseBytes` —
/// chạy được cả iOS/Android lẫn web Wasm), mở chỉ-đọc, đọc hết vào bộ nhớ rồi đóng.
/// Bộ dữ liệu nhỏ (~1.100 từ) nên tra từ trong bộ nhớ là nhanh nhất và offline hoàn toàn.
class DatasetService {
  DatasetService({AssetBundle? bundle, this._factory}) : _bundle = bundle ?? rootBundle;

  static const String privateAsset = 'private-data/toeic.db';
  static const String sampleAsset = 'assets/data/sample.db';
  static const String fileName = 'toeic_dataset.db';

  final AssetBundle _bundle;
  final DatabaseFactory? _factory;

  Future<Result<Dataset>> load() async {
    try {
      final bytes = await _loadAsset();
      final f = _factory ?? databaseFactory;
      final path = kIsWeb ? fileName : p.join(await f.getDatabasesPath(), fileName);
      await f.writeDatabaseBytes(path, bytes);
      final db = await f.openDatabase(path, options: OpenDatabaseOptions(readOnly: true));
      try {
        return Result.ok(await readDataset(db));
      } finally {
        await db.close();
      }
    } on Exception catch (e) {
      return Result.error(e);
    } on FlutterError catch (e) {
      // Không có cả bộ mẫu (build lỗi) → trả lỗi thay vì crash.
      return Result.error(Exception(e.message));
    }
  }

  Future<Uint8List> _loadAsset() async {
    try {
      final data = await _bundle.load(privateAsset);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (_) {
      // private-data rỗng: asset không tồn tại (rootBundle ném FlutterError) → bộ mẫu.
      final data = await _bundle.load(sampleAsset);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
  }

  /// Đọc mọi bảng thành [Dataset]. Schema do `tools/import_dataset.py` tạo ra.
  static Future<Dataset> readDataset(DatabaseExecutor db) async {
    Future<List<Map<String, Object?>>> q(String sql) => db.rawQuery(sql);
    final meta = {for (final r in await q('SELECT key, value FROM meta')) r['key']! as String: r['value']! as String};
    final members = <String, List<String>>{};
    for (final r in await q('SELECT family_id, word_id FROM family_members ORDER BY family_id, pos')) {
      (members[r['family_id']! as String] ??= []).add(r['word_id']! as String);
    }
    final wordFamilies = <String, List<String>>{};
    for (final r in await q('SELECT word_id, family_id FROM word_families ORDER BY word_id, pos')) {
      (wordFamilies[r['word_id']! as String] ??= []).add(r['family_id']! as String);
    }
    final questions = <String, List<Question>>{};
    for (final r in await q('SELECT * FROM questions ORDER BY passage_id, pos')) {
      (questions[r['passage_id']! as String] ??= []).add(
        Question(
          question: r['question']! as String,
          options: (jsonDecode(r['options']! as String) as List<Object?>).cast<String>(),
          answer: r['answer']! as int,
        ),
      );
    }
    return Dataset(
      version: int.parse(meta['version'] ?? '1'),
      source: meta['source'] ?? 'sample',
      topics: [
        for (final r in await q('SELECT * FROM topics ORDER BY ord'))
          Topic(code: r['code']! as String, book: r['book']! as String, en: r['en']! as String, vi: r['vi']! as String),
      ],
      families: [
        for (final r in await q('SELECT * FROM families ORDER BY ord'))
          Family(
            id: r['id']! as String,
            headword: r['headword']! as String,
            topic: r['topic']! as String,
            book: r['book']! as String,
            band850: r['band850'] == 1,
            members: members[r['id']] ?? const [],
            tip: r['tip'] as String?,
            page: r['page'] as int?,
          ),
      ],
      words: [
        for (final r in await q('SELECT * FROM words ORDER BY ord'))
          Word(
            id: r['id']! as String,
            word: r['word']! as String,
            lemma: r['lemma']! as String,
            pos: r['pos']! as String,
            ipa: r['ipa'] as String?,
            ipaSource: r['ipa_source'] as String?,
            definition: r['definition'] as String?,
            example: r['example'] as String?,
            vi: r['vi'] as String?,
            note: r['note'] as String?,
            topic: r['topic']! as String,
            book: r['book']! as String,
            family: r['family']! as String,
            families: wordFamilies[r['id']] ?? const [],
            isHead: r['is_head'] == 1,
          ),
      ],
      collocations: [
        for (final r in await q('SELECT * FROM collocations ORDER BY ord'))
          Collocation(
            id: r['id']! as String,
            family: r['family']! as String,
            phrase: r['phrase']! as String,
            vi: r['vi']! as String,
            example: r['example']! as String,
          ),
      ],
      passages: [
        for (final r in await q('SELECT * FROM passages ORDER BY ord'))
          Passage(
            id: r['id']! as String,
            topic: r['topic']! as String,
            title: r['title']! as String,
            text: r['text']! as String,
            questions: questions[r['id']] ?? const [],
          ),
      ],
      glosses: {
        for (final r in await q('SELECT * FROM glosses ORDER BY ord'))
          r['word']! as String: Gloss(pos: r['pos']! as String, definition: r['definition']! as String),
      },
    );
  }
}
