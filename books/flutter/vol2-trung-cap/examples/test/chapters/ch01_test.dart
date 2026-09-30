import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tap2_so_tu_vung/chapters/ch01/cart_model.dart';
import 'package:tap2_so_tu_vung/chapters/ch01/exercise_solution.dart';
import 'package:tap2_so_tu_vung/chapters/ch01/provider_demo.dart';

import '../helpers.dart';

void main() {
  group('Chương 1 — quản lý state', () {
    test('CartModel báo listener khi thêm / xóa', () {
      final cart = CartModel();
      var notified = 0;
      cart.addListener(() => notified++);
      cart.add(catalog[0]);
      cart.add(catalog[1]);
      expect((cart.count, cart.totalPrice), (2, 270));
      cart.removeAll();
      expect((cart.count, notified), (0, 3));
    });

    testWidgets('CounterView (ChangeNotifier + ListenableBuilder)', (tester) async {
      final vm = CounterViewModel();
      addTearDown(vm.dispose);
      await pumpApp(tester, CounterView(viewModel: vm));
      await tester.tap(find.byTooltip('Tăng'));
      await tester.pump();
      expect(find.text('Đếm: 1'), findsOneWidget);
    });

    testWidgets('ProviderCartDemo: read để gọi hàm, Consumer để hiển thị', (tester) async {
      await pumpApp(tester, const SingleChildScrollView(child: ProviderCartDemo()));
      await tester.tap(find.text('Thêm').first);
      await tester.tap(find.text('Thêm').last);
      await tester.pump();
      expect(find.text('Giỏ: 2 món — 420k'), findsOneWidget);
      await tester.tap(find.text('Xóa hết'));
      await tester.pump();
      expect(find.text('Giỏ: 0 món — 0k'), findsOneWidget);
    });

    testWidgets('Bài 1: context.select chỉ build lại khi số lượng đổi', (tester) async {
      final cart = CartModel();
      addTearDown(cart.dispose);
      CartCountBadge.buildCount = 0;
      await pumpApp(tester, ChangeNotifierProvider.value(value: cart, child: const CartCountBadge()));
      expect(CartCountBadge.buildCount, 1);
      cart.add(catalog[0]);
      await tester.pump();
      expect((CartCountBadge.buildCount, find.text('1').evaluate().length), (2, 1));
      cart.removeAll();
      await tester.pump();
      cart.removeAll(); // gọi notifyListeners nhưng count vẫn 0 → KHÔNG build lại
      await tester.pump();
      expect(CartCountBadge.buildCount, 3);
    });

    test('Bài 2: CartNotifier tạo list mới mỗi lần đổi', () {
      final cart = CartNotifier();
      final before = cart.value;
      var notified = 0;
      cart.addListener(() => notified++);
      cart.add(catalog[2]);
      expect(identical(before, cart.value), isFalse);
      expect((cart.value.length, cart.totalPrice, notified), (1, 300, 1));
      expect(() => cart.value.add(catalog[0]), throwsUnsupportedError);
    });
  });
}
