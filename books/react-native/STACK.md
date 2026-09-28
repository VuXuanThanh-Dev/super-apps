# STACK — Phiên bản và thư viện dùng cho cả bộ sách

> Tất cả phiên bản dưới đây được kiểm tra ngày **2026-09-28** bằng `npm view`,
> bằng file `bundledNativeModules.json` bên trong gói `expo@57.0.25`, và bằng mã nguồn
> tài liệu chính thức trên GitHub. Trang `reactnative.dev`, `docs.expo.dev`, `expo.dev`
> bị chặn trong sandbox, nên chúng tôi đọc **mã nguồn** của các trang đó trên GitHub
> (xem mục "Nguồn tham khảo").

## 1. Tóm tắt nhanh (TL;DR)

| Thành phần | Phiên bản ghim (pinned) | Vì sao |
|---|---|---|
| Node.js | **22.22.2** (LTS) | RN 0.85+ yêu cầu Node ≥ 20.19.4; Node 22 là Active LTS |
| Expo SDK | **57** (`expo@57.0.25`) | SDK mới nhất ổn định (npm `latest` = 57.0.25). Expo Go chỉ chạy SDK mới nhất |
| React Native | **0.86.3** | Phiên bản mà Expo SDK 57 đóng gói (bundledNativeModules.json) |
| React | **19.2.3** | Theo Expo SDK 57 |
| TypeScript | **6.0.3** | Theo template `expo-template-default@57.0.27` |
| Điều hướng | `expo-router@57.0.23` | Mặc định của Expo, file-based routing |
| Test | `jest@29.7.0`, `jest-expo@57.0.5`, `@testing-library/react-native@14.0.1`, `test-renderer@1.3.0` | Preset chính thức của Expo |
| Lint | `eslint@9.39.5`, `eslint-config-expo@57.0.2` | Cấu hình flat của Expo |
| JS engine | Hermes V1 (mặc định từ RN 0.84) | Không cần cấu hình |
| Kiến trúc | New Architecture (bắt buộc từ RN 0.82) | Không thể tắt nữa |

**Chạy trên Expo Go (iPhone):** các app trong sách dùng SDK 57. Expo Go trên App Store
chỉ hỗ trợ **một** SDK (SDK mới nhất). Xem mục 4 để biết mức độ đã kiểm chứng.

## 2. Phiên bản React Native mới nhất và New Architecture

- `npm view react-native version` → **0.87.1** (bản mới nhất trên npm, 2026-09-28).
  RN 0.87.0 phát hành 2026-08-11.
- Nhưng Expo SDK 57 dùng **0.86.3**. Chúng ta theo Expo, vì Expo Go chỉ chạy đúng
  phiên bản RN mà SDK đóng gói. **Quyết định:** dùng 0.86.3, không dùng 0.87.
- Mốc quan trọng (từ blog chính thức trong repo react-native-website):
  - 0.76 (2024-10): New Architecture thành mặc định.
  - **0.82 (2025-10-08): "the first React Native that runs entirely on the New Architecture"** —
    đặt `newArchEnabled=false` sẽ bị bỏ qua. Expo SDK 54 / RN 0.81 là bản cuối còn Legacy Architecture.
  - **0.84 (2026-02-11): Hermes V1 là JavaScript engine mặc định.**
  - 0.85 (2026-04-07): Jest preset tách ra `@react-native/jest-preset`; bỏ Node < 20.19.4;
    xóa `StyleSheet.absoluteFillObject`.
  - **0.86 (2026-06-11):** không có breaking change cho người dùng; sửa edge-to-edge Android 15+;
    repo React Native chuyển từ tổ chức `facebook` sang `react` trên GitHub.
  - 0.87 (2026-08-11): Strict TypeScript API mặc định (chưa có trong SDK 57).
- Expo docs (`guides/new-architecture.mdx`): "Expo Go only supports the New Architecture."

## 3. Expo hay React Native CLI?

Tài liệu chính thức của React Native (`docs/getting-started.md`, repo react-native-website) viết:
"if you're building a new app with React Native, we recommend using a Framework", và giới thiệu
Expo là "a production-grade React Native Framework". Lệnh khuyên dùng: `npx create-expo-app@latest`.

