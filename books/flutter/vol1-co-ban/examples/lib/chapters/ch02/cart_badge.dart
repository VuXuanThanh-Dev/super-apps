import 'package:flutter/material.dart';

/// Angular Signals ↔ ValueNotifier:
///   `signal(0)`        → `ValueNotifier<int>(0)`
///   count.set(v)       → count.value = v
///   template {{count()}} → ValueListenableBuilder
class CartBadgeDemo extends StatefulWidget {
  const CartBadgeDemo({super.key});

  @override
  State<CartBadgeDemo> createState() => _CartBadgeDemoState();
}

class _CartBadgeDemoState extends State<CartBadgeDemo> {
  final ValueNotifier<int> _cartCount = ValueNotifier(0);

  @override
  void dispose() {
    _cartCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chỉ phần này build lại khi _cartCount đổi — giống một signal được đọc trong template.
        ValueListenableBuilder<int>(
          valueListenable: _cartCount,
          builder: (context, count, _) => Badge(
            label: Text('$count'),
            isLabelVisible: count > 0,
            child: const Icon(Icons.shopping_cart_outlined, size: 32),
          ),
        ),
        const SizedBox(width: 16),
        FilledButton(onPressed: () => _cartCount.value++, child: const Text('Thêm vào giỏ')),
      ],
    );
  }
}
