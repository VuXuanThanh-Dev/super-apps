# PLAN — Bộ sách React Native (Task 3)

## Mục tiêu (Goal)
Viết bộ sách tiếng Việt về React Native, từ cơ bản đến nâng cao, cho Nobin —
một senior Angular developer chưa làm app mobile, test trên iPhone bằng Expo Go.
Mỗi tập kết thúc bằng một app mẫu chạy được trong Expo Go, có type-check, lint, test.

## Cấu trúc thư mục
```
books/react-native/
  PLAN.md  PROGRESS.md  STACK.md  GLOSSARY.md  README.md
  scripts/check-all.sh        # chạy tsc + eslint + jest (+ expo export web) cho cả 3 tập
  scripts/build-pdf.mjs       # Markdown -> HTML (pandoc) -> PDF (Playwright Chromium)
  vol1-co-ban/                # Tập 1
    NN-*.md                   # các chương
    examples/                 # MỘT dự án Expo: app mẫu + code từng chương (src/chapters/chNN) + test
  vol2-trung-cap/  (giống trên)
  vol3-nang-cao/   (giống trên)
  dist/                       # 3 file PDF
```
Quyết định: mỗi tập dùng một dự án Expo duy nhất cho mọi ví dụ (tiết kiệm cài đặt,
mọi đoạn code đều được tsc/eslint/jest kiểm tra). Màn hình "Lab" trong app cho phép
mở từng ví dụ của từng chương trên Expo Go.

## Mục lục (Table of contents)

### Tập 1 — Cơ bản
1. Cài đặt và dự án đầu tiên (Expo, Expo Go trên iPhone)
2. React Native cho Angular developer (bảng đối chiếu: component, service/DI, RxJS/Signals, routing, forms, testing)
3. Component, JSX, props, state và các core component
4. Styling và Flexbox
5. Danh sách: FlatList, SectionList
6. Form và nhập liệu
7. Điều hướng (navigation) với Expo Router
8. App mẫu Tập 1: "Việc Cần Làm" (task list: tabs, list, form, detail)

### Tập 2 — Trung cấp
1. Quản lý state: useReducer, Context, Zustand
2. Lấy dữ liệu (data fetching): fetch, TanStack Query
3. Lưu trữ offline: AsyncStorage, expo-sqlite
4. Animation: Animated API, Reanimated
5. Device APIs: haptics, location, image picker, quyền (permissions)
6. Testing: jest-expo, React Native Testing Library
7. App mẫu Tập 2: app đọc bài viết có cache offline, yêu thích, haptics

### Tập 3 — Nâng cao
1. New Architecture: JSI, Fabric, TurboModules, Codegen, Hermes
2. Native modules với Expo Modules API
3. Performance
4. Security
5. CI/CD (GitHub Actions + EAS)
6. Phát hành App Store / Play Store
7. Monitoring: error boundary, logging, Sentry
8. App mẫu Tập 3: "Sổ ghi chú bảo mật" (secure store, error boundary, performance)

Cấu trúc mỗi chương: Mục tiêu → Giải thích đơn giản → Ví dụ → Đi sâu →
Lỗi và bẫy thường gặp → Tóm tắt → Bài tập (có lời giải) → Nguồn tham khảo.

## Milestones
- M1 — Nghiên cứu + STACK.md (phiên bản có trích dẫn)
- M2 — Kế hoạch 3 tập (PLAN.md này + khung README, GLOSSARY) + mục Angular → RN
- M3 — Tập 1 (chương + app mẫu + check)
- M4 — Tập 2
- M5 — Tập 3
- M6 — 3 PDF + kiểm tra dấu tiếng Việt + link checker + PR hoàn chỉnh

## Definition of Done (copy từ task)
- [x] STACK.md with cited, pinned versions
- [x] 3 volumes; every chapter has runnable code and an exercise with solution
- [x] Angular → React Native section
- [x] 3 example apps pass type-check, lint, and tests
- [x] 3 PDFs with correct Vietnamese accents

(Bằng chứng: xem PROGRESS.md và `logs/`.)
