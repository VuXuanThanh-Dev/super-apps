import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// PIN hợp lệ: 4–8 chữ số.
bool isValidPinFormat(String pin) => RegExp(r'^\d{4,8}$').hasMatch(pin);

/// Muối (salt) ngẫu nhiên 16 byte từ bộ sinh số an toàn (Random.secure) — mỗi PIN một muối.
String generateSalt([Random? random]) {
  final r = random ?? Random.secure();
  return base64Encode(List<int>.generate(16, (_) => r.nextInt(256)));
}

/// Băm PIN = SHA-256 lặp [iterations] lần với muối. KHÔNG lưu PIN gốc.
/// Lưu ý thật thà: PIN 4–6 số chỉ có 10^4–10^6 khả năng; nếu kẻ xấu lấy được hash thì vẫn dò được.
/// Bảo vệ chính là: hash nằm trong Keychain/Keystore + khóa tạm sau nhiều lần sai.
String hashPin(String pin, String salt, {int iterations = 10000}) {
  final saltBytes = base64Decode(salt);
  var digest = sha256.convert([...saltBytes, ...utf8.encode(pin)]).bytes;
  for (var i = 1; i < iterations; i++) {
    digest = sha256.convert([...digest, ...saltBytes]).bytes;
  }
  return base64Encode(digest);
}

/// So sánh không để lộ thời gian (constant-time): luôn duyệt hết chuỗi.
bool constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

/// Thời gian khóa sau [failedAttempts] lần sai liên tiếp: 5 lần → 30 giây, mỗi lần sai thêm gấp đôi, tối đa 1 giờ.
Duration lockoutDuration(int failedAttempts) {
  if (failedAttempts < 5) return Duration.zero;
  final seconds = 30 * pow(2, failedAttempts - 5).toInt();
  return Duration(seconds: min(seconds, 3600));
}

/// Có nên khóa lại app khi quay về từ nền (background) không.
bool shouldAutoLock({required DateTime backgroundedAt, required DateTime now, required Duration timeout}) =>
    now.difference(backgroundedAt) >= timeout;

/// PIN yếu (Bài 1 Chương 4) — mọi chữ số giống nhau, dãy tăng/giảm liên tiếp, hoặc nằm trong danh sách hay gặp.
bool isWeakPin(String pin) {
  if (pin.isEmpty) return true;
  if (pin.split('').toSet().length == 1) return true; // 0000, 1111
  final digits = pin.codeUnits.map((c) => c - 48).toList();
  bool stepBy(int step) {
    for (var i = 1; i < digits.length; i++) {
      if (digits[i] - digits[i - 1] != step) return false;
    }
    return true;
  }

  if (stepBy(1) || stepBy(-1)) return true; // 1234, 9876
  const common = {'1212', '1004', '2000', '6969', '4321', '1122', '2580', '0852'};
  return common.contains(pin);
}
