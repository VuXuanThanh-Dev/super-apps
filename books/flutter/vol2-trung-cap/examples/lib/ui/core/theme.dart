import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color seed = Color(0xFF0F766E); // xanh ngọc

  static ThemeData light = _build(Brightness.light);
  static ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      appBarTheme: AppBarTheme(backgroundColor: scheme.primaryContainer, foregroundColor: scheme.onPrimaryContainer),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }
}
