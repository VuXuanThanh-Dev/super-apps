import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap1_viec_can_lam/chapters/ch05/exercise_solution.dart';
import 'package:tap1_viec_can_lam/chapters/ch05/layout_demo.dart';
import 'package:tap1_viec_can_lam/features/tasks/task.dart';
import 'package:tap1_viec_can_lam/theme.dart';

import '../helpers.dart';

void main() {
  group('Chương 5 — layout, theme, adaptive', () {
    test('columnsForWidth theo breakpoint', () {
      expect(columnsForWidth(390), 1); // iPhone dọc
      expect(columnsForWidth(700), 2);
      expect(columnsForWidth(1024), 3);
    });

    testWidgets('AdaptiveGrid đổi số cột theo bề rộng', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpApp(tester, const LayoutDemo());
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 3);
    });

    test('AppTheme: dark theme có Brightness.dark, cùng seed', () {
      expect(AppTheme.light.colorScheme.brightness, Brightness.light);
      expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
      expect(AppTheme.light.useMaterial3, isTrue);
    });

    test('Bài 1: colorForPriority lấy màu từ ColorScheme', () {
      final scheme = AppTheme.dark.colorScheme;
      expect(colorForPriority(scheme, Priority.high), scheme.error);
      expect(colorForPriority(scheme, Priority.low), scheme.outline);
    });

    testWidgets('Bài 2: chữ dài trong Row không gây overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpApp(tester, LongTitleRow(title: 'Rất dài ' * 30));
      expect(tester.takeException(), isNull);
    });
  });
}
