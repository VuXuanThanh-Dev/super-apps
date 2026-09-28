# Chương 7 — Monitoring: Error Boundary, logging, báo lỗi từ xa

## Mục tiêu

- Bắt lỗi render bằng **Error Boundary** để app không "trắng màn hình".
- Ghi **breadcrumbs** (dấu vết thao tác) và **báo lỗi** qua các transport, không lộ dữ liệu nhạy cảm.
- Biết cách nối với dịch vụ như **Sentry** (và giới hạn khi không có tài khoản).
- Test tất cả những điều trên.

## Giải thích đơn giản

Khi app chạy trên máy người dùng, bạn không thấy console. Monitoring trả lời 3 câu hỏi:
**Lỗi gì? Ở đâu? Người dùng đã làm gì trước đó?**

- **Error Boundary**: một component "lưới an toàn". Nếu component con ném lỗi khi render, nó hiện màn
  hình dự phòng ("Đã có lỗi xảy ra — Thử lại") thay vì làm sập cả cây.
- **Breadcrumbs**: danh sách ngắn các bước gần nhất ("mở màn hình", "tạo ghi chú"...), gửi kèm báo lỗi.
- **Transport**: nơi gửi báo lỗi — console khi dev, Sentry/Bugsnag khi production.

Trong Angular bạn có `ErrorHandler` toàn cục; React dùng Error Boundary theo từng nhánh cây.

## Ví dụ

### 1. Logger với breadcrumbs và lọc dữ liệu nhạy cảm

`examples/src/monitoring/logger.ts` (trích):

```ts
const MAX_BREADCRUMBS = 30;
const SENSITIVE_KEY = /pin|password|token|secret/i;

export function createLogger(now: () => number = Date.now) {
  let crumbs: Breadcrumb[] = [];
  const transports: Transport[] = [];

  return {
    addBreadcrumb(level: Level, message: string, data?: Breadcrumb['data']) {
      // Không bao giờ ghi dữ liệu nhạy cảm vào log.
      const safe = data
        ? Object.fromEntries(Object.entries(data).map(([k, v]) => [k, SENSITIVE_KEY.test(k) ? '[ẩn]' : v]))
        : undefined;
      crumbs = [...crumbs, { at: now(), level, message, data: safe }].slice(-MAX_BREADCRUMBS);
    },
    reportError(error: unknown, context?: Record<string, string>) {
      const err = error instanceof Error ? error : new Error(String(error));
      const report: ErrorReport = { error: err, breadcrumbs: crumbs, context };
      for (const t of transports) {
        try {
          t(report);
        } catch {
          // transport lỗi không được làm hỏng app
        }
      }
      return report;
    },
    // ...
  };
}
```

App ghi breadcrumb ở các chỗ quan trọng: `auth.unlock`, `auth.unlock_failed` (kèm số lần thử, **không**
kèm PIN), `note.create` (kèm độ dài, **không** kèm nội dung).

### 2. Error Boundary

`examples/src/monitoring/ErrorBoundary.tsx` (trích):

```tsx
export class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error): State {
    return { error };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    logger.reportError(error, { componentStack: (info.componentStack ?? '').slice(0, 500) });
    this.props.onError?.(error);
  }

  reset = () => this.setState({ error: null });

  render() {
    if (!this.state.error) return this.props.children;
    return (
      <View style={styles.box}>
        <Text accessibilityRole="alert" style={styles.title}>Đã có lỗi xảy ra 😢</Text>
        <Text style={styles.msg}>{this.state.error.message}</Text>
        <Pressable accessibilityRole="button" onPress={this.reset} style={styles.btn}>
          <Text style={styles.btnText}>Thử lại</Text>
        </Pressable>
      </View>
    );
  }
}
```

Error Boundary **phải** là class component (React chưa có hook tương đương). Nó **không** bắt lỗi trong
event handler, `setTimeout` hay Promise — những chỗ đó gọi `logger.reportError` bằng tay.

Layout gốc bọc toàn app: `<ErrorBoundary><AppShell /></ErrorBoundary>`, và gắn `consoleTransport`.

**Chuyện thật khi viết sách:** lúc test FlashList bị cấu hình sai (Chương 3), màn hình danh sách ném lỗi
"Element type is invalid" — và test thấy màn hình "Đã có lỗi xảy ra 😢" với đúng thông báo đó. Error
Boundary đã làm đúng việc của nó.

### 3. Test

```tsx
it('ErrorBoundary: bắt lỗi render, hiện màn hình dự phòng và báo cáo lỗi', async () => {
  const reports: ErrorReport[] = [];
  const remove = logger.addTransport((r) => reports.push(r));
  const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {}); // React in lỗi ra console
  const user = userEvent.setup();
  await render(<Harness />);
  await user.press(screen.getByRole('button', { name: 'Gây lỗi' }));
  expect(screen.getByRole('alert')).toHaveTextContent(/Đã có lỗi xảy ra/);
  expect(screen.getByText('Nổ khi render!')).toBeOnTheScreen();
  expect(reports).toHaveLength(1);
  consoleSpy.mockRestore();
  remove();
});
```

Kết quả (2026-09-28):

```text
PASS src/chapters/ch07/monitoring.test.tsx
    ✓ breadcrumbs: giữ 30 mục mới nhất và ẩn dữ liệu nhạy cảm
    ✓ reportError gửi tới mọi transport; transport lỗi không làm hỏng app
    ✓ ErrorBoundary: bắt lỗi render, hiện màn hình dự phòng và báo cáo lỗi
    ✓ bài tập: createDedupeTransport bỏ lỗi trùng trong 60 giây
```

Test toàn app cũng kiểm tra nút "💥 Thử lỗi (Error Boundary)" trong Cài đặt.

