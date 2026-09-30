import 'package:flutter/foundation.dart';

@immutable
class CatalogItem {
  const CatalogItem(this.name, this.price);
  final String name;
  final int price; // nghìn đồng

  @override
  bool operator ==(Object other) => other is CatalogItem && other.name == name && other.price == price;
  @override
  int get hashCode => Object.hash(name, price);
}

const catalog = [
  CatalogItem('Sách TOEIC Listening', 120),
  CatalogItem('Sách TOEIC Reading', 150),
  CatalogItem('Tai nghe', 300),
];

/// App state bằng ChangeNotifier — đúng ví dụ "Cart" trong docs "Simple app state management".
/// Giống một Angular service có state: dữ liệu private, thay đổi qua hàm, báo cho người nghe.
class CartModel extends ChangeNotifier {
  final List<CatalogItem> _items = [];

  List<CatalogItem> get items => List.unmodifiable(_items);
  int get count => _items.length;
  int get totalPrice => _items.fold(0, (sum, i) => sum + i.price);

  void add(CatalogItem item) {
    _items.add(item);
    notifyListeners(); // ≈ signal.set() / subject.next()
  }

  void removeAll() {
    _items.clear();
    notifyListeners();
  }
}

/// ViewModel đơn giản theo Learning Pathway: ChangeNotifier + ListenableBuilder, không cần package.
class CounterViewModel extends ChangeNotifier {
  int _value = 0;
  int get value => _value;

  void increment() {
    _value++;
    notifyListeners();
  }
}
