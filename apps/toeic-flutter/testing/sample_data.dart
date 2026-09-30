import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:toeic_flutter/data/repositories/dataset_repository.dart';
import 'package:toeic_flutter/data/services/content_service.dart';
import 'package:toeic_flutter/data/services/dataset_service.dart';
import 'package:toeic_flutter/domain/models/dataset.dart';

/// Đọc bộ mẫu CÔNG KHAI `assets/data/sample.db` bằng SQLite thật (FFI) — test luôn dùng bộ mẫu,
/// kể cả khi private-data có dữ liệu, để kết quả test giống nhau trên mọi máy.
Future<Dataset> loadSampleDataset() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    File(DatasetService.sampleAsset).absolute.path,
    options: OpenDatabaseOptions(readOnly: true),
  );
  try {
    return await DatasetService.readDataset(db);
  } finally {
    await db.close();
  }
}

PublicContent loadPublicContent() => PublicContent.fromJsonStrings(
  dialogs: File('assets/content/dialogs.json').readAsStringSync(),
  functionWords: File('assets/content/function-words.json').readAsStringSync(),
  genericGlosses: File('assets/content/generic-glosses.json').readAsStringSync(),
  irregular: File('assets/content/irregular.json').readAsStringSync(),
);

Future<DatasetRepository> loadSampleRepository() async =>
    DatasetRepository(dataset: await loadSampleDataset(), content: loadPublicContent());
