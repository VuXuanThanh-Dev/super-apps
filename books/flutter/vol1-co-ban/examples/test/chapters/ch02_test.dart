import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap1_viec_can_lam/chapters/ch02/cart_badge.dart';
import 'package:tap1_viec_can_lam/chapters/ch02/debounce.dart';
import 'package:tap1_viec_can_lam/chapters/ch02/exercise_solution.dart';
import 'package:tap1_viec_can_lam/chapters/ch02/greeting_service.dart';
import 'package:tap1_viec_can_lam/chapters/ch02/rating_stars.dart';

import '../helpers.dart';

void main() {
  group('Angular/React Native → Flutter', () {
    testWidgets('RatingStars: dữ liệu đi xuống, callback đi lên (như @Input/@Output)', (tester) async {
      int? received;
      await pumpApp(tester, RatingStars(value: 2, onChanged: (v) => received = v));
      await tester.tap(find.byTooltip('4 sao'));
      expect(received, 4);
      expect(find.byIcon(Icons.star), findsNWidgets(2));
    });

    testWidgets('ValueNotifier như signal: badge cập nhật khi bấm', (tester) async {
      await pumpApp(tester, const CartBadgeDemo());
      await tester.tap(find.text('Thêm vào giỏ'));
      await tester.tap(find.text('Thêm vào giỏ'));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('InheritedWidget thay implementation như providers: [...]', (tester) async {
      await pumpApp(
        tester,
        const Column(
          children: [
            GreetingText(name: 'Nobin'),
            GreetingScope(
              service: FormalGreeting(),
              child: GreetingText(name: 'Lan'),
            ),
          ],
        ),
      );
      expect(find.text('Chào Nobin!'), findsOneWidget);
      expect(find.text('Kính chào anh/chị Lan.'), findsOneWidget);
    });

    testWidgets('SearchBox debounce 300ms (debounceTime)', (tester) async {
      final calls = <String>[];
      await pumpApp(tester, SearchBox(onSearch: calls.add));
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'abc');
      expect(calls, isEmpty);
      await tester.pump(const Duration(milliseconds: 300));
      expect(calls, ['abc']);
    });

    test('searchTerms: map / where / distinct giống pipe(map, filter, distinctUntilChanged)', () {
      final out = searchTerms(Stream.fromIterable([' a', 'ab ', 'ab', 'abc', 'x']));
      expect(out, emitsInOrder(['ab', 'abc', emitsDone]));
    });

    test('Bài 1: Computed tính lại khi nguồn đổi, chỉ báo khi kết quả đổi', () {
      final price = ValueNotifier(100);
      final qty = ValueNotifier(2);
      final total = Computed([price, qty], () => price.value * qty.value);
      var notified = 0;
      total.addListener(() => notified++);
      expect(total.value, 200);
      qty.value = 3;
      expect(total.value, 300);
      expect(notified, 1);
      price.value = 100; // không đổi → ValueNotifier không báo
      expect(notified, 1);
      total.dispose();
    });
  });
}