**Hai bẫy gặp khi viết test:**

1. Đặt `accessibilityRole="alert"` trên `<View>` → `getByRole('alert')` **không tìm thấy**, vì View chỉ
   là phần tử accessibility khi có `accessible={true}`. Chuyển role sang `<Text>` (Text mặc định accessible).
2. `info.componentStack` trong môi trường test không chứa tên component như mong đợi — test chỉ kiểm tra
   nó là chuỗi.

## Đi sâu

### Nối Sentry (chưa chạy — UNVERIFIED trong sandbox)

Tài liệu Expo "Using Sentry" khuyên dùng wizard:

```bash
npx @sentry/wizard@latest -i reactNative
```

Wizard cài gói, cấu hình Metro (để upload source map), và yêu cầu đăng nhập tài khoản Sentry. Phiên bản
`@sentry/react-native` mà Expo SDK 57 khuyến nghị (bundledNativeModules.json): `~7.11.0`. Sau đó, bạn có
thể nối logger của sách với Sentry bằng một transport:

```ts
import * as Sentry from '@sentry/react-native';

logger.addTransport(({ error, breadcrumbs, context }) => {
  Sentry.withScope((scope) => {
    breadcrumbs.forEach((b) => scope.addBreadcrumb({ message: b.message, level: b.level === 'warn' ? 'warning' : b.level, data: b.data }));
    if (context) scope.setContext('app', context);
    Sentry.captureException(error);
  });
});
```

Đoạn code Sentry trên **chưa được cài và chạy** (không có tài khoản/DSN, và sách không muốn thêm phụ
thuộc chỉ để minh họa) → **UNVERIFIED**. Kiểm tra API trong tài liệu Sentry trước khi dùng.

### Expo Router cũng có ErrorBoundary theo route

Tài liệu Expo Router ("Error handling"): mỗi file route có thể `export function ErrorBoundary({ error, retry })`
để bắt lỗi riêng của màn hình đó. Sách dùng một Error Boundary ở gốc cho đơn giản; app lớn nên dùng cả hai.

### Đo gì trong production?

- Tỉ lệ phiên không crash (crash-free sessions).
- Lỗi JS theo phiên bản app / runtimeVersion (để biết EAS Update nào gây lỗi).
- Thời gian khởi động, màn hình chậm.
- **Không** thu thập nội dung ghi chú, PIN, token.

## Lỗi và bẫy thường gặp

- **Nghĩ Error Boundary bắt mọi lỗi** → không bắt lỗi trong handler/Promise.
- **Log dữ liệu cá nhân** → vi phạm quyền riêng tư; lọc trước khi gửi (xem `SENSITIVE_KEY`).
- **Không có source map** → stack trace production khó đọc (bundle đã minify/Hermes bytecode).
- **Transport ném lỗi làm hỏng app** → bọc `try/catch` từng transport.
- **Bão lỗi**: một lỗi lặp lại hàng trăm lần mỗi phút → cần dedupe/sampling (bài tập).

## Tóm tắt

- Error Boundary (class) ở gốc + ErrorBoundary theo route khi cần.
- Logger: breadcrumbs có giới hạn, lọc dữ liệu nhạy cảm, nhiều transport an toàn.
- Sentry nối qua transport; cần tài khoản và source map (chưa chạy trong sách).

## Bài tập (có lời giải)

**Bài 1.** Viết `createDedupeTransport(inner, windowMs)`: không gửi lại cùng một lỗi (cùng `name` +
`message`) trong `windowMs`.

<details>
<summary>Lời giải</summary>

`examples/src/monitoring/dedupe.ts`:

```ts
export function createDedupeTransport(inner: Transport, windowMs: number, now: () => number = Date.now): Transport {
  const lastSent = new Map<string, number>();
  return (report) => {
    const key = `${report.error.name}:${report.error.message}`;
    const t = now();
    const prev = lastSent.get(key);
    if (prev !== undefined && t - prev < windowMs) return;
    lastSent.set(key, t);
    inner(report);
  };
}
```

Test: gửi A (t=0), A (t=30s, bị bỏ), B (t=30s), A (t=61s) → `inner` nhận `['A', 'B', 'A']`.
</details>

**Bài 2.** Thêm Error Boundary riêng cho màn hình ghi chú bằng API của Expo Router, để lỗi ở đó không
thay cả app bằng màn hình lỗi.

<details>
<summary>Lời giải</summary>

Trong `src/app/(app)/note/[id].tsx`:

```tsx
import { type ErrorBoundaryProps } from 'expo-router';

export function ErrorBoundary({ error, retry }: ErrorBoundaryProps) {
  return (
    <View style={{ padding: 24, gap: 12 }}>
      <Text accessibilityRole="alert">Không mở được ghi chú: {error.message}</Text>
      <AppButton title="Thử lại" onPress={retry} />
    </View>
  );
}
```

Theo tài liệu Expo Router, route export `ErrorBoundary` sẽ được bọc bởi một React Error Boundary.
(Lời giải tham khảo; chưa thêm vào app mẫu.)
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- React — Catching rendering errors with an Error Boundary (mã nguồn react.dev): https://github.com/reactjs/react.dev/blob/main/src/content/reference/react/Component.md
- Expo Router — Error handling: https://github.com/expo/expo/blob/main/docs/pages/router/error-handling.mdx
- Expo — Using Sentry: https://github.com/expo/expo/blob/main/docs/pages/guides/using-sentry.mdx
- React Native — Security (không gửi token vào công cụ monitoring): https://github.com/facebook/react-native-website/blob/main/docs/security.md
- Sentry React Native repo: https://github.com/getsentry/sentry-react-native
