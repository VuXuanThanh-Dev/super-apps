/// Chương 6 — so sánh version "x.y.z" (bỏ qua "+build") để quyết định có bắt cập nhật không.
int compareVersions(String a, String b) {
  List<int> parse(String v) => v.split('+').first.split('.').map(int.parse).toList();
  final pa = parse(a), pb = parse(b);
  for (var i = 0; i < 3; i++) {
    final c = pa[i].compareTo(pb[i]);
    if (c != 0) return c;
  }
  return 0;
}

/// Bắt cập nhật khi bản đang cài thấp hơn bản tối thiểu (server/Remote Config trả về).
bool needsForceUpdate({required String installed, required String minimumSupported}) =>
    compareVersions(installed, minimumSupported) < 0;
