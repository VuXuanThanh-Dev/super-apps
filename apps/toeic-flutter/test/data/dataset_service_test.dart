import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:toeic_flutter/data/services/content_service.dart';
import 'package:toeic_flutter/data/services/dataset_service.dart';
import 'package:toeic_flutter/utils/result.dart';

import '../../testing/sample_data.dart';

/// AssetBundle giả: chỉ có các file trong [files]; file khác → FlutterError (giống rootBundle).
class FileAssetBundle extends CachingAssetBundle {
  FileAssetBundle(this.files);
  final Map<String, String> files; // asset key -> đường dẫn file thật

  @override
  Future<ByteData> load(String key) async {
    final path = files[key];
    if (path == null) throw FlutterError('Unable to load asset: "$key".');
    return ByteData.sublistView(File(path).readAsBytesSync());
  }
}

void main() {
  setUpAll(sqfliteFfiInit);

  test('import is lossless: sample.db read back == sample JSON of Task 5 (every field, same order)', () async {
    final ds = await loadSampleDataset();
    final fixture = jsonDecode(File('test/fixtures/sample_dataset.json').readAsStringSync());
    expect(jsonDecode(jsonEncode(ds.toJson())), fixture);
    expect((ds.topics.length, ds.families.length, ds.words.length, ds.collocations.length, ds.passages.length), (
      2,
      9,
      16,
      14,
      2,
    ));
  });

  test('private-data empty → loads the public sample', () async {
    final service = DatasetService(
      bundle: FileAssetBundle({DatasetService.sampleAsset: DatasetService.sampleAsset}),
      factory: databaseFactoryFfi,
    );
    final r = await service.load();
    expect(r, isA<Ok<Object?>>());
    expect((r as Ok).value.source, 'sample');
  });

  test('private-data/toeic.db present → it is used instead of the sample', () async {
    // Tạo một DB "riêng" giả từ bộ mẫu, đổi meta.source = private.
    final dir = await Directory.systemTemp.createTemp('toeic_');
    final path = '${dir.path}/toeic.db';
    File(DatasetService.sampleAsset).copySync(path);
    final db = await databaseFactoryFfi.openDatabase(path);
    await db.update('meta', {'value': 'private'}, where: 'key = ?', whereArgs: ['source']);
    await db.close();
    final service = DatasetService(
      bundle: FileAssetBundle({DatasetService.privateAsset: path, DatasetService.sampleAsset: DatasetService.sampleAsset}),
      factory: databaseFactoryFfi,
    );
    final r = await service.load();
    expect((r as Ok).value.source, 'private');
    await dir.delete(recursive: true);
  });

  test('no asset at all → Result.error (not a crash)', () async {
    final r = await DatasetService(bundle: FileAssetBundle({}), factory: databaseFactoryFfi).load();
    expect(r, isA<Error<Object?>>());
  });

  test('public content (Task 5 own writing + WordNet) loads from assets', () async {
    final c = await ContentService(
      bundle: FileAssetBundle({
        for (final f in ['dialogs', 'function-words', 'generic-glosses', 'irregular'])
          'assets/content/$f.json': 'assets/content/$f.json',
      }),
    ).load();
    expect(c.roleplays, isNotEmpty);
    expect(c.roleplays.first.lines, isNotEmpty);
    expect(c.functionWords['the'], isNotNull);
    expect(c.irregular['ran'], 'run');
    expect(c.genericGlosses, isNotEmpty);
  });
}
