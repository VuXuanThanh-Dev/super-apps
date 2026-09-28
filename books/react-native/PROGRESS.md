# PROGRESS

## Done
- M1: STACK.md (Expo SDK 57, RN 0.86.3, React 19.2.3, TS 6.0.3) — có nguồn.
- M2: PLAN.md (3 tập), GLOSSARY.md, Chương 2 Tập 1 "React Native cho Angular developer".
- Tập 1 code: `vol1-co-ban/examples` (app "Việc Cần Làm" + code chương 1–8 + lời giải) — tsc/eslint/jest/expo export web+ios PASS.
- Tập 1: chương 1, 2 đã viết.

## Next
- Tập 1: viết chương 3–8, README tập, commit (M3).
- Rồi M4 (Tập 2), M5 (Tập 3), M6 (PDF).

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
