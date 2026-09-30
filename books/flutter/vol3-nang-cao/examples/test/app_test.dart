import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap3_so_ghi_chu/app.dart';
import 'package:tap3_so_ghi_chu/core/platform/battery_channel.dart';

import 'helpers.dart';

void main() {
  testWidgets('tạo PIN → ghi chú: thêm, sửa, xóa → khóa → mở khóa', (tester) async {
    final t = testDependencies();
    await tester.pumpWidget(SecureNotesApp(dependencies: t.deps));
    await tester.pumpAndSettle();
    expect(find.text('Tạo mã PIN'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Mã PIN mới (4–8 số)'), '1234');
    await tester.enterText(find.widgetWithText(TextField, 'Nhập lại mã PIN'), '1234');
    await tester.tap(find.text('Lưu mã PIN'));
    await tester.pumpAndSettle();
    expect(find.text('PIN quá dễ đoán, hãy chọn PIN khác'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Mã PIN mới (4–8 số)'), '2468');
    await tester.enterText(find.widgetWithText(TextField, 'Nhập lại mã PIN'), '2468');
    await tester.tap(find.text('Lưu mã PIN'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có ghi chú nào'), findsOneWidget);

    await tester.tap(find.text('Ghi chú mới'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Tiêu đề'), 'Mật khẩu wifi');
    await tester.enterText(find.widgetWithText(TextField, 'Nội dung'), 'nha-rieng-2026');
    await tester.tap(find.byTooltip('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Mật khẩu wifi'), findsOneWidget);
    expect(t.store.data['notes_v1'], contains('Mật khẩu wifi'));

    await tester.tap(find.text('Mật khẩu wifi'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Tiêu đề'), 'Wifi nhà');
    await tester.tap(find.byTooltip('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Wifi nhà'), findsOneWidget);

    await tester.tap(find.byTooltip('Khóa ngay'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập mã PIN'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Mã PIN'), '1357');
    await tester.tap(find.text('Mở khóa'));
    await tester.pumpAndSettle();
    expect(find.text('Sai mã PIN (1 lần)'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Mã PIN'), '2468');
    await tester.tap(find.text('Mở khóa'));
    await tester.pumpAndSettle();
    expect(find.text('Wifi nhà'), findsOneWidget);

    await tester.drag(find.text('Wifi nhà'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có ghi chú nào'), findsOneWidget);
  });

  testWidgets('guard: chưa mở khóa thì mọi URL đều về màn hình khóa', (tester) async {
    final t = testDependencies();
    await t.deps.pins.setPin('2468');
    await tester.pumpWidget(SecureNotesApp(dependencies: t.deps));
    await tester.pumpAndSettle();
    expect(find.text('Nhập mã PIN'), findsOneWidget);
    expect(find.text('Ghi chú'), findsNothing);
  });

  testWidgets('cài đặt: pin "không hỗ trợ" khi không có native; nhật ký ghi lại sự kiện', (tester) async {
    final t = testDependencies();
    await tester.pumpWidget(SecureNotesApp(dependencies: t.deps));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Mã PIN mới (4–8 số)'), '2468');
    await tester.enterText(find.widgetWithText(TextField, 'Nhập lại mã PIN'), '2468');
    await tester.tap(find.text('Lưu mã PIN'));
    await tester.pumpAndSettle();
    // Trong widget test, gọi kênh CHƯA được mock có thể treo mãi (sách gặp thật) → luôn mock kênh.
    // Ở đây giả lập "không có code native" giống trên web.
    const channel = MethodChannel(BatteryChannel.channelName);
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async => throw MissingPluginException());
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await tester.tap(find.byTooltip('Cài đặt'));
    await tester.pumpAndSettle();
    expect(find.text('Không hỗ trợ trên nền tảng này'), findsOneWidget);
    expect(find.text('[info] Đã tạo PIN'), findsOneWidget);
    expect(t.logger.records.any((r) => r.message.contains('2468')), isFalse);
  });

  testWidgets('Lab mở được mọi chương', (tester) async {
    final t = testDependencies();
    await tester.pumpWidget(SecureNotesApp(dependencies: t.deps));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Mã PIN mới (4–8 số)'), '2468');
    await tester.enterText(find.widgetWithText(TextField, 'Nhập lại mã PIN'), '2468');
    await tester.tap(find.text('Lưu mã PIN'));
    await tester.pumpAndSettle();
    for (final title in [
      'Ch.2 — Performance: const và child',
      'Ch.3 — Platform channel (pin)',
      'Ch.4 — Kiểm tra deep link',
    ]) {
      await tester.tap(find.byTooltip('Lab'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(title));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: title);
      expect(find.text(title), findsWidgets);
      await tester.tap(find.byType(BackButton));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byType(BackButton));
      await tester.pump(const Duration(milliseconds: 300));
    }
  });
}
