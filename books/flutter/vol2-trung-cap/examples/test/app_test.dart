import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tap2_so_tu_vung/app.dart';

import 'data/services_test.dart' show sampleJson;
import 'fakes/fakes.dart';
import 'helpers.dart';

/// Widget test toàn app: router + provider + ViewModel thật, dữ liệu/dịch vụ GIẢ.
void main() {
  Future<void> pumpVocab(
    WidgetTester tester, {
    String location = '/words',
    FakeTts? tts,
    FakeWordRepository? words,
    bool settle = true,
  }) async {
    await tester.pumpWidget(
      VocabApp(
        key: UniqueKey(),
        initialLocation: location,
        dependencies: fakeDependencies(
          tts: tts,
          words: words,
          httpClient: MockClient((_) async => http.Response(sampleJson, 200)),
        ),
      ),
    );
    // Màn hình có animation lặp vô hạn (PulsingDot) thì pumpAndSettle không bao giờ "yên" → dùng pump.
    settle ? await tester.pumpAndSettle() : await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('danh sách → tìm không dấu (debounce) → phát âm', (tester) async {
    final tts = FakeTts();
    await pumpVocab(tester, tts: tts);
    expect(find.text('Sổ Từ Vựng'), findsOneWidget);
    expect(find.text('3 từ'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'hoa don');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('1 từ'), findsOneWidget);
    await tester.tap(find.byTooltip('Phát âm invoice'));
    expect(tts.spoken, ['invoice']);
  });

  testWidgets('chi tiết: yêu thích, phát âm, tra từ điển online (MockClient)', (tester) async {
    final tts = FakeTts();
    await pumpVocab(tester, tts: tts);
    await tester.tap(find.text('negotiate'));
    await tester.pumpAndSettle();
    expect(find.text('(v) đàm phán'), findsOneWidget);
    await tester.tap(find.text('Yêu thích'));
    await tester.pumpAndSettle();
    expect(find.text('Bỏ yêu thích'), findsOneWidget);
    await tester.tap(find.text('Phát âm'));
    expect(tts.spoken, ['negotiate']);
    await tester.tap(find.text('Tra từ điển online'));
    await tester.pumpAndSettle();
    expect(find.text('verb: try to reach an agreement by discussion'), findsOneWidget);
  });

  testWidgets('deep link /words/2 và id không tồn tại', (tester) async {
    await pumpVocab(tester, location: '/words/2');
    expect(find.text('(v) đàm phán'), findsOneWidget);
    await pumpVocab(tester, location: '/words/999');
    expect(find.text('Không tìm thấy từ này'), findsOneWidget);
  });

  testWidgets('ôn tập: lật thẻ, "Đã nhớ" / "Chưa nhớ", hết lượt', (tester) async {
    final words = FakeWordRepository();
    await pumpVocab(tester, location: '/review', words: words);
    expect(find.text('Thẻ 1/3'), findsOneWidget);
    await tester.tap(find.text('Chạm để xem nghĩa'));
    await tester.pumpAndSettle(); // chờ animation lật xong
    expect(find.text('(n) ngân sách'), findsOneWidget);
    await tester.tap(find.text('Đã nhớ'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Chạm để xem nghĩa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chưa nhớ'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Bạn nhớ 1/3 từ'), findsOneWidget);
    expect(words.reviews, hasLength(3));
  });

  testWidgets('cài đặt: dark mode áp dụng cho cả app', (tester) async {
    await pumpVocab(tester, location: '/settings');
    await tester.tap(find.text('Tối'));
    await tester.pumpAndSettle();
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
  });

  testWidgets('Lab mở được mọi chương', (tester) async {
    for (final id in ['ch01', 'ch02', 'ch03', 'ch04', 'ch05', 'ch06']) {
      await pumpVocab(tester, location: '/lab/$id', settle: false);
      expect(tester.takeException(), isNull, reason: id);
      expect(find.textContaining('Ch.${id.substring(3)}'), findsWidgets, reason: id);
      await tester.pumpWidget(const SizedBox()); // gỡ app → dừng Stream/animation còn chạy
      await tester.pump(const Duration(seconds: 11));
    }
  });
}
