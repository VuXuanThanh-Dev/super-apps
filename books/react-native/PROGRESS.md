# PROGRESS

## Done
- M1: STACK.md (Expo SDK 57, RN 0.86.3, React 19.2.3, TS 6.0.3) — có nguồn, ngày kiểm tra.
- M2: PLAN.md, GLOSSARY.md, Tập 1 Chương 2 "React Native cho Angular developer".
- M3: Tập 1 — 8 chương, app "Việc Cần Làm": 16 suites / 57 tests.
- M4: Tập 2 — 7 chương, app "Tin Đọc Sau": 11 suites / 43 tests.
- M5: Tập 3 — 8 chương, app "Sổ Ghi Chú Bảo Mật" + local Expo module + eas.json + CI mẫu: 10 suites / 45 tests.
- M6: README gốc, 3 PDF trong `dist/` (68 + 51 + 58 trang), kiểm tra dấu OK, link check 0 link hỏng.
- Bằng chứng: `logs/check-all.txt`, `logs/check-pdf-accents.txt`, `logs/check-links.txt`, `logs/build-pdf.txt`.

## Next (việc còn lại — cần máy thật / tài khoản)
- Chạy 3 app trên iPhone bằng Expo Go (NOT RUN trong sandbox).
- Biên dịch module native Swift/Kotlin (`vol3-nang-cao/examples/modules/text-stats`) bằng development build.
- Chạy thật workflow CI mẫu (`vol3-nang-cao/ci/*.yml`) và EAS Build/Submit (cần EXPO_TOKEN, Apple/Google account).
- Một số lời giải bài tập ghi "(lời giải tham khảo)" chưa có test riêng (đã ghi rõ trong từng chương).

## Blockers
- Bị chặn (403) trong sandbox: reactnative.dev, docs.expo.dev, expo.dev (+ api.expo.dev), apps.apple.com,
  angular.dev, dev.to, jsonplaceholder.typicode.com, www.conventionalcommits.org; github.com qua curl.
  Đã thử: curl, WebFetch. Cách vòng: mã nguồn docs trên GitHub (git clone / raw.githubusercontent.com),
  `npm view`, `EXPO_OFFLINE=1`. Cần từ Nobin: cho phép các host này trong Network access nếu muốn kiểm tra lại.
- Không có iPhone / Xcode / Android SDK / tài khoản Expo-Apple-Google trong sandbox.

## Decisions
- Branch: task-3-react-native. PR: https://github.com/VuXuanThanh-Dev/super-apps/pull/3
- Expo SDK 57 (npm latest; Expo Go chỉ hỗ trợ SDK mới nhất). Không dùng RN 0.87 (Expo Go chưa hỗ trợ).
- Mỗi tập = 1 dự án Expo trong `examples/` (app mẫu + code từng chương + lời giải có test) để mọi đoạn code đều được tsc/eslint/jest kiểm tra.
- Chương "Angular → RN" là Chương 2 của Tập 1 (học sớm).
- Test: jest-expo + RNTL 14 (API async). `renderRouter` của expo-router dùng được nhưng phải giữ biến trước khi `await`.
- Không bật `typedRoutes` (cần `expo start` sinh type; CI sẽ lỗi).
- Tập 2: Zustand (client state) + TanStack Query (server state); JSONPlaceholder (bị chặn → test dùng fetch giả);
  SQLite test bằng `node:sqlite` qua adapter; Jest dùng `react-native-worklets/jest/resolver`.
- Tập 3: bật React Compiler (đã thấy trong bundle iOS; Jest không chạy compiler); FlashList 2.0.2 jestSetup hỏng
  → tự viết `jest.setup.js`; deep link parse bằng regex (URL() chuẩn hóa `..`).
- Lint `--max-warnings 0`. Workflow CI chỉ là file mẫu (không đụng `.github/` vì ngoài phạm vi).
- PDF: pandoc 3.1.3 → HTML (font Noto) → Chromium (playwright-core 1.56.1) + mermaid 12.0.0 local; lời giải `<details>` được mở sẵn khi in.
- Lỗi thật tìm được nhờ test: Tập 1 `router.back()` khi mở bằng deep link → sửa bằng `goBackOr()`.
