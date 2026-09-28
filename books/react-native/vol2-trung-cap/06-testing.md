# Chương 6 — Testing: jest-expo và React Native Testing Library

## Mục tiêu

- Hiểu bộ công cụ test của sách: **Jest 29 + jest-expo 57 + React Native Testing Library (RNTL) 14**.
- Viết test theo "kim tự tháp": hàm thuần → component → toàn app.
- Mock đúng cách: `fetch`, module native, `Alert`, thời gian (fake timers).
- Đọc báo cáo **coverage** (độ phủ).

## Giải thích đơn giản

- **Jest**: trình chạy test (giống Karma/Jasmine hoặc Jest trong Angular).
- **jest-expo**: "preset" cấu hình sẵn Jest cho Expo: biên dịch TypeScript/JSX bằng Babel, giả lập
  môi trường React Native (mặc định iOS), mock nhiều module Expo.
- **RNTL**: render component trong bộ nhớ (không cần điện thoại) và cho bạn tìm phần tử **như người
  dùng thấy**: theo vai trò (`getByRole`), nhãn (`getByLabelText`), chữ (`getByText`).

Quy tắc vàng của RNTL: "The more your tests resemble the way your software is used, the more
confidence they can give you." — test càng giống cách người dùng dùng app, càng đáng tin.

## Ví dụ

### 1. Tầng hàm thuần

Không cần render, chạy cực nhanh. Ví dụ `loadPosts` (Chương 3) với cache trong bộ nhớ:

```ts
it('mất mạng: dùng cache', async () => {
  const cache = memoryCache({ posts: [POSTS[0]], savedAt: 1 });
  const r = await loadPosts({ fetcher: async () => Promise.reject(new ApiError('offline', null)), cache });
  expect(r.source).toBe('cache');
});
```

### 2. Tầng component — mock `Alert`

`Alert.alert` là API native: trong test nó không hiện hộp thoại. Ta **spy** (theo dõi) nó, rồi tự
"bấm" nút trong hộp thoại (`examples/src/chapters/ch06/testing.test.tsx`):

```tsx
function pressAlertButton(spy: jest.SpyInstance, text: string) {
  const buttons = spy.mock.calls[0][2] as AlertButton[];
  buttons.find((b) => b.text === text)?.onPress?.();
}

it('Alert: bấm "Xóa" thì gọi onConfirm', async () => {
  const alertSpy = jest.spyOn(Alert, 'alert').mockImplementation(() => {});
  const onConfirm = jest.fn();
  const user = userEvent.setup();
  await render(<ConfirmDeleteButton itemName="Bài 1" onConfirm={onConfirm} />);

  await user.press(screen.getByRole('button', { name: 'Xóa Bài 1' }));
  expect(alertSpy).toHaveBeenCalledWith('Xóa?', 'Bài 1', expect.any(Array));

  pressAlertButton(alertSpy, 'Xóa');
  expect(onConfirm).toHaveBeenCalledTimes(1);
  alertSpy.mockRestore();
});
```

Đây là phần còn thiếu ở app Tập 1 (luồng "Xóa việc" dùng `Alert`).

### 3. Tầng toàn app — `renderRouter` + mạng giả

`examples/src/__tests__/app.test.tsx`:

```tsx
jest.mock('expo-network', () => ({
  useNetworkState: () => ({ isConnected: true, isInternetReachable: true }),
  addNetworkStateListener: () => ({ remove: () => {} }),
  getNetworkStateAsync: async () => ({ isConnected: true }),
}));

it('mất mạng: hiện dữ liệu đã lưu trong cache', async () => {
  await asyncStoragePostsCache.save([POSTS[2]], new Date(2026, 8, 28, 8, 5).getTime());
  fetchMock.mockRejectedValue(new TypeError('Network request failed'));
  await renderApp();
  expect(await screen.findByText('Dữ liệu offline, lưu lúc 08:05 28/09')).toBeOnTheScreen();
  expect(screen.getByText('TanStack Query cho người mới')).toBeOnTheScreen();
});
```

Test này đi qua **mọi lớp thật**: layout gốc, QueryClient, `usePosts`, `loadPosts`, AsyncStorage
(bản giả của thư viện), màn hình. Chỉ `fetch` và `expo-network` là giả.