| Tiêu chí | Expo (framework) | React Native CLI (không framework) |
|---|---|---|
| Bắt đầu | `npx create-expo-app@latest` | Cần Xcode/Android Studio ngay |
| Chạy trên iPhone không cần Mac | Có, qua **Expo Go** | Không (cần Xcode để build) |
| Routing | Expo Router (file-based) có sẵn | Tự chọn thư viện |
| Native module tùy ý | Cần **development build** (không dùng Expo Go) | Có |
| Build & phát hành | EAS Build / EAS Submit (cloud) hoặc local | Tự làm bằng Xcode/Gradle |

**Quyết định:** cả bộ sách dùng **Expo** (managed + Continuous Native Generation).
Lý do: (1) docs chính thức khuyên dùng framework; (2) Nobin test bằng Expo Go trên iPhone;
(3) Tập 3 vẫn dạy native module và build thật qua development build / EAS.

## 4. Expo SDK hiện tại và Expo Go trên iPhone

- `npm view expo dist-tags` (2026-09-28): `latest` = **57.0.25**, `next` = 58.0.0-preview.8
  (SDK 58 đang beta). Ngày phát hành 57.0.0 trên npm: 2026-06-30.
- Expo docs (`workflow/upgrading-expo-sdk-walkthrough.mdx`): Expo Go "only supports the latest
  SDK version and previous versions are no longer supported".
  Và (`develop/development-builds/faq.mdx`): "Each build of Expo Go supports one SDK version.
  The project and Expo Go SDK versions must match."
- Expo docs (`get-started/start-developing.mdx`): trên iPhone thật, Expo Go chỉ mở project khi
  **Expo CLI và Expo Go đăng nhập cùng một tài khoản Expo**: chạy `npx expo login` trên máy tính,
  rồi đăng nhập trong Expo Go (biểu tượng tài khoản góc trên bên phải).
