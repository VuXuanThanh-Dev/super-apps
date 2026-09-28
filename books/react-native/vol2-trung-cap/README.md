# Tập 2 — React Native trung cấp

Tiếp nối Tập 1. Mỗi chương có code chạy được trong `examples/` và bài tập có lời giải (phần lớn có test).

## Mục lục

1. [Quản lý state: useReducer, Context, Zustand](01-quan-ly-state.md)
2. [Lấy dữ liệu: fetch, TanStack Query](02-lay-du-lieu-data-fetching.md)
3. [Lưu trữ offline: AsyncStorage, expo-sqlite](03-luu-tru-offline.md)
4. [Animation: Animated API, Reanimated](04-animation.md)
5. [Device APIs: rung, vị trí, chọn ảnh, quyền](05-device-apis.md)
6. [Testing: jest-expo, React Native Testing Library](06-testing.md)
7. [App mẫu "Tin Đọc Sau"](07-app-mau-tin-doc-sau.md)

## App mẫu: `examples/`

Phiên bản ghim chính xác trong `examples/package.json`: Expo SDK 57 (`expo@57.0.25`), React Native 0.86.3,
React 19.2.3, TypeScript 6.0.3, expo-router 57.0.23, zustand 5.0.15, @tanstack/react-query 5.104.0,
@react-native-async-storage/async-storage 2.2.0, expo-sqlite 57.0.3, react-native-reanimated 4.5.1,
react-native-worklets 0.10.1, expo-haptics 57.0.3, expo-location 57.0.20, expo-image-picker 57.0.20,
expo-network 57.0.2. Node ≥ 20.19.4 (sách dùng 22.22.2).

### Chạy trên iPhone (Expo Go)

```bash
cd books/react-native/vol2-trung-cap/examples
npm ci
npx expo login        # cùng tài khoản Expo với app Expo Go
npx expo start        # quét QR bằng Camera
```

**Chạy trên Expo Go: NOT RUN (không có iPhone trong sandbox).** App cần Internet để tải bài từ
`https://jsonplaceholder.typicode.com` (lần đầu); sau đó xem offline được.

### Kiểm tra

```bash
npm run typecheck
npm run lint          # eslint . --max-warnings 0
npm test
npm run export:ios    # tùy chọn
```

Hoặc: `bash books/react-native/scripts/check-all.sh vol2-trung-cap`.
Kết quả ngày 2026-09-28: tsc OK, eslint OK, **11 test suites / 43 tests passed**, web + iOS bundle OK.