### Kết quả toàn bộ Tập 2 (2026-09-28)

```text
PASS src/__tests__/app.test.tsx
  App Tập 2: Tin Đọc Sau
    ✓ tải bài viết từ mạng, mở chi tiết
    ✓ mất mạng: hiện dữ liệu đã lưu trong cache
    ✓ mất mạng và chưa có cache: báo lỗi + nút Thử lại
    ✓ yêu thích một bài → xuất hiện ở tab Yêu thích
  Tab Lab
    ✓ mở ví dụ Zustand
PASS src/chapters/ch06/testing.test.tsx
    ✓ Alert: bấm "Xóa" thì gọi onConfirm
    ✓ Alert: bấm "Hủy" thì không xóa
    ✓ bài tập: OfflineBanner với { isConnected: false, isInternetReachable: false } → hiện = true
    ✓ bài tập: OfflineBanner với { isConnected: true, isInternetReachable: false } → hiện = true
    ✓ bài tập: OfflineBanner với { isConnected: true, isInternetReachable: true } → hiện = false
    ✓ bài tập: OfflineBanner với { isConnected: true, isInternetReachable: undefined } → hiện = false
...
Test Suites: 11 passed, 11 total
Tests:       43 passed, 43 total
```

Coverage (`npx jest --coverage --coverageReporters=text-summary`):

```text
=============================== Coverage summary ===============================
Statements   : 92.09% ( 338/367 )
Branches     : 81.56% ( 115/141 )
Functions    : 88.95% ( 153/172 )
Lines        : 92.69% ( 279/301 )
================================================================================
```

## Đi sâu

### Cấu hình Jest của Tập 2

```json
"jest": {
  "preset": "jest-expo",
  "resolver": "react-native-worklets/jest/resolver",
  "setupFilesAfterEnv": ["./jest.setup.js"]
}
```

`jest.setup.js` bật matcher của Reanimated và mock AsyncStorage (xem Chương 3, 4).

### Chọn query (theo hướng dẫn RNTL v14)

Thứ tự ưu tiên: `getByRole` → `getByLabelText` → `getByPlaceholderText` → `getByText` →
`getByDisplayValue` → `getByTestId` (cuối cùng).

- `getBy*`: phải có, không có thì lỗi.
- `queryBy*`: chỉ dùng để khẳng định **không có** (`.not.toBeOnTheScreen()`).
- `findBy*`: chờ phần tử xuất hiện (sau API, timer).

### RNTL 14: mọi thứ là async

`await render(...)`, `await fireEvent(...)`, `await renderHook(...)`, `await user.press(...)`,
`await view.rerender(...)`, `await view.unmount()`. Quên `await` → cảnh báo `act(...)` hoặc test
chạy sai thứ tự.

### Ba cách mock

| Mock gì | Cách | Ví dụ trong sách |
|---|---|---|
| Module cả gói | `jest.mock('expo-location', () => ({ ... }))` | ch05 `device.test.tsx` |
| Một hàm của object | `jest.spyOn(Alert, 'alert')` | ch06 `testing.test.tsx` |
| Global | `globalThis.fetch = jest.fn()` | ch02, app test |
| Dependency qua tham số | truyền `fetchImpl`, `cache`, `now` | `createApiClient`, `loadPosts` |

Cách cuối (inject qua tham số) là dễ nhất và ít "phép màu" nhất — giống DI của Angular.

### So với Angular testing

| Angular | Sách này |
|---|---|
| `TestBed.configureTestingModule` | `renderWithProviders(ui)` tạo QueryClient mới |
| `HttpTestingController.expectOne(url).flush(data)` | `fetchMock.mockResolvedValueOnce(jsonResponse(data))` |
| `fakeAsync` / `tick` | `jest.useFakeTimers()` / `jest.advanceTimersByTime()` |
| `By.css`, `nativeElement.textContent` | `getByRole`, `toHaveTextContent` |
| Cypress/Playwright E2E | Maestro/Detox (ngoài phạm vi sách; cần simulator) |

## Lỗi và bẫy thường gặp