- **UNVERIFIED (một phần):** "Expo Go trên App Store hiện hỗ trợ SDK 57". Chúng tôi không mở
  được `apps.apple.com` hay `expo.dev/changelog` (bị chặn). Bằng chứng phụ:
  (a) kết quả WebSearch nói Expo Go iOS 57.0.9 lên App Store ngày 2 tháng 9;
  (b) PR công khai ngày 2026-09-20 trên GitHub (YoniRipp/beme#371) nói
  "Expo Go ships only the latest SDK — currently 57".
  Nobin nên mở Expo Go → Settings để xem "Supported SDK".
- **Cảnh báo:** khi SDK 58 ổn định, Expo Go trên App Store sẽ chuyển sang SDK 58 và các app
  SDK 57 sẽ không mở được nữa. Khi đó chạy `npx expo install expo@^58.0.0 --fix` trong từng
  thư mục `examples/` (xem README).

## 5. Thư viện cho từng tập (tất cả có trong Expo Go SDK 57)

Cột "Nguồn phiên bản": BNM = `bundledNativeModules.json` trong `expo@57.0.25`;
npm = `npm view <pkg> version`. `npx expo install` luôn chọn đúng bản BNM.

| Tập | Thư viện | Phiên bản | Nguồn phiên bản | Dùng để |
|---|---|---|---|---|
| 1 | expo-router | 57.0.23 | BNM | Điều hướng |
| 1 | react-native-safe-area-context | 5.7.0 | BNM | Vùng an toàn (tai thỏ) |
| 1 | react-native-screens | 4.26.x | BNM | Màn hình native |
| 1 | react-native-web, react-dom | 0.21.x, 19.2.3 | BNM | Chạy `expo export --platform web` để kiểm tra |
| 2 | zustand | 5.0.15 | npm (JS thuần) | State toàn cục |
| 2 | @tanstack/react-query | 5.104.0 | npm (JS thuần) | Cache dữ liệu server |
| 2 | @react-native-async-storage/async-storage | 2.2.0 | BNM | Key-value lưu trữ |
| 2 | expo-sqlite | ~57.0.3 | BNM | Cơ sở dữ liệu SQLite |
| 2 | react-native-reanimated / react-native-worklets | 4.5.1 / 0.10.1 | BNM | Animation |
| 2 | expo-haptics, expo-location, expo-image-picker | ~57.0.x | BNM | Device APIs |
| 3 | expo-secure-store | ~57.0.4 | BNM | Lưu bí mật (Keychain/Keystore) |
| 3 | @shopify/flash-list | 2.0.2 | BNM | Danh sách hiệu năng cao |
| 3 | @sentry/react-native | ~7.11.0 | BNM | Monitoring (chỉ giới thiệu; cần DSN) |
| 3 | eas-cli | 24.8.0 | npm | Build/Submit (chạy bằng `npx eas-cli@latest`) |

Phiên bản chính xác đã cài nằm trong `package.json` + `package-lock.json` của từng
`vol*/examples/` (ghim exact, không dùng `^`/`~`).

### So sánh thư viện state (Tập 2)

| Repo | Stars | Commit gần nhất | License | Hữu ích | Ngày kiểm tra |
|---|---|---|---|---|---|
| https://github.com/pmndrs/zustand | 58.8k | 2026-08-25 | MIT | API nhỏ, giống "service có state" của Angular | 2026-09-28 |
| https://github.com/reduxjs/redux-toolkit | 11.2k | 2026-09-28 | MIT | Chuẩn doanh nghiệp, giống NgRx | 2026-09-28 |
| https://github.com/pmndrs/jotai | 21.3k | 2026-09-08 | MIT | State dạng atom, gần giống Signals | 2026-09-28 |
| https://github.com/TanStack/query | 50.4k | 2026-09-28 | MIT | Server state (cache, retry) | 2026-09-28 |

**Quyết định:** Zustand cho client state (ít boilerplate, dễ test) + TanStack Query cho
server state. Redux Toolkit và Jotai được giới thiệu so sánh trong chương.

## 6. Công cụ trong sandbox (dùng để kiểm tra sách)

| Công cụ | Phiên bản |
|---|---|
| Node / npm | 22.22.2 / 10.9.7 |
| pandoc | 3.1.3 |
| Playwright Chromium (in PDF) | playwright 1.56.1 |

Lưu ý khi cài trong sandbox: `npx expo install` gọi API của expo.dev (bị chặn), nên dùng
`EXPO_OFFLINE=1 npx expo install <pkg>` — Expo CLI khi đó dùng bảng phiên bản có sẵn trong gói `expo`.

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:
- npm registry: `npm view expo dist-tags`, `npm view expo time`, `npm view react-native version`,
  `npm view react-native time`, `npm view expo-template-default@sdk-57` — https://www.npmjs.com/package/expo
- `bundledNativeModules.json` trong gói `expo@57.0.25` (tải bằng `npm pack expo@57.0.25`).
- Expo docs source, commit `99d902f` (2026-09-28): https://github.com/expo/expo/tree/main/docs/pages
  - https://github.com/expo/expo/blob/main/docs/pages/get-started/start-developing.mdx
  - https://github.com/expo/expo/blob/main/docs/pages/workflow/upgrading-expo-sdk-walkthrough.mdx
  - https://github.com/expo/expo/blob/main/docs/pages/develop/development-builds/faq.mdx
  - https://github.com/expo/expo/blob/main/docs/pages/guides/new-architecture.mdx
  - https://github.com/expo/expo/blob/main/docs/pages/versions/v57.0.0/sdk/securestore.mdx
- React Native website source, commit `f5d7ce0` (2026-09-27):
  - https://github.com/facebook/react-native-website/blob/main/docs/getting-started.md
  - https://github.com/facebook/react-native-website/blob/main/website/blog/2025-10-08-react-native-0.82.mdx
  - https://github.com/facebook/react-native-website/blob/main/website/blog/2026-02-11-react-native-0.84.mdx
  - https://github.com/facebook/react-native-website/blob/main/website/blog/2026-04-07-react-native-0.85.mdx
  - https://github.com/facebook/react-native-website/blob/main/website/blog/2026-06-11-react-native-0.86.mdx
  - https://github.com/facebook/react-native-website/blob/main/website/blog/2026-08-11-react-native-0.87.mdx
- Bằng chứng phụ (secondary) cho Expo Go SDK 57 trên App Store: https://github.com/YoniRipp/beme/pull/371
- Trang repo GitHub (stars, license): https://github.com/pmndrs/zustand, https://github.com/reduxjs/redux-toolkit,
  https://github.com/pmndrs/jotai, https://github.com/TanStack/query
- Bị chặn, KHÔNG mở được: https://expo.dev/changelog/sdk-57, https://apps.apple.com/us/app/expo-go/id982107779,
  https://reactnative.dev, https://docs.expo.dev
