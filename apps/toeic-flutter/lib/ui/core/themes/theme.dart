import 'package:flutter/material.dart';

/// Theme sáng / tối của app (Material 3, màu từ seed). Chế độ tối = tính năng 8.
abstract final class AppTheme {
  static const Color seed = Color(0xFF0A6E5C); // cùng màu chính với app Task 5
  static const String fontFamily = 'NotoSans';

  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      fontFamily: fontFamily,
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      cardTheme: const CardThemeData(margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
    );
  }
}
