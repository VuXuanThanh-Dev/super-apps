# Tập 1 — React Native cơ bản

Dành cho developer đã biết TypeScript/Angular, chưa làm app mobile. Test trên iPhone bằng Expo Go.

## Mục lục

1. [Cài đặt và dự án đầu tiên](01-cai-dat-va-du-an-dau-tien.md)
2. [React Native cho Angular developer](02-react-native-cho-angular-developer.md) ← bảng đối chiếu Angular → RN
3. [Component, JSX, props, state](03-component-props-state.md)
4. [Styling và Flexbox](04-styling-va-flexbox.md)
5. [Danh sách: FlatList, SectionList](05-danh-sach-flatlist-sectionlist.md)
6. [Form và nhập liệu](06-form-va-nhap-lieu.md)
7. [Điều hướng với Expo Router](07-dieu-huong-expo-router.md)
8. [App mẫu "Việc Cần Làm"](08-app-mau-viec-can-lam.md)

## App mẫu và code ví dụ: `examples/`

Phiên bản (ghim chính xác trong `examples/package.json`): Node 22.22.2 (≥ 20.19.4), Expo SDK 57
(`expo@57.0.25`), React Native 0.86.3, React 19.2.3, TypeScript 6.0.3, expo-router 57.0.23.

### Chạy trên iPhone (Expo Go)

```bash
cd books/react-native/vol1-co-ban/examples
npm ci
npx expo login        # cùng tài khoản Expo với app Expo Go trên iPhone
npx expo start        # quét mã QR bằng Camera
```

- Tab **Việc cần làm**: app mẫu. Tab **Lab**: mở ví dụ của từng chương.
- Trạng thái: **Chạy trên Expo Go: NOT RUN (không có iPhone trong sandbox).**
- Nếu Expo Go báo không tương thích SDK: Expo Go trên App Store chỉ hỗ trợ SDK mới nhất.
  Khi SDK 58 ra, chạy `npx expo install expo@^58.0.0 --fix` rồi chạy lại test.

### Kiểm tra

```bash
npm run typecheck
npm run lint
npm test
npm run export:ios    # tùy chọn: tạo bundle Hermes iOS
```

Hoặc từ thư mục gốc repo: `bash books/react-native/scripts/check-all.sh vol1-co-ban`.
Kết quả ngày 2026-09-28: tsc OK, eslint OK, **16 test suites / 57 tests passed**, web + iOS bundle OK.

### Cấu trúc

```text
examples/src/
  app/                 # màn hình (Expo Router)
  features/tasks/      # model thuần, Context, component của app mẫu (+ test)
  components/          # AppButton
  chapters/chNN/       # ví dụ + lời giải bài tập từng chương (+ test)
  __tests__/           # test tích hợp toàn app (renderRouter)
```
