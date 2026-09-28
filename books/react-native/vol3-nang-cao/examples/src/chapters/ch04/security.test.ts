import { secureStoreMock } from '@/test/mockSecureStore';
import { useAuth } from '@/state/auth';
import { parseDeepLink } from './deepLink';
import { findSuspiciousPublicEnv, getApiBaseUrl } from './publicEnv';

jest.mock('expo-secure-store', () => require('@/test/mockSecureStore').secureStoreMock); // eslint-disable-line @typescript-eslint/no-require-imports
jest.mock('expo-crypto', () => ({
  CryptoDigestAlgorithm: { SHA256: 'SHA-256' },
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  digestStringAsync: async (_alg: string, text: string) => require('node:crypto').createHash('sha256').update(text).digest('hex'),
  getRandomBytes: (n: number) => Uint8Array.from({ length: n }, (_, i) => i),
}));

describe('Tập 3 — Chương 4: bảo mật', () => {
  beforeEach(async () => {
    secureStoreMock.__clear();
    await useAuth.getState().resetAll();
  });

  it('không lưu PIN gốc: chỉ có salt + hash trong SecureStore', async () => {
    await useAuth.getState().setPin('2580');
    const saved = secureStoreMock.setItemAsync.mock.calls.map((c) => c[1]).join('|');
    expect(saved).not.toContain('2580');
    expect(useAuth.getState().status).toBe('unlocked');
  });

  it('mở khóa đúng/sai và khóa tạm sau 5 lần sai', async () => {
    await useAuth.getState().setPin('2580');
    useAuth.getState().lockNow();
    expect(await useAuth.getState().unlock('0000', 1000)).toBe(false);
    expect(await useAuth.getState().unlock('2580', 1000)).toBe(true);
    useAuth.getState().lockNow();
    for (let i = 0; i < 5; i++) await useAuth.getState().unlock('1111', 2000);
    expect(useAuth.getState().lock.lockedUntil).toBe(32_000);
    expect(await useAuth.getState().unlock('2580', 3000)).toBe(false); // đang bị khóa, PIN đúng cũng không vào
    expect(await useAuth.getState().unlock('2580', 33_000)).toBe(true);
  });

  it('init đọc lại trạng thái từ SecureStore (như mở lại app)', async () => {
    await useAuth.getState().setPin('2580');
    useAuth.setState({ status: 'loading' });
    await useAuth.getState().init();
    expect(useAuth.getState().status).toBe('locked');
  });

  it.each([
    ['rnbookvol3://note/abc-123', { screen: 'note', id: 'abc-123' }],
    ['rnbookvol3://', { screen: 'home' }],
    ['https://evil.example/note/abc', { screen: 'invalid', reason: 'Scheme không được phép' }],
    ['rnbookvol3://note/../../etc', { screen: 'invalid', reason: 'Đường dẫn không hỗ trợ' }],
    ['không phải url', { screen: 'invalid', reason: 'URL không hợp lệ' }],
  ])('parseDeepLink(%p)', (raw, expected) => {
    expect(parseDeepLink(raw)).toEqual(expected);
  });

  it('bài tập: phát hiện bí mật trong EXPO_PUBLIC_*', () => {
    expect(
      findSuspiciousPublicEnv({
        EXPO_PUBLIC_API_URL: 'https://api.example.com',
        EXPO_PUBLIC_STRIPE_KEY: 'sk_live_123',
        EXPO_PUBLIC_DB_PASSWORD: 'x',
        SERVER_SECRET: 'không public nên bỏ qua',
      }),
    ).toEqual(['EXPO_PUBLIC_STRIPE_KEY', 'EXPO_PUBLIC_DB_PASSWORD']);
    expect(getApiBaseUrl()).toBe('https://jsonplaceholder.typicode.com');
  });
});
