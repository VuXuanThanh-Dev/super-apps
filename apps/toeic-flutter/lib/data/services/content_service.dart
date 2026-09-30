import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/dataset.dart';

/// Nội dung CÔNG KHAI (không lấy từ sách), chép từ Task 5 bằng `tools/sync_from_toeic.sh`:
/// hội thoại nhập vai và từ chức năng (tự viết), định nghĩa WordNet 3.0 và bảng từ bất quy tắc (WordNet).
class PublicContent {
  const PublicContent({
    required this.roleplays,
    required this.functionWords,
    required this.genericGlosses,
    required this.irregular,
  });

  final List<Roleplay> roleplays;
  final Map<String, FunctionWord> functionWords;
  final Map<String, Gloss> genericGlosses;
  final Map<String, String> irregular;

  /// Tạo từ các chuỗi JSON (dùng chung cho app và test).
  factory PublicContent.fromJsonStrings({
    required String dialogs,
    required String functionWords,
    required String genericGlosses,
    required String irregular,
  }) {
    Map<String, Object?> obj(String s) => (jsonDecode(s) as Map<String, Object?>);
    return PublicContent(
      roleplays: [
        for (final d in (jsonDecode(dialogs) as List<Object?>).cast<Map<String, Object?>>()) Roleplay.fromJson(d),
      ],
      functionWords: {
        for (final e in obj(functionWords).entries) e.key: FunctionWord.fromJson(e.value! as Map<String, Object?>),
      },
      genericGlosses: {
        for (final e in obj(genericGlosses).entries) e.key: Gloss.fromJson(e.value! as Map<String, Object?>),
      },
      irregular: obj(irregular).cast<String, String>(),
    );
  }
}

class ContentService {
  ContentService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<PublicContent> load() async => PublicContent.fromJsonStrings(
    dialogs: await _bundle.loadString('assets/content/dialogs.json'),
    functionWords: await _bundle.loadString('assets/content/function-words.json'),
    genericGlosses: await _bundle.loadString('assets/content/generic-glosses.json'),
    irregular: await _bundle.loadString('assets/content/irregular.json'),
  );
}
