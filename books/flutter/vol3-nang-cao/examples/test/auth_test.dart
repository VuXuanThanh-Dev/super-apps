import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tap3_so_ghi_chu/core/logging/app_logger.dart';
import 'package:tap3_so_ghi_chu/core/security/secure_store.dart';
import 'package:tap3_so_ghi_chu/features/auth/data/pin_repository.dart';
import 'package:tap3_so_ghi_chu/features/auth/domain/pin_hasher.dart';
import 'package:tap3_so_ghi_chu/features/auth/ui/auth_controller.dart';

void main() {
  group('pin_hasher (domain thuần)', () {
    test('muối khác nhau → hash khác nhau; cùng muối → cùng hash; không chứa PIN gốc', () {
      final s1 = generateSalt(Random(1)), s2 = generateSalt(Random(2));
      expect(s1, isNot(s2));
      final h = hashPin('2468', s1, iterations: 100);
      expect(hashPin('2468', s1, iterations: 100), h);
      expect(hashPin('2468', s2, iterations: 100), isNot(h));
      expect(h.contains('2468'), isFalse);
    });

    test('constantTimeEquals, isValidPinFormat', () {
      expect(constantTimeEquals('abc', 'abc'), isTrue);
      expect(constantTimeEquals('abc', 'abd'), isFalse);
      expect(constantTimeEquals('abc', 'ab'), isFalse);
      expect(isValidPinFormat('2468'), isTrue);
      expect(isValidPinFormat('12a4'), isFalse);
      expect(isValidPinFormat('123'), isFalse);
    });

    test('lockoutDuration: 5 lần → 30s, gấp đôi, tối đa 1 giờ', () {
      expect(lockoutDuration(4), Duration.zero);
      expect(lockoutDuration(5), const Duration(seconds: 30));
      expect(lockoutDuration(6), const Duration(seconds: 60));
      expect(lockoutDuration(20), const Duration(hours: 1));
    });

    test('shouldAutoLock', () {
      final t = DateTime(2026, 9, 30, 10);
      expect(
        shouldAutoLock(
          backgroundedAt: t,
          now: t.add(const Duration(seconds: 29)),
          timeout: const Duration(seconds: 30),
        ),
        isFalse,
      );
      expect(
        shouldAutoLock(
          backgroundedAt: t,
          now: t.add(const Duration(seconds: 30)),
          timeout: const Duration(seconds: 30),
        ),
        isTrue,
      );
    });
  });

  group('PinRepository', () {
    test('chỉ lưu muối + hash; sai 5 lần thì khóa tạm; hết giờ khóa thì mở được', () async {
      var now = DateTime(2026, 9, 30, 10);
      final store = MemorySecureStore();
      final repo = PinRepository(store, iterations: 10, clock: () => now);
      expect(await repo.hasPin(), isFalse);
      await repo.setPin('2468');
      expect(store.data.values.any((v) => v.contains('2468')), isFalse);
      expect(await repo.verify('2468'), isA<PinOk>());
      for (var i = 1; i <= 4; i++) {
        expect(await repo.verify('0000'), isA<PinWrong>());
      }
      final locked = await repo.verify('0000');
      expect((locked as PinLocked).remaining, const Duration(seconds: 30));
      expect(await repo.verify('2468'), isA<PinLocked>()); // đúng PIN nhưng đang khóa
      now = now.add(const Duration(seconds: 31));
      expect(await repo.verify('2468'), isA<PinOk>());
      await expectLater(repo.setPin('12'), throwsArgumentError);
    });
  });

  group('AuthController', () {
    late DateTime now;
    late AuthController auth;
    setUp(() async {
      now = DateTime(2026, 9, 30, 10);
      auth = AuthController(
        pins: PinRepository(MemorySecureStore(), iterations: 10, clock: () => now),
        logger: AppLogger(),
        clock: () => now,
      );
      await auth.init();
    });

    test('tạo PIN: từ chối PIN yếu và PIN không khớp', () async {
      expect(auth.status, AuthStatus.needsSetup);
      await auth.createPin('1234', '1234');
      expect(auth.message, 'PIN quá dễ đoán, hãy chọn PIN khác');
      await auth.createPin('2468', '2469');
      expect(auth.message, 'Hai lần nhập không khớp');
      await auth.createPin('2468', '2468');
      expect(auth.status, AuthStatus.unlocked);
    });

    test('khóa, mở sai, mở đúng; tự khóa khi ở nền quá lâu', () async {
      await auth.createPin('2468', '2468');
      auth.lock();
      await auth.unlock('1111');
      expect((auth.status, auth.message), (AuthStatus.locked, 'Sai mã PIN (1 lần)'));
      await auth.unlock('2468');
      expect(auth.status, AuthStatus.unlocked);
      auth.onBackground();
      now = now.add(const Duration(seconds: 10));
      auth.onResume();
      expect(auth.status, AuthStatus.unlocked); // chưa đủ 30 giây
      auth.onBackground();
      now = now.add(const Duration(minutes: 2));
      auth.onResume();
      expect(auth.status, AuthStatus.locked);
    });
  });
}
