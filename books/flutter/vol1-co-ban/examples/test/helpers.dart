import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tap1_viec_can_lam/theme.dart';

/// Bọc widget trong MaterialApp + Scaffold để test (giống TestBed với module tối thiểu).
Future<void> pumpApp(WidgetTester tester, Widget child, {ThemeData? theme}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Scaffold(body: child),
    ),
  );
}
