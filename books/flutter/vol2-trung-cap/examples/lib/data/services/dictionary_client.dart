import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../utils/result.dart';

/// Một nghĩa tiếng Anh lấy từ từ điển online.
class Definition {
  const Definition({required this.partOfSpeech, required this.definition, this.example});

  final String partOfSpeech;
  final String definition;
  final String? example;

  /// Ép kiểu cẩn thận: JSON từ mạng có thể thiếu trường.
  factory Definition.fromJson(String partOfSpeech, Map<String, Object?> json) => Definition(
    partOfSpeech: partOfSpeech,
    definition: json['definition'] as String? ?? '',
    example: json['example'] as String?,
  );
}

class DictionaryException implements Exception {
  const DictionaryException(this.message);
  final String message;
  @override
  String toString() => 'DictionaryException: $message';
}

/// Client cho Free Dictionary API (`https://api.dictionaryapi.dev/api/v2/entries/en/<word>`).
/// Nhận `http.Client` qua constructor → test thay bằng `MockClient` (không cần mạng).
class DictionaryClient {
  DictionaryClient({http.Client? client, this.timeout = const Duration(seconds: 8)})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  static Uri uriFor(String word) =>
      Uri.https('api.dictionaryapi.dev', '/api/v2/entries/en/${Uri.encodeComponent(word.trim())}');

  Future<Result<List<Definition>>> lookup(String word) async {
    try {
      final response = await _client.get(uriFor(word)).timeout(timeout);
      if (response.statusCode == 404) return const Result.error(DictionaryException('Không tìm thấy từ này'));
      if (response.statusCode != 200) {
        return Result.error(DictionaryException('Lỗi máy chủ (${response.statusCode})'));
      }
      return Result.ok(parseDefinitions(utf8.decode(response.bodyBytes)));
    } on TimeoutException {
      return const Result.error(DictionaryException('Hết thời gian chờ'));
    } on FormatException {
      return const Result.error(DictionaryException('Dữ liệu trả về không đúng định dạng'));
    } on http.ClientException catch (e) {
      return Result.error(DictionaryException('Không kết nối được: ${e.message}'));
    }
  }

  void close() => _client.close();
}

/// Tách JSON (mảng các entry → meanings → definitions) thành danh sách phẳng.
List<Definition> parseDefinitions(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! List) throw const FormatException('Cần một mảng JSON');
  return [
    for (final entry in decoded.whereType<Map<String, Object?>>())
      for (final meaning in (entry['meanings'] as List? ?? const []).whereType<Map<String, Object?>>())
        for (final d in (meaning['definitions'] as List? ?? const []).whereType<Map<String, Object?>>())
          Definition.fromJson(meaning['partOfSpeech'] as String? ?? '?', d),
  ];
}
