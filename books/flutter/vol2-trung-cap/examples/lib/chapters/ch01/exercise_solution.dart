import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_model.dart';

/// Bài 1: badge chỉ build lại khi SỐ LƯỢNG đổi — dùng context.select.
class CartCountBadge extends StatelessWidget {
  const CartCountBadge({super.key});

  static int buildCount = 0; // chỉ để test đếm số lần build

  @override
  Widget build(BuildContext context) {
    buildCount++;
    final count = context.select<CartModel, int>((cart) => cart.count);
    return Badge(label: Text('$count'), child: const Icon(Icons.shopping_cart));
  }
}

/// Bài 2: cùng giỏ hàng nhưng dùng ValueNotifier với danh sách BẤT BIẾN.
/// ValueNotifier chỉ báo khi `value` là đối tượng MỚI (so sánh ==), nên phải tạo list mới.
class CartNotifier extends ValueNotifier<List<CatalogItem>> {
  CartNotifier() : super(const []);

  // List.unmodifiable: không ai sửa được list cũ → buộc phải tạo list mới (bất biến thật sự).
  void add(CatalogItem item) => value = List.unmodifiable([...value, item]);
  void removeAll() => value = const [];
  int get totalPrice => value.fold(0, (sum, i) => sum + i.price);
}
