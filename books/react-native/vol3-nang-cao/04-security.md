# Chương 4 — Security (bảo mật)

## Mục tiêu

- Biết cái gì **không bao giờ** được đặt trong app (khóa bí mật, mật khẩu thật).
- Lưu dữ liệu nhạy cảm bằng **expo-secure-store** (Keychain/Keystore).
- Làm màn hình khóa bằng PIN: hash + salt, so sánh an toàn, khóa tạm sau nhiều lần sai.
- Kiểm tra dữ liệu từ bên ngoài (deep link) và bảo vệ route.

## Giải thích đơn giản

Quy tắc số 1: **mọi thứ trong bundle JS đều có thể bị đọc.** App tải về máy người dùng; người có kỹ
năng có thể giải nén và đọc code. Vì vậy:

- Khóa API "bí mật" (secret key) phải nằm ở **server**, không nằm trong app.
- Biến `EXPO_PUBLIC_*` được nhúng thẳng vào bundle. Tài liệu Expo cảnh báo: "Do not store sensitive
  info, such as private keys, in `EXPO_PUBLIC_` variables. These variables will be visible in
  plain-text in your compiled application."

Quy tắc số 2: dữ liệu nhạy cảm trên máy → **Keychain (iOS) / Keystore (Android)**, qua expo-secure-store.
Tài liệu React Native (trang Security) mô tả Async Storage là kho "unencrypted" (không mã hóa) và
khuyên không dùng nó cho token, bí mật.

| Dữ liệu | Nơi lưu |
|---|---|
| Cài đặt giao diện, cache công khai | AsyncStorage / SQLite |
| Token đăng nhập, hash PIN, khóa mã hóa | **expo-secure-store** |
| Khóa bí mật của server (API secret) | **Không lưu trong app** — để ở backend |

## Ví dụ

### 1. PIN: không lưu PIN, chỉ lưu hash(salt + PIN)

`examples/src/security/pin.ts` (trích):

```ts
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

// 5 lần sai → khóa 30 giây, mỗi 5 lần sai tiếp theo nhân đôi thời gian.
export function registerAttempt(state: LockState, success: boolean, now: number): LockState {
  if (success) return INITIAL_LOCK;
  const failedAttempts = state.failedAttempts + 1;
  if (failedAttempts % 5 !== 0) return { failedAttempts, lockedUntil: null };
  const level = failedAttempts / 5;
  return { failedAttempts, lockedUntil: now + 30_000 * 2 ** (level - 1) };
}
```

`validatePinFormat` từ chối PIN yếu: không phải số, dài < 4 hoặc > 6, toàn số giống nhau (`1111`),
dãy liên tiếp (`1234`, `3456`, `9876`).

### 2. Lưu vào SecureStore

`examples/src/security/secureStorage.ts` (trích):

```ts
const OPTIONS: SecureStore.SecureStoreOptions = {
  keychainAccessible: SecureStore.WHEN_UNLOCKED_THIS_DEVICE_ONLY, // không sao lưu sang máy khác
};

export const sha256: Digest = (text) => Crypto.digestStringAsync(Crypto.CryptoDigestAlgorithm.SHA256, text);

export function newSalt(): string {
  return Array.from(Crypto.getRandomBytes(16), (b) => b.toString(16).padStart(2, '0')).join('');
}
```

- `expo-crypto`: `digestStringAsync` (SHA-256), `getRandomBytes` (số ngẫu nhiên an toàn).
- `WHEN_UNLOCKED_THIS_DEVICE_ONLY`: chỉ đọc được khi máy mở khóa, và không đi theo bản sao lưu.

> **Giới hạn của ví dụ:** SHA-256 một vòng với PIN 4–6 số **không đủ** chống dò khi kẻ tấn công lấy
> được hash (chỉ 10⁶ khả năng). Ở đây hash nằm trong Keychain nên khó lấy, và khóa tạm làm chậm việc
> đoán qua giao diện. App thật nên dùng khóa phần cứng/sinh trắc học (expo-local-authentication — Face
> ID **không có** trong Expo Go) hoặc hàm dẫn xuất khóa chậm (PBKDF2/Argon2) ở tầng native.

### 3. Store xác thực

`examples/src/state/auth.ts` (trích):

```ts
unlock: async (pin, now = Date.now()) => {
  const { lock } = get();
  if (isLocked(lock, now)) return false;
  const stored = await secureStorage.readPin();
  const ok = !!stored && safeEqual(await hashPin(pin, stored.salt, sha256), stored.hash);
  const next = registerAttempt(lock, ok, now);
  await secureStorage.writeLock(next);   // lưu số lần sai: tắt app mở lại cũng không "reset" được
  set({ lock: next, status: ok ? 'unlocked' : 'locked' });
  return ok;
},
```