- **Quên `await`** với API RNTL 14.
- **Mock rò giữa các test** → `jest.clearAllMocks()` / `mockReset()` trong `beforeEach`.
- **Store/cache singleton** (Zustand, AsyncStorage giả) giữ dữ liệu giữa các test → reset trong `beforeEach`.
- **QueryClient dùng chung** giữa các test → tạo mới mỗi test, `retry: false`.
- **Tìm theo `testID` khắp nơi** → test không phản ánh người dùng; ưu tiên role/label/text.
- **`jest.spyOn(RN, 'useWindowDimensions')` không tác dụng** (xem Tập 1, Chương 4) → tách component nhận giá trị qua props.
- **Snapshot test lớn** → dễ vỡ, khó review. Sách không dùng snapshot.

## Tóm tắt

- Jest + jest-expo + RNTL 14; ưu tiên test hành vi qua role/label/text.
- Kim tự tháp: nhiều test thuần, vừa đủ test component, vài test toàn app.
- Mock ít nhất có thể; inject dependency qua tham số khi được.

## Bài tập (có lời giải)

**Bài 1.** Viết test cho `OfflineBanner` với 4 trạng thái mạng, dùng `it.each` và mock `expo-network`.

<details>
<summary>Lời giải</summary>

```tsx
jest.mock('expo-network', () => ({ useNetworkState: jest.fn() }));

it.each([
  [{ isConnected: false, isInternetReachable: false }, true],
  [{ isConnected: true, isInternetReachable: false }, true],
  [{ isConnected: true, isInternetReachable: true }, false],
  [{ isConnected: true, isInternetReachable: undefined }, false],
])('bài tập: OfflineBanner với %o → hiện = %p', async (state, visible) => {
  jest.mocked(useNetworkState).mockReturnValue(state as never);
  await render(<OfflineBanner />);
  const banner = screen.queryByRole('alert');
  if (visible) expect(banner).toBeOnTheScreen();
  else expect(banner).not.toBeOnTheScreen();
});
```

Trường hợp `isInternetReachable: undefined` (chưa biết) quan trọng: banner **không** được hiện,
nếu không app sẽ nhấp nháy "offline" mỗi lần mở.
</details>

**Bài 2.** Viết test cho luồng "Xóa việc" của app Tập 1 (`src/app/task/[id].tsx`), dùng kỹ thuật `Alert` ở trên.

<details>
<summary>Lời giải</summary>

Trong `vol1-co-ban/examples/src/__tests__/app.routes.test.tsx`:

```tsx
it('xóa việc sau khi xác nhận', async () => {
  const alertSpy = jest.spyOn(Alert, 'alert').mockImplementation(() => {});
  const app = await renderApp('/task/seed-2');
  await userEvent.setup().press(await screen.findByRole('button', { name: 'Xóa' }));
  const buttons = alertSpy.mock.calls[0][2] as AlertButton[];
  await act(async () => { buttons.find((b) => b.text === 'Xóa')?.onPress?.(); });
  expect(app.getPathname()).toBe('/');
  expect(screen.queryByText('Đọc chương Flexbox')).not.toBeOnTheScreen();
  alertSpy.mockRestore();
});
```

Test này đã được thêm vào Tập 1 và **tìm ra một lỗi thật**: khi mở thẳng `/task/seed-2` rồi xóa,
`router.back()` không có chỗ quay lại ("The action 'GO_BACK' was not handled by any navigator").
Tập 1 đã sửa bằng hàm `goBackOr(router, '/')` (xem Tập 1, Chương 7). Đây là lý do nên có test tích hợp.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- React Native Testing Library — repo và README: https://github.com/callstack/react-native-testing-library
- RNTL — LLM guidelines v14 (query, async): https://github.com/callstack/react-native-testing-library/blob/main/docs/guides/llm-guidelines.md
- RNTL — Migration to v14: https://github.com/callstack/react-native-testing-library/blob/main/docs/guides/migration-v14.md
- Expo — Unit testing with Jest (mã nguồn docs): https://github.com/expo/expo/blob/main/docs/pages/develop/unit-testing.mdx
- React Native — Testing overview: https://github.com/facebook/react-native-website/blob/main/docs/testing-overview.md
- TanStack Query — Testing: https://github.com/TanStack/query/blob/main/docs/framework/react/guides/testing.md
