import 'package:flutter_test/flutter_test.dart';
import 'package:tap1_viec_can_lam/chapters/ch06/exercise_solution.dart';
import 'package:tap1_viec_can_lam/chapters/ch06/lists_demo.dart';

import '../helpers.dart';

void main() {
  group('Chương 6 — danh sách', () {
    testWidgets('ContactList chỉ build dòng đang hiện (lazy) và cuộn tới dòng 200', (tester) async {
      await pumpApp(tester, const ContactList());
      expect(find.text('Liên hệ 1'), findsOneWidget);
      expect(find.text('Liên hệ 200'), findsNothing); // chưa được tạo
      await tester.scrollUntilVisible(find.text('Liên hệ 200'), 500);
      expect(find.text('Liên hệ 200'), findsOneWidget);
    });

    testWidgets('SwipeList: vuốt để xóa', (tester) async {
      await pumpApp(tester, const SwipeList(initial: ['agenda', 'budget', 'invoice']));
      await tester.drag(find.text('budget'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text('budget'), findsNothing);
      expect(find.text('invoice'), findsOneWidget);
    });

    testWidgets('SectionedWordList hiển thị tiêu đề nhóm', (tester) async {
      await pumpApp(tester, SectionedWordList(groups: groupByInitial(['budget', 'agenda'])));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    test('Bài 1: groupByInitial sắp xếp nhóm và từ', () {
      expect(groupByInitial(['delay', 'Budget', 'approve', 'agenda', ' ', 'deadline']), {
        'A': ['agenda', 'approve'],
        'B': ['Budget'],
        'D': ['deadline', 'delay'],
      });
    });

    testWidgets('Bài 2: ColorGrid có 20 ô', (tester) async {
      await pumpApp(tester, const ColorGrid());
      expect(find.text('Ô 1'), findsOneWidget);
    });
  });
}