### 4. Protected routes + khóa khi xuống nền

`examples/src/app/_layout.tsx`:

```tsx
const sub = AppState.addEventListener('change', (next) => {
  if (next === 'background') lockNow();
});
// ...
<Stack screenOptions={{ headerShown: false }}>
  <Stack.Protected guard={unlocked}>
    <Stack.Screen name="(app)" />
  </Stack.Protected>
  <Stack.Protected guard={!unlocked}>
    <Stack.Screen name="lock" />
  </Stack.Protected>
</Stack>
```

Tài liệu Expo Router: khi `guard` là false, người dùng không vào được màn hình đó và được chuyển về
màn hình khả dụng đầu tiên; khi `guard` đổi từ true sang false, lịch sử của màn hình đó bị xóa.

### 5. Deep link: không tin dữ liệu bên ngoài

`examples/src/chapters/ch04/deepLink.ts`:

```ts
const PREFIX = /^rnbookvol3:\/\/(.*)$/;
const ID = /^[a-z0-9-]{1,40}$/;

export function parseDeepLink(raw: string): DeepLinkTarget {
  const m = PREFIX.exec(raw.trim());
  if (!m) return { screen: 'invalid', reason: /^[a-z][a-z0-9+.-]*:/i.test(raw) ? 'Scheme không được phép' : 'URL không hợp lệ' };
  const path = m[1].split(/[?#]/)[0];
  const parts = path.split('/').filter(Boolean);
  if (parts.length === 0) return { screen: 'home' };
  if (parts[0] === 'note' && parts.length === 2 && ID.test(parts[1])) return { screen: 'note', id: parts[1] };
  return { screen: 'invalid', reason: 'Đường dẫn không hỗ trợ' };
}
```

**Phát hiện khi viết test:** phiên bản đầu dùng `new URL(raw)`. Với `rnbookvol3://note/../../etc`,
`URL` tự chuẩn hóa thành host `note` + path `/etc` → link được chấp nhận như id `etc`, dấu hiệu `..`
bị che mất. Chúng tôi chuyển sang phân tích bằng regex + allowlist. Màn hình ghi chú cũng kiểm tra lại
tham số bằng `parseNoteId` trước khi dùng.

### Test — kết quả thật (2026-09-28)

```text
PASS src/chapters/ch04/security.test.ts
    ✓ không lưu PIN gốc: chỉ có salt + hash trong SecureStore
    ✓ mở khóa đúng/sai và khóa tạm sau 5 lần sai
    ✓ init đọc lại trạng thái từ SecureStore (như mở lại app)
    ✓ parseDeepLink("rnbookvol3://note/abc-123")
    ✓ parseDeepLink("rnbookvol3://")
    ✓ parseDeepLink("https://evil.example/note/abc")
    ✓ parseDeepLink("rnbookvol3://note/../../etc")
    ✓ parseDeepLink("không phải url")
    ✓ bài tập: phát hiện bí mật trong EXPO_PUBLIC_*
PASS src/security/pin.test.ts
    (8 tests: validatePinFormat ×5, hash + salt, safeEqual, khóa tạm)
```

Trong test, `expo-secure-store` được thay bằng Map trong bộ nhớ (`src/test/mockSecureStore.ts`) và
`expo-crypto` bằng SHA-256 của Node (`node:crypto`) — cùng thuật toán, cùng kết quả hex.

## Đi sâu

### Checklist bảo mật cho app RN (tóm tắt từ trang Security của RN + tài liệu Expo)

1. Không có bí mật trong bundle / `EXPO_PUBLIC_*`.
2. Token → SecureStore; không log token; không gửi token vào công cụ monitoring (Chương 7 có lọc).
3. Chỉ HTTPS (iOS App Transport Security chặn HTTP mặc định).
4. OAuth trên mobile: dùng Authorization Code + **PKCE** (trang Security của RN giải thích vì sao;
   `expo-auth-session` có tùy chọn `usePKCE`), không nhúng client secret.
5. Kiểm tra mọi input từ deep link, push notification, clipboard.
6. Khóa màn hình nhạy cảm khi app xuống nền.
7. Cân nhắc SSL pinning cho app tài chính (cần native/development build).

### Vì sao không mã hóa luôn ghi chú?

