import 'package:flutter/foundation.dart';

import '../../../core/logging/app_logger.dart';
import '../data/pin_repository.dart';
import '../domain/pin_hasher.dart';

enum AuthStatus { loading, needsSetup, locked, unlocked }

/// Trạng thái khóa của cả app. Router đọc [status] để chuyển hướng (redirect) về màn hình khóa.
class AuthController extends ChangeNotifier {
  AuthController({
    required this._pins,
    required this._logger,
    this.autoLockAfter = const Duration(seconds: 30),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final PinRepository _pins;
  final AppLogger _logger;
  final DateTime Function() _clock;
  Duration autoLockAfter;

  AuthStatus _status = AuthStatus.loading;
  String? _message;
  bool _busy = false;
  DateTime? _backgroundedAt;

  AuthStatus get status => _status;
  String? get message => _message;
  bool get busy => _busy;

  Future<void> init() async {
    _status = await _pins.hasPin() ? AuthStatus.locked : AuthStatus.needsSetup;
    notifyListeners();
  }

  Future<void> createPin(String pin, String confirm) async {
    if (!isValidPinFormat(pin)) return _setMessage('PIN phải gồm 4–8 chữ số');
    if (isWeakPin(pin)) return _setMessage('PIN quá dễ đoán, hãy chọn PIN khác');
    if (pin != confirm) return _setMessage('Hai lần nhập không khớp');
    await _pins.setPin(pin);
    _logger.info('Đã tạo PIN'); // KHÔNG log giá trị PIN
    _status = AuthStatus.unlocked;
    _message = null;
    notifyListeners();
  }

  Future<void> unlock(String pin) async {
    if (_busy) return;
    _busy = true;
    notifyListeners();
    try {
      switch (await _pins.verify(pin)) {
        case PinOk():
          _status = AuthStatus.unlocked;
          _message = null;
        case PinWrong(:final failedAttempts):
          _message = 'Sai mã PIN ($failedAttempts lần)';
          _logger.warning('Nhập sai PIN');
        case PinLocked(:final remaining):
          _message = 'Tạm khóa, thử lại sau ${remaining.inSeconds} giây';
          _logger.warning('Khóa tạm vì nhập sai nhiều lần');
      }
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void setAutoLockAfter(Duration value) {
    autoLockAfter = value;
    notifyListeners();
  }

  void lock() {
    if (_status != AuthStatus.unlocked) return;
    _status = AuthStatus.locked;
    notifyListeners();
  }

  /// Gọi khi app vào nền (AppLifecycleState.hidden/paused).
  void onBackground() => _backgroundedAt = _clock();

  /// Gọi khi app quay lại: khóa nếu đã ở nền lâu hơn [autoLockAfter].
  void onResume() {
    final at = _backgroundedAt;
    _backgroundedAt = null;
    if (at != null && shouldAutoLock(backgroundedAt: at, now: _clock(), timeout: autoLockAfter)) lock();
  }

  void _setMessage(String m) {
    _message = m;
    notifyListeners();
  }
}
