import { INITIAL_LOCK, hashPin, isLocked, registerAttempt, safeEqual, secondsLeft, validatePinFormat } from './pin';

// Trong test dùng SHA-256 của Node thay cho expo-crypto (cùng thuật toán, cùng kết quả hex).
// eslint-disable-next-line @typescript-eslint/no-require-imports
const { createHash } = require('node:crypto');
const nodeSha256 = async (t: string): Promise<string> => createHash('sha256').update(t).digest('hex');

describe('PIN', () => {
  it.each([
    ['12a4', 'PIN chỉ gồm chữ số'],
    ['123', 'PIN cần 4–6 chữ số'],
    ['1111', 'PIN không được là các số giống nhau'],
    ['3456', 'PIN không được là dãy số liên tiếp'],
    ['2580', undefined],
  ])('validatePinFormat(%p) → %p', (pin, expected) => {
    expect(validatePinFormat(pin)).toBe(expected);
  });

  it('hash phụ thuộc salt; không chứa PIN gốc', async () => {
    const a = await hashPin('2580', 'salt-a', nodeSha256);
    const b = await hashPin('2580', 'salt-b', nodeSha256);
    expect(a).not.toBe(b);
    expect(a).toHaveLength(64);
    expect(a).not.toContain('2580');
  });

  it('safeEqual', () => {
    expect(safeEqual('abc', 'abc')).toBe(true);
    expect(safeEqual('abc', 'abd')).toBe(false);
    expect(safeEqual('abc', 'ab')).toBe(false);
  });

  it('sai 5 lần → khóa 30s; sai 10 lần → khóa 60s; đúng → reset', () => {
    let s = INITIAL_LOCK;
    for (let i = 0; i < 4; i++) s = registerAttempt(s, false, 0);
    expect(isLocked(s, 0)).toBe(false);
    s = registerAttempt(s, false, 1000);
    expect(isLocked(s, 1000)).toBe(true);
    expect(secondsLeft(s, 1000)).toBe(30);
    expect(isLocked(s, 31_000)).toBe(false);
    for (let i = 0; i < 5; i++) s = registerAttempt(s, false, 40_000);
    expect(secondsLeft(s, 40_000)).toBe(60);
    expect(registerAttempt(s, true, 50_000)).toEqual(INITIAL_LOCK);
  });
});
