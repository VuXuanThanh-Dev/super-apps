/// Chương 1 — kiểm tra "luật phụ thuộc" của kiến trúc feature-first bằng code.
///
/// Luật:
/// 1. `data/` và `domain/` của một feature KHÔNG import Flutter UI (`package:flutter/material.dart`,
///    `package:flutter/widgets.dart`) và KHÔNG import thư mục `ui/`.
/// 2. Một feature KHÔNG import `data/` của feature khác (muốn dùng thì đi qua interface ở `core/` hoặc qua UI).
///
/// [sources]: đường dẫn (tính từ lib/) → nội dung file. Trả về danh sách vi phạm (rỗng = ổn).
List<String> checkDependencyRules(Map<String, String> sources) {
  final violations = <String>[];
  final importRe = RegExp(r'''^import\s+['"]([^'"]+)['"]''', multiLine: true);
  for (final MapEntry(key: path, value: code) in sources.entries) {
    final parts = path.split('/');
    if (parts.length < 3 || parts[0] != 'features') continue;
    final feature = parts[1];
    final layer = parts[2];
    for (final m in importRe.allMatches(code)) {
      final target = m.group(1)!;
      final isUiImport =
          target == 'package:flutter/material.dart' ||
          target == 'package:flutter/widgets.dart' ||
          target.contains('/ui/') ||
          target.startsWith('../ui/');
      if ((layer == 'data' || layer == 'domain') && isUiImport) {
        violations.add('$path: tầng $layer không được import UI ($target)');
      }
      final other =
          RegExp(r'features/(\w+)/data/').firstMatch(target) ?? RegExp(r'\.\./\.\./(\w+)/data/').firstMatch(target);
      if (other != null && other.group(1) != feature) {
        violations.add('$path: feature "$feature" import data của feature "${other.group(1)}" ($target)');
      }
    }
  }
  return violations;
}
