export '../../core/logging/redact.dart' show redact;

/// Chương 4 — kiểm tra deep link TRƯỚC khi dùng (không tin dữ liệu từ bên ngoài).
/// Chấp nhận: `sochichu://notes/<id>` hoặc `https://nobin.dev/notes/<id>`; id chỉ gồm a–z, 0–9, '-' (tối đa 40).
String? parseNoteDeepLink(Uri uri) {
  final idRe = RegExp(r'^[a-z0-9-]{1,40}$');
  final segments = switch (uri) {
    Uri(scheme: 'sochichu', host: 'notes') => uri.pathSegments,
    Uri(scheme: 'https', host: 'nobin.dev') when uri.pathSegments.firstOrNull == 'notes' =>
      uri.pathSegments.skip(1).toList(),
    _ => const <String>[],
  };
  if (segments.length != 1) return null;
  final id = segments.single;
  return idRe.hasMatch(id) ? id : null;
}
