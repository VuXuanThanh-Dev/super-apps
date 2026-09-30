/// Chương 5 — CI tăng build number tự động: "1.2.3+4" → "1.2.3+5".
/// (Flutter: phần trước "+" là version name (CFBundleShortVersionString / versionName),
/// phần sau "+" là build number (CFBundleVersion / versionCode).)
String bumpBuildNumber(String version) {
  final m = RegExp(r'^(\d+\.\d+\.\d+)\+(\d+)$').firstMatch(version.trim());
  if (m == null) throw FormatException('Version không đúng dạng x.y.z+n: $version');
  return '${m.group(1)}+${int.parse(m.group(2)!) + 1}';
}

/// Bài tập Chương 5: tăng version theo SemVer (major/minor/patch), reset build number về 1.
String bumpVersion(String version, {required String part}) {
  final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)(\+\d+)?$').firstMatch(version.trim());
  if (m == null) throw FormatException('Version không đúng dạng: $version');
  var (major, minor, patch) = (int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
  switch (part) {
    case 'major':
      (major, minor, patch) = (major + 1, 0, 0);
    case 'minor':
      (minor, patch) = (minor + 1, 0);
    case 'patch':
      patch++;
    default:
      throw ArgumentError('part phải là major/minor/patch');
  }
  return '$major.$minor.$patch+1';
}
