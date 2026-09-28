# React Native / Expo feature checklist (mã luật)

**[O]** = theo tài liệu chính thức của Expo (xem Nguồn). Luật không có [O] là quy ước thực hành chung
(áp dụng nếu dự án chưa có quy ước khác).

## RT — Route
- **RN-RT1** [O] Mỗi màn hình là một file có default export trong `src/app` (Expo Router, file-based routing; template mặc định hiện tại). Dự án cũ dùng `app/` ở gốc thì giữ `app/` — theo cấu trúc sẵn có, không trộn hai kiểu.
- **RN-RT2** [O] Route động dùng ngoặc vuông `src/app/words/[id].tsx`, đọc tham số bằng `useLocalSearchParams`.
- **RN-RT3** [O] Nhóm route không ảnh hưởng URL dùng ngoặc tròn `src/app/(tabs)/…`; layout trong `_layout.tsx`.
- **RN-RT4** [O] Không đặt file không phải route (component, hook, test) trong `src/app` — Expo Router sẽ coi là route.

## FD — Folder
- **RN-FD1** Tính năng nằm trong `src/features/<feature>/` (components, hooks, api/db, types, `__tests__`);
  file route trong `src/app` chỉ ghép các phần đó.
- **RN-FD2** Code dùng chung ở `src/components`, `src/hooks`, `src/constants` [O: vị trí ngoài src/app].

## PK — Packages
- **RN-PK1** [O] Cài package bằng `npx expo install <pkg>` để có phiên bản tương thích với react-native của dự án.
  Nếu `npx expo install` không gọi được api.expo.dev (mạng bị chặn), lấy phiên bản trong
  `node_modules/expo/bundledNativeModules.json` rồi `npm install <pkg>@<phiên bản đó>` (cách Task 5 đã làm).
- **RN-PK2** Dự án chạy bằng Expo Go → chỉ dùng module có trong Expo SDK hoặc JS thuần; module native khác cần development build.
- **RN-PK3** [O] Biến môi trường cho client dùng tiền tố `EXPO_PUBLIC_`; **không** để bí mật (private key) trong đó vì nằm dạng text trong app.

## SD — State & data
- **RN-SD1** State cục bộ bằng `useState`/`useReducer`; state dùng chung nhỏ → context hoặc store nhẹ theo quy ước dự án.
- **RN-SD2** Dữ liệu offline (từ điển, tiến độ học) lưu local (ví dụ `expo-sqlite`) và đọc qua một lớp repository có test.
- **RN-SD3** Logic thuần (tính điểm, lịch ôn tập, tách từ) viết thành hàm thuần, không phụ thuộc React → dễ test.

## UI — UI states
- **RN-UI1** Mỗi màn hình có loading / empty / error / success; lỗi có nút thử lại.
- **RN-UI2** Danh sách dài dùng `FlatList`/`SectionList` (ảo hoá), có `keyExtractor` ổn định.
- **RN-UI3** Tôn trọng safe area và bàn phím (`SafeAreaView`/`KeyboardAvoidingView` hoặc thư viện dự án đang dùng).
- **RN-UI4** Hỗ trợ dark mode nếu app có (dùng theme, không mã màu cứng).

## AX — Accessibility
- **RN-AX1** Phần tử bấm được: `Pressable` + `accessibilityRole="button"` + `accessibilityLabel` khi không có chữ.
- **RN-AX2** Vùng chạm đủ lớn (khoảng 44×44 pt); chữ co giãn theo cỡ chữ hệ thống (không tắt `allowFontScaling` bừa bãi).

## TS — Tests
- **RN-TS1** [O] Test bằng `jest-expo` (preset Jest của Expo) + `@testing-library/react-native`, cài bằng `npx expo install … --dev`.
- **RN-TS2** Hàm thuần: unit test đủ trường hợp biên. Màn hình: ít nhất 1 test render + 1 tương tác (`fireEvent`/`userEvent`).
- **RN-TS3** Mock dữ liệu/IO ở ranh giới (repository), không mock chi tiết bên trong component.

## VF — Verify
- **RN-VF1** `npx tsc --noEmit`, lint, `npx jest` pass — dán output thật.
- **RN-VF2** Chạy `npx expo start` và thử trên Expo Go hoặc web nếu có thể; nếu không, ghi "NOT RUN".

## Nguồn tham khảo (Sources)
Repo expo/expo, commit `99d902f` (mở 2026-09-28; docs.expo.dev bị chặn trong sandbox):
- Expo Router core concepts: https://github.com/expo/expo/blob/99d902f55f3925a9320160cbd78490e06606c1aa/docs/pages/router/basics/core-concepts.mdx
- Expo Router notation: https://github.com/expo/expo/blob/99d902f55f3925a9320160cbd78490e06606c1aa/docs/pages/router/basics/notation.mdx
- Expo CLI (`npx expo install`): https://github.com/expo/expo/blob/99d902f55f3925a9320160cbd78490e06606c1aa/docs/pages/more/expo-cli.mdx
- Unit testing with jest-expo: https://github.com/expo/expo/blob/99d902f55f3925a9320160cbd78490e06606c1aa/docs/pages/develop/unit-testing.mdx
- Environment variables: https://github.com/expo/expo/blob/99d902f55f3925a9320160cbd78490e06606c1aa/docs/pages/guides/environment-variables.mdx
- Phiên bản ghim của sách React Native: `books/react-native/STACK.md` trên branch `task-3-react-native`
