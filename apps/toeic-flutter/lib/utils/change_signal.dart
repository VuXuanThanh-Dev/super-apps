import 'package:flutter/foundation.dart';

/// Một [Listenable] đơn giản: gọi [emit] để báo "dữ liệu đã đổi".
class ChangeSignal extends ChangeNotifier {
  void emit() => notifyListeners();
}
