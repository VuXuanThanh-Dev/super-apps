import '../../../core/security/secure_store.dart';
import '../domain/pin_hasher.dart';

/// Kết quả kiểm tra PIN.
sealed class PinCheck {
  const PinCheck();
}

final class PinOk extends PinCheck {
  const PinOk();
}

final class PinWrong extends PinCheck {
  const PinWrong(this.failedAttempts);
  final int failedAttempts;
}

final class PinLocked extends PinCheck {
  const PinLocked(this.remaining);
  final Duration remaining;
}

/// Lưu muối + hash của PIN và bộ đếm sai trong SecureStore (Keychain/Keystore).
class PinRepository {
  PinRepository(this._store, {DateTime Function()? clock, this.iterations = 10000}) : _clock = clock ?? DateTime.now;

  final SecureStore _store;
  final DateTime Function() _clock;
  final int iterations;

  static const _saltKey = 'pin_salt';
  static const _hashKey = 'pin_hash';
  static const _failedKey = 'pin_failed';
  static const _lockedUntilKey = 'pin_locked_until';

  Future<bool> hasPin() async => await _store.read(_hashKey) != null;

  Future<void> setPin(String pin) async {
    if (!isValidPinFormat(pin)) throw ArgumentError('PIN phải gồm 4–8 chữ số');
    final salt = generateSalt();
    await _store.write(_saltKey, salt);
    await _store.write(_hashKey, hashPin(pin, salt, iterations: iterations));
    await _store.delete(_failedKey);
    await _store.delete(_lockedUntilKey);
  }

  Future<PinCheck> verify(String pin) async {
    final now = _clock();
    final lockedUntil = DateTime.tryParse(await _store.read(_lockedUntilKey) ?? '');
    if (lockedUntil != null && now.isBefore(lockedUntil)) return PinLocked(lockedUntil.difference(now));

    final salt = await _store.read(_saltKey);
    final hash = await _store.read(_hashKey);
    if (salt == null || hash == null) throw StateError('Chưa tạo PIN');

    if (constantTimeEquals(hashPin(pin, salt, iterations: iterations), hash)) {
      await _store.delete(_failedKey);
      await _store.delete(_lockedUntilKey);
      return const PinOk();
    }
    final failed = (int.tryParse(await _store.read(_failedKey) ?? '') ?? 0) + 1;
    await _store.write(_failedKey, '$failed');
    final lock = lockoutDuration(failed);
    if (lock > Duration.zero) {
      await _store.write(_lockedUntilKey, now.add(lock).toIso8601String());
      return PinLocked(lock);
    }
    return PinWrong(failed);
  }
}
