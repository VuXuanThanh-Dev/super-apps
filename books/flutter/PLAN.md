# PLAN — Bộ sách Flutter (Task 8)

## Mục tiêu (Goal)
Viết bộ sách tiếng Việt về Flutter, từ cơ bản đến nâng cao, cho Nobin — senior Angular developer,
đã học React Native (`books/react-native/`), test trên iPhone.
Sách phải dạy **đúng những gì app TOEIC Flutter (Task 9) cần**: SQLite offline, text-to-speech,
thông báo cục bộ (local notifications), điều hướng, quản lý state, theme/dark mode, test.
Mỗi tập kết thúc bằng một app mẫu hoàn chỉnh; `flutter analyze` 0 issue, `flutter test` pass,
`flutter build web` OK.

## Bám sát tài liệu chính thức (yêu cầu của Nobin, 2026-09-30)
Nobin: "nhớ bám sát nội dung của trang chủ" → sách đi theo **docs.flutter.dev**:
- Thứ tự Tập 1–2 theo **Flutter Learning Pathway** chính thức (`learn/pathway`): cài đặt → Dart →
  widget → layout → DevTools → nhập liệu → StatefulWidget → animation ngầm → HTTP → ChangeNotifier →
  ListenableBuilder → adaptive layout → slivers → navigation.
- Kiến trúc theo **app-architecture** chính thức: UI layer (View + ViewModel/MVVM), data layer
  (Repository + Service), Command, Result, offline-first, DI bằng `provider`, điều hướng bằng `go_router`.
- State theo **data-and-backend/state-mgmt**: setState (ephemeral) → ChangeNotifier/ListenableBuilder → `provider`.
- Mục "Flutter cho Angular (và React Native) developer" dựa trên `flutter-for/web-devs`,
  `flutter-for/react-native-devs`, `flutter-for/declarative`.
- Package docs không nhắc tên (ví dụ `flutter_tts`, `flutter_local_notifications`) được ghi rõ là
  "lựa chọn của sách, docs không nêu tên" trong STACK.md.
- Nguồn: mã nguồn docs tại repo `flutter/website`, commit ghim
  `ab59c614e780e2d6d44f07ae4a96238028f581a5` (2026-09-30), thư mục `sites/docs/src/content/`
  (docs.flutter.dev bị chặn trong sandbox). Mỗi chương trích cả URL docs.flutter.dev và file nguồn ở commit ghim.
  License repo: nội dung CC BY 3.0, code mẫu BSD ("Except as otherwise noted") — sách viết lại bằng lời
  của mình (paraphrase), chỉ trích ngắn, ghi công đầy đủ.

### Bảng đối chiếu: mục docs chính thức → chương trong sách

| Mục docs.flutter.dev (file trong `sites/docs/src/content/`) | Chương |
|---|---|
| `learn/pathway/quick-install`, `install/`, `platform-integration/ios/setup`, `platform-integration/web/building` | T1-Ch1 |
| `learn/pathway/tutorial/create-an-app`, `learn/pathway/tutorial/devtools`, `tools/devtools/` | T1-Ch1 |
| `flutter-for/web-devs`, `flutter-for/react-native-devs`, `flutter-for/declarative` | T1-Ch2 |
| Dart: `dart.dev/language` (repo `dart-lang/site-www`), Dart tutorial (bước 2 của pathway), `ui/dot-shorthands` | T1-Ch3 |
| `learn/pathway/tutorial/widget-fundamentals`, `learn/pathway/tutorial/stateful-widget`, `ui/index`, `ui/interactivity/` | T1-Ch4 |
| `learn/pathway/tutorial/layout`, `ui/layout/`, `ui/layout/constraints`, `cookbook/design/themes`, `learn/pathway/tutorial/adaptive-layout`, `ui/adaptive-responsive/` | T1-Ch5 |
| `cookbook/lists/`, `learn/pathway/tutorial/slivers`, `ui/layout/scrolling/` | T1-Ch6 |
| `learn/pathway/tutorial/user-input`, `cookbook/forms/` | T1-Ch7 |
| `ui/navigation/`, `learn/pathway/tutorial/navigation`, `cookbook/navigation/` | T1-Ch8 |
| `data-and-backend/state-mgmt/` (intro, ephemeral-vs-app, simple, options), `learn/pathway/tutorial/change-notifier`, `learn/pathway/tutorial/listenable-builder` | T2-Ch1 |
| Dart async/streams/isolates (`dart-lang/site-www`), `perf/isolates` | T2-Ch2 |
| `learn/pathway/tutorial/http-requests`, `cookbook/networking/`, `data-and-backend/networking`, `data-and-backend/serialization/json` | T2-Ch3 |
| `cookbook/persistence/` (key-value, sqlite), `data-and-backend/persistence/`, `app-architecture/design-patterns/{sql,key-value-data,offline-first}` | T2-Ch4 |
| `learn/pathway/tutorial/implicit-animations`, `ui/animations/` (implicit, tutorial, hero) | T2-Ch5 |
| `packages-and-plugins/using-packages` + package flutter_tts, flutter_local_notifications (docs không nêu tên) | T2-Ch6 |
| `testing/overview`, `cookbook/testing/` (unit, widget, integration, mocking), `testing/integration-tests/`, `app-architecture/case-study/testing` | T2-Ch7 |
| `app-architecture/` (concepts, guide, recommendations, case-study, design-patterns/{command,result}) | T3-Ch1 (và app mẫu T2, T3) |
| `perf/` (best-practices, ui-performance, isolates, app-size), `testing/build-modes`, `tools/devtools/performance` | T3-Ch2 |
| `platform-integration/platform-channels`, `packages-and-plugins/developing-packages`, `packages-and-plugins/swift-package-manager/` | T3-Ch3 |
| `security/`, `deployment/obfuscate` | T3-Ch4 |
| `deployment/cd` | T3-Ch5 |
| `deployment/ios`, `deployment/android`, `deployment/flavors` | T3-Ch6 |
| `testing/errors`, `testing/debugging`, `tools/devtools/logging` | T3-Ch7 |

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
1. Cài đặt, dự án đầu tiên, DevTools, và cách chạy trên iPhone (Mac + Xcode, hoặc web trên Safari)
2. **Flutter cho Angular (và React Native) developer** — bảng đối chiếu: component/widget,
   service/DI, RxJS/Signals ↔ Stream/ChangeNotifier/ValueNotifier, routing, forms, testing
3. Dart cho TypeScript developer (null safety, class, record, pattern, sealed, async cơ bản)
4. Widget: Stateless, Stateful, vòng đời, BuildContext, key
5. Layout, styling, theming và adaptive layout (constraints, Row/Column, Material 3, ThemeData, dark mode)
6. Danh sách và cuộn: ListView.builder, GridView, Dismissible, slivers
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
- [x] STACK.md with cited, pinned versions
- [x] 3 volumes; every chapter has runnable code and an exercise with solution
- [x] Angular/React Native → Flutter section
- [x] 3 example apps pass analyze, tests, and web build
- [x] 3 PDFs with correct Vietnamese accents

(Bằng chứng: PROGRESS.md và `logs/`. Chạy trên iPhone/Android: NOT RUN — không có thiết bị trong sandbox.)
