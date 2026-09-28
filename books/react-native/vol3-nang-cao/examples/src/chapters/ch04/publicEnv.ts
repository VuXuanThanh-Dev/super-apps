// Biến môi trường bắt đầu bằng EXPO_PUBLIC_ được Metro "nhúng" thẳng vào bundle JS.
// → Ai tải app về cũng đọc được. KHÔNG đặt khóa bí mật (secret key) ở đây.
export function getApiBaseUrl(): string {
  return process.env.EXPO_PUBLIC_API_URL ?? 'https://jsonplaceholder.typicode.com';
}

// Lời giải bài tập: phát hiện "có vẻ là bí mật" trong cấu hình public trước khi build.
const SECRET_PATTERNS = [/secret/i, /private[_-]?key/i, /password/i, /^sk_(live|test)_/i];

export function findSuspiciousPublicEnv(env: Record<string, string | undefined>): string[] {
  return Object.entries(env)
    .filter(([k]) => k.startsWith('EXPO_PUBLIC_'))
    .filter(([k, v]) => SECRET_PATTERNS.some((re) => re.test(k) || re.test(v ?? '')))
    .map(([k]) => k);
}
