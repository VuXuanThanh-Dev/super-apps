import 'package:flutter_test/flutter_test.dart';
import 'package:tap2_so_tu_vung/chapters/ch02/async_demo.dart';
import 'package:tap2_so_tu_vung/chapters/ch02/exercise_solution.dart';

import '../helpers.dart';

void main() {
  group('Chương 2 — Future, Stream, isolate', () {
    test('Future: await và Future.wait', () async {
      expect(await fetchGreeting('Nobin', delay: Duration.zero), 'Xin chào Nobin');
      expect(await greetAll(['A', 'B']), ['Xin chào A', 'Xin chào B']);
      await expectLater(fetchGreeting(''), throwsArgumentError);
    });

    test('Stream async*: countdown phát 3, 2, 1, 0 rồi đóng', () {
      expect(countdown(3, interval: Duration.zero), emitsInOrder([3, 2, 1, 0, emitsDone]));
    });

    testWidgets('StreamBuilder hiển thị từng giá trị', (tester) async {
      await pumpApp(tester, const CountdownView(from: 2));
      await tester.pump(); // nhận giá trị đầu
      expect(find.text('Còn 2 giây'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Còn 1 giây'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(find.text('Hết giờ!'), findsOneWidget);
    });

    test('compute: chạy hàm nặng ở isolate khác', () async {
      final text = List.generate(1000, (i) => i.isEven ? 'negotiation' : 'tax').join(' ');
      expect(await countLongWordsInBackground(text), 500);
    });

    test('Bài 1: retry thử lại rồi thành công / hết lượt thì ném lỗi', () async {
      var calls = 0;
      final value = await retry(() async {
        if (++calls < 3) throw Exception('lỗi mạng');
        return 'ok';
      }, initialDelay: Duration.zero);
      expect((value, calls), ('ok', 3));
      await expectLater(
        retry<String>(() async => throw Exception('luôn lỗi'), attempts: 2, initialDelay: Duration.zero),
        throwsException,
      );
    });

    test('Bài 2: Completer biến callback thành Future', () async {
      expect(await loadAsFuture('k'), 'giá trị của k');
      await expectLater(loadAsFuture(''), throwsStateError);
    });
  });
}
