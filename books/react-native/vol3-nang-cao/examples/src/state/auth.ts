import { create } from 'zustand';
import { logger } from '@/monitoring/logger';
import { INITIAL_LOCK, hashPin, isLocked, registerAttempt, safeEqual, validatePinFormat, type LockState } from '@/security/pin';
import { newSalt, secureStorage, sha256 } from '@/security/secureStorage';

export type AuthStatus = 'loading' | 'no-pin' | 'locked' | 'unlocked';

interface AuthState {
  status: AuthStatus;
  lock: LockState;
  init: () => Promise<void>;
  setPin: (pin: string) => Promise<string | undefined>; // trả thông báo lỗi nếu có
  unlock: (pin: string, now?: number) => Promise<boolean>;
  lockNow: () => void;
  resetAll: () => Promise<void>;
}

export const useAuth = create<AuthState>()((set, get) => ({
  status: 'loading',
  lock: INITIAL_LOCK,
  init: async () => {
    const [pin, lock] = await Promise.all([secureStorage.readPin(), secureStorage.readLock()]);
    set({ status: pin ? 'locked' : 'no-pin', lock: lock ?? INITIAL_LOCK });
  },
  setPin: async (pin) => {
    const error = validatePinFormat(pin);
    if (error) return error;
    const salt = newSalt();
    await secureStorage.writePin({ salt, hash: await hashPin(pin, salt, sha256) });
    await secureStorage.writeLock(INITIAL_LOCK);
    set({ status: 'unlocked', lock: INITIAL_LOCK });
    logger.addBreadcrumb('info', 'auth.pin_set');
    return undefined;
  },
  unlock: async (pin, now = Date.now()) => {
    const { lock } = get();
    if (isLocked(lock, now)) return false;
    const stored = await secureStorage.readPin();
    const ok = !!stored && safeEqual(await hashPin(pin, stored.salt, sha256), stored.hash);
    const next = registerAttempt(lock, ok, now);
    await secureStorage.writeLock(next);
    set({ lock: next, status: ok ? 'unlocked' : 'locked' });
    logger.addBreadcrumb(ok ? 'info' : 'warn', ok ? 'auth.unlock' : 'auth.unlock_failed', { attempts: next.failedAttempts });
    return ok;
  },
  lockNow: () => {
    if (get().status === 'unlocked') set({ status: 'locked' });
  },
  resetAll: async () => {
    await secureStorage.reset();
    set({ status: 'no-pin', lock: INITIAL_LOCK });
  },
}));
