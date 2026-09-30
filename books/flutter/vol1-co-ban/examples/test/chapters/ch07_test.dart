import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap1_viec_can_lam/chapters/ch07/exercise_solution.dart';
import 'package:tap1_viec_can_lam/chapters/ch07/sign_up_form.dart';
import 'package:tap1_viec_can_lam/chapters/ch07/validators.dart';

import '../helpers.dart';

void main() {
  group('Chương 7 — form', () {
    test('validators thuần: requiredField, email, minLength, compose', () {
      final v = compose([requiredField(), email()]);
      expect(v(''), 'Bắt buộc nhập');
      expect(v('abc'), 'Email không hợp lệ');
      expect(v('nobin@example.com'), isNull);
      expect(minLength(8)('1234'), 'Tối thiểu 8 ký tự');
    });

    testWidgets('SignUpForm hiện lỗi, rồi gửi dữ liệu khi hợp lệ', (tester) async {
      SignUpData? sent;
      await pumpApp(tester, SignUpForm(onSubmit: (d) => sent = d));
      await tester.tap(find.text('Đăng ký'));
      await tester.pump();
      expect(find.text('Bắt buộc nhập'), findsNWidgets(3));
      expect(sent, isNull);

      await tester.enterText(find.widgetWithText(TextFormField, 'Họ tên'), 'Nobin');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'nobin@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu'), 'matkhau123');
      await tester.tap(find.text('Đăng ký'));
      await tester.pump();
      expect(sent?.name, 'Nobin');
      expect(sent?.email, 'nobin@example.com');
    });

    testWidgets('nút mắt bật/tắt ẩn mật khẩu', (tester) async {
      await pumpApp(tester, SignUpForm(onSubmit: (_) {}));
      await tester.tap(find.byTooltip('Hiện mật khẩu'));
      await tester.pump();
      expect(find.byTooltip('Ẩn mật khẩu'), findsOneWidget);
    });

    test('Bài 1: matchesField so sánh với giá trị hiện tại của ô khác', () {
      var password = 'abc12345';
      final v = matchesField(() => password);
      expect(v('abc12345'), isNull);
      password = 'khac';
      expect(v('abc12345'), 'Mật khẩu không khớp');
    });

    testWidgets('Bài 2: ChangePasswordForm chỉ gọi onDone khi hai ô khớp', (tester) async {
      var done = false;
      await pumpApp(tester, ChangePasswordForm(onDone: () => done = true));
      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu mới'), 'matkhau123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Nhập lại mật khẩu'), 'matkhau999');
      await tester.tap(find.text('Đổi mật khẩu'));
      await tester.pump();
      expect(find.text('Mật khẩu không khớp'), findsOneWidget);
      expect(done, isFalse);
      await tester.enterText(find.widgetWithText(TextFormField, 'Nhập lại mật khẩu'), 'matkhau123');
      await tester.tap(find.text('Đổi mật khẩu'));
      await tester.pump();
      expect(done, isTrue);
    });
  });
}
