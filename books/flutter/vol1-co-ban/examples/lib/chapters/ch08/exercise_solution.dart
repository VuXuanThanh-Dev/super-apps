/// Bài 1 Chương 8: chỉ cho phép quay lại (redirect) tới đường dẫn NỘI BỘ.
/// Chặn "open redirect": `https://evil.com`, `//evil.com`, `javascript:...`.
String safeRedirectTarget(String? from, {String fallback = '/'}) {
  if (from == null || from.isEmpty) return fallback;
  if (!from.startsWith('/') || from.startsWith('//')) return fallback;
  final uri = Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return fallback;
  return from;
}
