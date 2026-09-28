---
name: react-native-feature-checklist
description: Step-by-step checklist for adding one feature (screen + route + state + data + tests) to an Expo / React Native app with Expo Router file-based routes in src/app, feature folders, npx expo install for compatible packages, Expo Go compatibility, offline data, accessibility and jest-expo + React Native Testing Library tests. Use when planning, building or self-checking a new screen or feature in an Expo app (the TOEIC app, React Native book samples), or when the react-native-mobile agent needs the feature workflow. Not for Angular web (angular-review-checklist), not for list/animation performance tuning (performance-optimizer agent) and not for EAS/CI pipelines (devops-ci agent).
---

# React Native feature checklist

Skill này là **quy trình/checklist**; agent `react-native-mobile` có thể nạp sẵn bằng
`skills: [react-native-feature-checklist]`. Không có agent thì main session dùng trực tiếp.

## Steps

1. **Đọc phiên bản đã ghim** của dự án: `package.json` (`expo`, `react-native`, `expo-router`),
   và `STACK.md` nếu có (sách React Native ghim Expo SDK 57 / RN 0.86.3, kiểm tra 2026-09-28).
   Không nâng phiên bản trong lúc làm tính năng.
2. **Viết spec 5 dòng** trước khi code: người dùng làm gì, dữ liệu vào/ra, trạng thái
   loading/empty/error, offline có chạy không, tiêu chí xong (acceptance criteria).
3. **Đi qua checklist** [references/checklist.md](references/checklist.md) theo thứ tự:
   Route → Folder → Packages → State & data → UI states → Accessibility → Tests → Verify.
4. **Chạy kiểm tra thật**: `npx tsc --noEmit`, `npx expo lint` (hoặc `npm run lint`),
   `npx jest <feature>`; nếu có thể, `npx expo start` và mở trên Expo Go / web.
   Không chạy được (ví dụ không có thiết bị) → ghi "NOT RUN" + Blocker.

## Expected output

- Danh sách file tạo/sửa theo cấu trúc (ví dụ `src/app/words/[id].tsx`,
  `src/features/words/…`, `src/features/words/__tests__/…`).
- Bảng checklist: mã luật → ✅ / ❌ / N/A + ghi chú.
- Output thật của tsc / lint / jest.

## Quality checklist

- [ ] Route mới chỉ là file màn hình mỏng trong `src/app` (hoặc `app/` nếu dự án dùng kiểu cũ); logic ở `src/features/<feature>`.
- [ ] Package mới cài bằng `npx expo install` và chạy được trên Expo Go (nếu dự án dùng Expo Go).
- [ ] Có đủ trạng thái loading / empty / error; không crash khi offline.
- [ ] Mọi nút bấm có `accessibilityRole`/`accessibilityLabel` phù hợp.
- [ ] Có test cho logic và ít nhất 1 test render màn hình; tsc/lint/jest pass (output thật).
