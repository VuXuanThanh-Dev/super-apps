import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap2_so_tu_vung/chapters/ch05/animation_demo.dart';
import 'package:tap2_so_tu_vung/chapters/ch05/exercise_solution.dart';
import 'package:tap2_so_tu_vung/ui/core/flip_card.dart';

import '../helpers.dart';

void main() {
  group('Chương 5 — animation', () {
    testWidgets('AnimatedProgress chạy từ giá trị cũ tới mới trong 500ms', (tester) async {
      await pumpApp(tester, const AnimatedProgress(value: 0.2));
      await tester.pumpAndSettle();
      expect(find.text('20%'), findsOneWidget);
      await pumpApp(tester, const AnimatedProgress(value: 1));
      await tester.pump(const Duration(milliseconds: 100));
      final mid = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value!;
      expect(mid, inExclusiveRange(0.2, 1.0)); // đang ở giữa đường
      await tester.pumpAndSettle();
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('FlipCard: nửa đường thì đổi mặt', (tester) async {
      Widget card(bool flipped) => SizedBox(
        height: 100,
        child: FlipCard(flipped: flipped, front: const Text('mặt trước'), back: const Text('mặt sau')),
      );
      await pumpApp(tester, card(false));
      expect(find.text('mặt trước'), findsOneWidget);
      await pumpApp(tester, card(true));
      await tester.pump(const Duration(milliseconds: 100)); // chưa qua 90°
      expect(find.text('mặt trước'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('mặt sau'), findsOneWidget);
    });

    testWidgets('Bài 1: PulsingDot lặp khi active, dừng khi tắt', (tester) async {
      await pumpApp(tester, const PulsingDot());
      expect(tester.hasRunningAnimations, isTrue);
      await pumpApp(tester, const PulsingDot(active: false));
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpAndSettle(); // đã dừng → settle được
    });

    testWidgets('Bài 2: AnimatedScore có cả chữ cũ và mới trong lúc chuyển', (tester) async {
      await pumpApp(tester, const AnimatedScore(score: 10));
      await pumpApp(tester, const AnimatedScore(score: 20));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('10 điểm'), findsOneWidget);
      expect(find.text('20 điểm'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('10 điểm'), findsNothing);
    });
  });
}
