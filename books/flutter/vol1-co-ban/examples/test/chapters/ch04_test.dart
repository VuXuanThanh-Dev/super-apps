import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap1_viec_can_lam/chapters/ch04/clock.dart';
import 'package:tap1_viec_can_lam/chapters/ch04/exercise_solution.dart';
import 'package:tap1_viec_can_lam/chapters/ch04/profile_card.dart';

import '../helpers.dart';

void main() {
  group('Chương 4 — widget', () {
    testWidgets('ProfileCard đổi nhãn khi bấm Theo dõi (state ở cha)', (tester) async {
      await pumpApp(tester, const ProfileDemo());
      await tester.tap(find.text('Theo dõi'));
      await tester.pump();
      expect(find.text('Đang theo dõi'), findsOneWidget);
    });

    test('formatTime thêm số 0 phía trước', () {
      expect(formatTime(DateTime(2026, 1, 1, 8, 5, 3)), '08:05:03');
    });

    testWidgets('Clock cập nhật mỗi giây, dừng khi paused, hủy Timer khi dispose', (tester) async {
      var now = DateTime(2026, 1, 1, 8);
      DateTime clock() => now;
      await pumpApp(tester, Clock(now: clock));
      expect(find.text('08:00:00'), findsOneWidget);
      now = now.add(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('08:00:02'), findsOneWidget);

      // Bài 2: paused = true → didUpdateWidget dừng Timer
      await pumpApp(tester, Clock(now: clock, paused: true));
      now = now.add(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('08:00:02'), findsOneWidget);

      await pumpApp(tester, Clock(now: clock));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('08:00:07'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      // Nếu Timer còn chạy sau dispose, flutter_test sẽ báo lỗi "A Timer is still pending".
    });

    testWidgets('Bài 1: LikeButton bật/tắt và đổi số', (tester) async {
      await pumpApp(tester, const LikeButton(initialLikes: 12));
      expect(find.text('12'), findsOneWidget);
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(find.text('13'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(find.text('12'), findsOneWidget);
    });
  });
}