Ghi chú của app mẫu nằm trong SQLite **không mã hóa**. expo-sqlite hỗ trợ SQLCipher, nhưng tài liệu
SDK 57 ghi "SQLCipher is not supported on Expo Go". Muốn mã hóa thật: development build + SQLCipher,
khóa lưu trong SecureStore. Sách ghi rõ giới hạn này thay vì giả vờ an toàn.

### `requireAuthentication` của SecureStore

Tài liệu SDK 57: tùy chọn `requireAuthentication` "is not supported in Expo Go when biometric
authentication is available" (thiếu khóa `NSFaceIDUsageDescription`). Dùng trong development build.

## Lỗi và bẫy thường gặp

- **Đặt API secret trong `.env` với tiền tố `EXPO_PUBLIC_`** → lộ ra bundle.
- **Lưu token trong AsyncStorage / Zustand persist** → không mã hóa.
- **So sánh hash bằng `===`** trong code nhạy cảm → nên dùng so sánh thời gian cố định.
- **Reset số lần sai khi khởi động lại app** → kẻ tấn công chỉ cần tắt/mở app. Lưu `LockState` vào SecureStore.
- **Tin `new URL()` để kiểm tra đường dẫn** → chuẩn hóa `..` che mất dấu hiệu tấn công.
- **Log dữ liệu nhạy cảm** vào breadcrumbs → logger của Chương 7 tự thay bằng `[ẩn]`.

## Tóm tắt

- Không có bí mật trong app; dữ liệu nhạy cảm vào SecureStore.
- PIN: hash + salt, so sánh an toàn, khóa tạm lưu bền vững, khóa khi xuống nền.
- Protected routes + kiểm tra deep link = không vào được màn hình khi chưa mở khóa.

## Bài tập (có lời giải)

**Bài 1.** Viết `findSuspiciousPublicEnv(env)` trả về tên các biến `EXPO_PUBLIC_*` có vẻ chứa bí mật
(tên chứa `secret`, `password`, `private_key`, hoặc giá trị bắt đầu bằng `sk_live_`/`sk_test_`).

<details>
<summary>Lời giải</summary>

`examples/src/chapters/ch04/publicEnv.ts`:

```ts
const SECRET_PATTERNS = [/secret/i, /private[_-]?key/i, /password/i, /^sk_(live|test)_/i];

export function findSuspiciousPublicEnv(env: Record<string, string | undefined>): string[] {
  return Object.entries(env)
    .filter(([k]) => k.startsWith('EXPO_PUBLIC_'))
    .filter(([k, v]) => SECRET_PATTERNS.some((re) => re.test(k) || re.test(v ?? '')))
    .map(([k]) => k);
}
```

Chạy hàm này trong CI (Chương 5) với `process.env` trước khi build để chặn lỗi sớm.
</details>

**Bài 2.** Tắt app rồi mở lại có "xóa" được số lần nhập sai không? Viết test.

<details>
<summary>Lời giải</summary>

Không — `LockState` được ghi vào SecureStore sau mỗi lần thử, và `init()` đọc lại. Test
"init đọc lại trạng thái từ SecureStore (như mở lại app)" đặt `status: 'loading'` rồi gọi `init()`
và thấy `status === 'locked'`; tương tự, `lock` được đọc lại từ `pin.lock`.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- React Native — Security: https://github.com/facebook/react-native-website/blob/main/docs/security.md
- Expo — Environment variables: https://github.com/expo/expo/blob/main/docs/pages/guides/environment-variables.mdx
- Expo — SecureStore (SDK 57): https://github.com/expo/expo/blob/main/docs/pages/versions/v57.0.0/sdk/securestore.mdx
- Expo — Crypto (SDK 57): https://github.com/expo/expo/blob/main/docs/pages/versions/v57.0.0/sdk/crypto.mdx
- Expo — SQLite (SQLCipher và Expo Go): https://github.com/expo/expo/blob/main/docs/pages/versions/v57.0.0/sdk/sqlite.mdx
- Expo — LocalAuthentication (Face ID và Expo Go): https://github.com/expo/expo/blob/main/docs/pages/versions/v57.0.0/sdk/local-authentication.mdx
- Expo — AuthRequest types (`usePKCE`): https://github.com/expo/expo/blob/main/packages/expo-auth-session/src/AuthRequest.types.ts
- React Native — Networking (App Transport Security): https://github.com/facebook/react-native-website/blob/main/docs/network.md
- Expo Router — Protected routes: https://github.com/expo/expo/blob/main/docs/pages/router/advanced/protected.mdx
