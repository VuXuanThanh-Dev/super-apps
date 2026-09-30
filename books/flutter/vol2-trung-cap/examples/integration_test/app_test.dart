import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tap2_so_tu_vung/main.dart' as app;

/// Integration test: chạy app THẬT (SQLite thật, plugin thật) trên thiết bị / máy ảo / Chrome.
///   flutter test integration_test/app_test.dart            (chọn iPhone/Android đang cắm)
/// Trong sandbox của sách: NOT RUN (không có thiết bị). Xem Tập 2, Chương 7.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mở app, tìm "dam phan", mở chi tiết negotiate', (tester) async {
    await app.main();
    await tester.pumpAndSettle();
    expect(find.text('Sổ Từ Vựng'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'dam phan');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('negotiate'));
    await tester.pumpAndSettle();
    expect(find.text('(v) đàm phán'), findsOneWidget);
  });
}
