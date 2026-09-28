import * as Crypto from 'expo-crypto';
import * as SecureStore from 'expo-secure-store';
import type { Digest, LockState } from './pin';

// Lưu bí mật trong Keychain (iOS) / Keystore (Android) qua expo-secure-store.
// Khác AsyncStorage: dữ liệu được mã hóa bởi hệ điều hành.
const KEYS = { pinHash: 'pin.hash', pinSalt: 'pin.salt', lock: 'pin.lock' } as const;
const OPTIONS: SecureStore.SecureStoreOptions = {
  keychainAccessible: SecureStore.WHEN_UNLOCKED_THIS_DEVICE_ONLY, // không sao lưu sang máy khác
};

export const sha256: Digest = (text) => Crypto.digestStringAsync(Crypto.CryptoDigestAlgorithm.SHA256, text);

export function newSalt(): string {
  return Array.from(Crypto.getRandomBytes(16), (b) => b.toString(16).padStart(2, '0')).join('');
}

export interface StoredPin {
  hash: string;
  salt: string;
}

export const secureStorage = {
  async readPin(): Promise<StoredPin | null> {
    const [hash, salt] = await Promise.all([
      SecureStore.getItemAsync(KEYS.pinHash, OPTIONS),
      SecureStore.getItemAsync(KEYS.pinSalt, OPTIONS),
    ]);
    return hash && salt ? { hash, salt } : null;
  },
  async writePin(pin: StoredPin): Promise<void> {
    await SecureStore.setItemAsync(KEYS.pinSalt, pin.salt, OPTIONS);
    await SecureStore.setItemAsync(KEYS.pinHash, pin.hash, OPTIONS);
  },
  async readLock(): Promise<LockState | null> {
    const raw = await SecureStore.getItemAsync(KEYS.lock, OPTIONS);
    try {
      return raw ? (JSON.parse(raw) as LockState) : null;
    } catch {
      return null;
    }
  },
  async writeLock(state: LockState): Promise<void> {
    await SecureStore.setItemAsync(KEYS.lock, JSON.stringify(state), OPTIONS);
  },
  async reset(): Promise<void> {
    await Promise.all(Object.values(KEYS).map((k) => SecureStore.deleteItemAsync(k, OPTIONS)));
  },
};

export type SecureStorage = typeof secureStorage;
