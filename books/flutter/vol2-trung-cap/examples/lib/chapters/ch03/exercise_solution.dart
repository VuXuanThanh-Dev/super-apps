import 'dart:convert';

/// Bài 1 Chương 3: lấy link phát âm đầu tiên trong JSON của Free Dictionary API.
/// API trả "audio": "//ssl.gstatic.com/..." (thiếu scheme) → thêm "https:". Chuỗi rỗng = không có.
String? firstAudioUrl(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! List) return null;
  for (final entry in decoded.whereType<Map<String, Object?>>()) {
    for (final p in (entry['phonetics'] as List? ?? const []).whereType<Map<String, Object?>>()) {
      final audio = p['audio'] as String? ?? '';
      if (audio.isEmpty) continue;
      return audio.startsWith('//') ? 'https:$audio' : audio;
    }
  }
  return null;
}
