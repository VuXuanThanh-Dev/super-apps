import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_model.dart';

/// Bộ đếm theo Learning Pathway: ViewModel truyền vào, View dùng ListenableBuilder.
class CounterView extends StatelessWidget {
  const CounterView({super.key, required this.viewModel});

  final CounterViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Đếm: ${viewModel.value}'),
          IconButton(tooltip: 'Tăng', onPressed: viewModel.increment, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }
}

/// Giỏ hàng với provider: ChangeNotifierProvider ở trên, con dùng read / watch / select / Consumer.
class ProviderCartDemo extends StatelessWidget {
  const ProviderCartDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartModel(), // provider tự dispose CartModel khi widget bị gỡ
      child: const Column(mainAxisSize: MainAxisSize.min, children: [CatalogList(), Divider(), CartSummary()]),
    );
  }
}

class CatalogList extends StatelessWidget {
  const CatalogList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in catalog)
          ListTile(
            title: Text(item.name),
            subtitle: Text('${item.price}k'),
            trailing: TextButton(
              // read: chỉ LẤY để gọi hàm, không lắng nghe → widget này không build lại khi giỏ đổi.
              onPressed: () => context.read<CartModel>().add(item),
              child: const Text('Thêm'),
            ),
          ),
      ],
    );
  }
}

class CartSummary extends StatelessWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer: chỉ phần builder build lại (giống watch nhưng phạm vi nhỏ hơn).
    return Consumer<CartModel>(
      builder: (context, cart, child) => ListTile(
        title: Text('Giỏ: ${cart.count} món — ${cart.totalPrice}k'),
        trailing: TextButton(onPressed: cart.count == 0 ? null : cart.removeAll, child: const Text('Xóa hết')),
      ),
    );
  }
}
