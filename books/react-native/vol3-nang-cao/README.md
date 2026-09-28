# Tập 3 — React Native nâng cao

Tiếp nối Tập 2. Mỗi chương có code trong `examples/` và bài tập có lời giải (phần lớn có test).

## Mục lục

1. [New Architecture: JSI, Fabric, TurboModules, Codegen, Hermes](01-new-architecture.md)
2. [Native modules với Expo Modules API](02-native-modules-expo-modules-api.md)
3. [Performance](03-performance.md)
4. [Security](04-security.md)
5. [CI/CD: GitHub Actions và EAS](05-ci-cd.md)
6. [Phát hành App Store / Google Play](06-phat-hanh-app-store-play-store.md)
7. [Monitoring](07-monitoring.md)
8. [App mẫu "Sổ Ghi Chú Bảo Mật"](08-app-mau-so-ghi-chu-bao-mat.md)

## App mẫu: `examples/`

Phiên bản ghim chính xác trong `examples/package.json`: Expo SDK 57 (`expo@57.0.25`), React Native 0.86.3,
React 19.2.3, TypeScript 6.0.3, expo-router 57.0.23, expo-secure-store 57.0.4, expo-crypto 57.0.3,
expo-sqlite 57.0.3, @shopify/flash-list 2.0.2, zustand 5.0.15. Node ≥ 20.19.4 (sách dùng 22.22.2).
`eas-cli` 24.8.0 (chạy bằng `npx eas-cli@latest`, không cài vào dự án).

### Chạy trên iPhone (Expo Go)

```bash
cd books/react-native/vol3-nang-cao/examples
npm ci
npx expo login
npx expo start
```

**Chạy trên Expo Go: NOT RUN (không có iPhone trong sandbox).** Module native `modules/text-stats`
chưa được biên dịch (không có Xcode/Android SDK) — trong Expo Go app dùng bản JavaScript dự phòng.

### Kiểm tra

```bash
npm run typecheck
npm run lint
npm test
npm run export:ios
```

Hoặc: `bash books/react-native/scripts/check-all.sh vol3-nang-cao` (có kiểm tra cú pháp YAML trong `ci/`).
Kết quả ngày 2026-09-28: tsc OK, eslint OK, **10 test suites / 45 tests passed**, web + iOS bundle OK.

### Thư mục `ci/`

Workflow GitHub Actions **mẫu** (không đặt vào `.github/` vì ngoài phạm vi task):
`book-checks.yml` (chạy `check-all.sh` cho 3 tập) và `eas-build.yml` (build bằng EAS, cần `EXPO_TOKEN`).
