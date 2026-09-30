import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap1_viec_can_lam/chapters/ch08/exercise_solution.dart';
import 'package:tap1_viec_can_lam/chapters/ch08/navigator_basics.dart';
import 'package:tap1_viec_can_lam/chapters/ch08/word_router.dart';

import '../helpers.dart';

void main() {
  group('Chương 8 — điều hướng', () {
    testWidgets('Navigator.push nhận kết quả khi màn hình kia pop', (tester) async {
      await pumpApp(tester, const ColorPickerHome());
      await tester.tap(find.text('Chọn màu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xanh lá'));
      await tester.pumpAndSettle();
      expect(find.text('Màu: Xanh lá'), findsOneWidget);
    });

    testWidgets('go_router: path + query parameter', (tester) async {
      final loggedIn = ValueNotifier(true);
      final router = buildWordRouter(loggedIn: loggedIn, initialLocation: '/words/2?tab=examples');
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Từ: deadline · tab: examples'), findsOneWidget);
      router.dispose();
    });

    testWidgets('go_router: redirect về /login khi chưa đăng nhập, rồi quay lại', (tester) async {
      final loggedIn = ValueNotifier(false);
      final router = buildWordRouter(loggedIn: loggedIn);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      await tester.tap(find.text('invoice'));
      await tester.pumpAndSettle();
      expect(find.text('Đăng nhập (giả)'), findsOneWidget);
      expect(router.state.uri.queryParameters['from'], '/words/3');
      await tester.tap(find.text('Đăng nhập (giả)'));
      await tester.pumpAndSettle();
      expect(find.text('Từ: invoice · tab: meaning'), findsOneWidget);
      router.dispose();
    });

    test('Bài 1: safeRedirectTarget chặn open redirect', () {
      expect(safeRedirectTarget('/words/3?tab=x'), '/words/3?tab=x');
      expect(safeRedirectTarget(null), '/');
      expect(safeRedirectTarget('https://evil.com'), '/');
      expect(safeRedirectTarget('//evil.com/a'), '/');
      expect(safeRedirectTarget('javascript:alert(1)'), '/');
    });
  });
}
