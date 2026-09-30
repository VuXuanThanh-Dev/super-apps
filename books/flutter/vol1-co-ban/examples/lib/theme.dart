import 'package:flutter/material.dart';

/// Theme Material 3 sáng/tối sinh từ một màu gốc (seed color).
abstract final class AppTheme {
  static const Color seed = Color(0xFF1D4ED8);

  static ThemeData light = _build(Brightness.light);
  static ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      appBarTheme: AppBarTheme(backgroundColor: scheme.primaryContainer, foregroundColor: scheme.onPrimaryContainer),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
    );
  }
}
