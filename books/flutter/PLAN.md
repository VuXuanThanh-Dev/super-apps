# PLAN — Bộ sách Flutter (Task 8)

## Mục tiêu (Goal)
Viết bộ sách tiếng Việt về Flutter, từ cơ bản đến nâng cao, cho Nobin — senior Angular developer,
đã học React Native (`books/react-native/`), test trên iPhone.
Sách phải dạy **đúng những gì app TOEIC Flutter (Task 9) cần**: SQLite offline, text-to-speech,
thông báo cục bộ (local notifications), điều hướng, quản lý state, theme/dark mode, test.
Mỗi tập kết thúc bằng một app mẫu hoàn chỉnh; `flutter analyze` 0 issue, `flutter test` pass,
`flutter build web` OK.

## Cấu trúc thư mục (giống `books/react-native/`)
```
books/flutter/
  PLAN.md  PROGRESS.md  STACK.md  GLOSSARY.md  README.md  .gitignore
  scripts/check-all.sh        # pub get + analyze + test + build web cho cả 3 tập
  scripts/web-smoke.mjs       # mở bản build web trong Chromium headless, kiểm tra app chạy
  scripts/build-pdf.mjs       # Markdown -> HTML (pandoc) -> PDF (Playwright Chromium) + Mermaid
  scripts/check-pdf-accents.sh  scripts/check-links.py
  vol1-co-ban/                # Tập 1
    NN-*.md                   # các chương
    examples/                 # MỘT dự án Flutter: app mẫu + code từng chương (lib/chapters/chNN) + test
  vol2-trung-cap/  (giống trên)
  vol3-nang-cao/   (giống trên, + ci/ workflow mẫu)
  dist/                       # 3 file PDF
  logs/                       # output thật của các lần kiểm tra
```
Quyết định: mỗi tập = một dự án Flutter duy nhất (`flutter create --platforms=ios,android,web`).
Màn hình "Lab" trong app mở ví dụ của từng chương. Mọi đoạn code trong sách lấy từ dự án này,
nên đều được `flutter analyze` + `flutter test` kiểm tra.

## Mục lục (Table of contents)

### Tập 1 — Cơ bản (app mẫu: "Việc Cần Làm")
1. Cài đặt, dự án đầu tiên, và cách chạy trên iPhone (Mac + Xcode, hoặc web trên Safari)
2. **Flutter cho Angular (và React Native) developer** — bảng đối chiếu: component/widget,
   service/DI, RxJS/Signals ↔ Stream/ChangeNotifier/ValueNotifier, routing, forms, testing
3. Dart cho TypeScript developer (null safety, class, record, pattern, sealed, async cơ bản)
4. Widget: Stateless, Stateful, vòng đời, BuildContext, key
5. Layout, styling và theming (Row/Column/Flex, Material 3, ThemeData, dark mode)
6. Danh sách: ListView.builder, GridView, separated, Dismissible
7. Form và nhập liệu (Form, TextFormField, validator, controller)
8. Điều hướng: Navigator và go_router (tham số, tab với ShellRoute, redirect)
9. App mẫu Tập 1: "Việc Cần Làm" (tabs, list, form, detail, dark mode)

### Tập 2 — Trung cấp (app mẫu: "Sổ Từ Vựng" — bản tập dượt cho app TOEIC)
1. Quản lý state: setState → ValueNotifier → ChangeNotifier + provider (MVVM); so sánh Riverpod, Bloc, signals
2. Bất đồng bộ: Future, async/await, Stream, FutureBuilder/StreamBuilder, isolate
3. HTTP + JSON (package http, model fromJson/toJson, lỗi mạng, test với MockClient)
4. Lưu trữ offline: shared_preferences, SQLite với sqflite (migration, repository), test bằng sqflite_common_ffi
5. Animation: implicit, explicit (AnimationController), Hero
6. Device APIs: text-to-speech (flutter_tts), thông báo cục bộ (flutter_local_notifications), quyền
7. Testing: unit, widget, integration (integration_test), fake vs mock (mocktail)
8. App mẫu Tập 2: "Sổ Từ Vựng" (SQLite offline, tìm kiếm, phát âm TTS, nhắc ôn hằng ngày, dark mode)

### Tập 3 — Nâng cao (app mẫu: "Sổ Ghi Chú Bảo Mật")
1. Kiến trúc: feature-first, data/UI layer, repository, ViewModel, Command, Result (theo khuyến nghị chính thức)
2. Performance: const, rebuild, DevTools, list lớn, isolate/compute
3. Platform channels và plugin (MethodChannel, EventChannel, Pigeon; Swift/Kotlin)
4. Bảo mật: flutter_secure_storage, PIN băm (crypto), obfuscation, deep link an toàn
5. CI/CD: GitHub Actions (analyze/test/build), workflow mẫu
6. Phát hành App Store / Play Store (signing, version, TestFlight)
7. Monitoring: FlutterError.onError, PlatformDispatcher.onError, logging, Sentry (giới thiệu)
8. App mẫu Tập 3: "Sổ Ghi Chú Bảo Mật" (feature-first, khóa PIN, secure storage, error logging)

Cấu trúc mỗi chương (rule 8): Mục tiêu → Giải thích đơn giản → Ví dụ → Đi sâu →
Lỗi và bẫy thường gặp → Tóm tắt → Bài tập (có lời giải) → Nguồn tham khảo.

## Milestones
- M1 — Nghiên cứu + STACK.md (phiên bản ghim, trích dẫn pub.dev có ngày; cách chạy trên iPhone)
- M2 — Kế hoạch 3 tập (PLAN.md này + README, GLOSSARY) + chương "Flutter cho Angular (và RN) developer"
- M3 — Tập 1 (chương + app mẫu + analyze/test/build web)
- M4 — Tập 2
- M5 — Tập 3
- M6 — 3 PDF + kiểm tra dấu tiếng Việt + link checker + PR hoàn chỉnh

## Definition of Done (copy từ task)
- [ ] STACK.md with cited, pinned versions
- [ ] 3 volumes; every chapter has runnable code and an exercise with solution
- [ ] Angular/React Native → Flutter section
- [ ] 3 example apps pass analyze, tests, and web build
- [ ] 3 PDFs with correct Vietnamese accents
