# PROGRESS

## Done
- M1: STACK.md (Expo SDK 57, RN 0.86.3, React 19.2.3, TS 6.0.3) — có nguồn.
- M2: PLAN.md (3 tập), GLOSSARY.md, Chương 2 Tập 1 "React Native cho Angular developer".
- Tập 1 code: `vol1-co-ban/examples` (app "Việc Cần Làm" + code chương 1–8 + lời giải) — tsc/eslint/jest/expo export web+ios PASS.
- M3: Tập 1 xong — 8 chương + README; check-all: 16 suites / 57 tests PASS, web + iOS bundle OK.

- M4: Tập 2 xong — 7 chương + README; check-all: 11 suites / 43 tests PASS, web + iOS bundle OK.
  Test tích hợp tìm ra lỗi thật ở Tập 1 (router.back() khi mở bằng deep link) → đã sửa bằng goBackOr().

## Next
- M5: Tập 3 (New Architecture, native modules, performance, security, CI/CD, release, monitoring, app mẫu).
- M6: PDF + link check + PR.

## Blockers
- Bị chặn (403) trong sandbox: reactnative.dev, docs.expo.dev, expo.dev, api.expo.dev, dev.to,
  apps.apple.com, angular.dev. Cách vòng: đọc mã nguồn docs trên GitHub, `npm view`,
  `EXPO_OFFLINE=1` cho `npx expo install`. Cần từ Nobin: cho phép các host này trong Network access.
- Không có iPhone: không chạy được trên Expo Go (ghi NOT RUN). Thay thế: jest + `expo export --platform ios` (bundle Hermes OK).

## Decisions
- Branch: task-3-react-native. PR nháp: https://github.com/VuXuanThanh-Dev/super-apps/pull/3
- Expo SDK 57 (latest trên npm; Expo Go chỉ hỗ trợ SDK mới nhất). Không dùng RN 0.87 vì Expo Go chưa hỗ trợ.
- Mỗi tập = 1 dự án Expo trong `examples/` (app mẫu + code từng chương + lời giải bài tập có test).
- Test: jest-expo + RNTL 14 (API async). expo-router `renderRouter` dùng được với RNTL 14,
  nhưng phải giữ biến trước khi `await` (xem `src/__tests__/app.routes.test.tsx`).
- Không bật `typedRoutes` (cần `expo start` để sinh type; tsc trên CI sẽ lỗi nếu chưa sinh).
- Chương "Angular → RN" đặt là Chương 2 của Tập 1 để học sớm.
- Tập 2: Zustand (client state) + TanStack Query (server state); API giả JSONPlaceholder
  (bị chặn trong sandbox → test dùng fetch giả). SQLite test bằng `node:sqlite` qua adapter.
- Jest Tập 2 dùng `resolver: react-native-worklets/jest/resolver` (Reanimated 4.5.1 không có jest/resolver).
- Lint dùng `--max-warnings 0`.
