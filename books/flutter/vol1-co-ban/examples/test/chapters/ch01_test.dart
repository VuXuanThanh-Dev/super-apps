import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap1_viec_can_lam/chapters/ch01/exercise_solution.dart';
import 'package:tap1_viec_can_lam/chapters/ch01/hello_counter.dart';

import '../helpers.dart';

void main() {
  group('Chương 1 — app đầu tiên', () {
    testWidgets('HelloCounter tăng theo step khi bấm', (tester) async {
      await pumpApp(tester, const HelloCounter(step: 2));
      expect(find.text('Bạn đã bấm 0 lần'), findsOneWidget);
      await tester.tap(find.text('Bấm tôi'));
      await tester.pump(); // build lại sau setState
      expect(find.text('Bạn đã bấm 2 lần'), findsOneWidget);
    });

    testWidgets('Bài tập: nút Đặt lại bị vô hiệu khi = 0 và đưa về 0', (tester) async {
      await pumpApp(tester, const CounterWithReset());
      final reset = find.widgetWithText(OutlinedButton, 'Đặt lại');
      expect(tester.widget<OutlinedButton>(reset).onPressed, isNull);
      await tester.tap(find.text('+1'));
      await tester.tap(find.text('+1'));
      await tester.pump();
      expect(find.text('Đếm: 2'), findsOneWidget);
      await tester.tap(reset);
      await tester.pump();
      expect(find.text('Đếm: 0'), findsOneWidget);
    });
  });
}
