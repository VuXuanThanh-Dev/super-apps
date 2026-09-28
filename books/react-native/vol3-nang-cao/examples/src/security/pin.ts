// Logic PIN thuần — không phụ thuộc thư viện native, test được hoàn toàn.

export function validatePinFormat(pin: string): string | undefined {
  if (!/^\d+$/.test(pin)) return 'PIN chỉ gồm chữ số';
  if (pin.length < 4 || pin.length > 6) return 'PIN cần 4–6 chữ số';
  if (/^(\d)\1+$/.test(pin)) return 'PIN không được là các số giống nhau';
  if ('0123456789'.includes(pin) || '9876543210'.includes(pin)) return 'PIN không được là dãy số liên tiếp';
  return undefined;
}

// Không bao giờ lưu PIN thật. Lưu hash(salt + PIN). Hàm digest được "inject" để test dễ.
export type Digest = (text: string) => Promise<string>;

export async function hashPin(pin: string, salt: string, digest: Digest): Promise<string> {
  return digest(`${salt}:${pin}`);
}

// So sánh độ dài cố định (constant-time) để không lộ thông tin qua thời gian so sánh.
export function safeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

// Khóa tạm sau nhiều lần sai: 5 lần sai → khóa 30 giây, mỗi 5 lần sai tiếp theo nhân đôi thời gian.
export interface LockState {
  failedAttempts: number;
  lockedUntil: number | null; // epoch ms
}

export const INITIAL_LOCK: LockState = { failedAttempts: 0, lockedUntil: null };

export function isLocked(state: LockState, now: number): boolean {
  return state.lockedUntil !== null && now < state.lockedUntil;
}

export function registerAttempt(state: LockState, success: boolean, now: number): LockState {
  if (success) return INITIAL_LOCK;
  const failedAttempts = state.failedAttempts + 1;
  if (failedAttempts % 5 !== 0) return { failedAttempts, lockedUntil: null };
  const level = failedAttempts / 5; // 1, 2, 3...
  return { failedAttempts, lockedUntil: now + 30_000 * 2 ** (level - 1) };
}

export function secondsLeft(state: LockState, now: number): number {
  return state.lockedUntil ? Math.max(0, Math.ceil((state.lockedUntil - now) / 1000)) : 0;
}
