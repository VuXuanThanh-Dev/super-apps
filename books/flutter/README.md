# Bộ sách Flutter — từ cơ bản đến nâng cao (tiếng Việt)

Dành cho **Angular developer** (đã học React Native trong [books/react-native/](../react-native/README.md))
muốn làm app mobile bằng **Flutter**, test trên **iPhone**. Sách bám sát tài liệu chính thức
**docs.flutter.dev** (Learning Pathway, App architecture, State management — xem bảng đối chiếu trong [PLAN.md](PLAN.md)).
Markdown là nguồn chính; PDF được build bằng script.

| Tập | Nội dung | Markdown | PDF | App mẫu |
|---|---|---|---|---|
| 1 — Cơ bản | Cài đặt, **Flutter cho Angular/RN developer**, Dart cho TypeScript dev, widget, layout/theme/dark mode, danh sách, form, go_router | [vol1-co-ban/](vol1-co-ban/README.md) | [dist/Flutter-Tap1-Co-Ban.pdf](dist/Flutter-Tap1-Co-Ban.pdf) | "Việc Cần Làm" |
| 2 — Trung cấp | State (ChangeNotifier + provider, MVVM), async/Stream, HTTP + JSON, SQLite, animation, TTS + thông báo, testing | [vol2-trung-cap/](vol2-trung-cap/README.md) | [dist/Flutter-Tap2-Trung-Cap.pdf](dist/Flutter-Tap2-Trung-Cap.pdf) | "Sổ Từ Vựng" |
| 3 — Nâng cao | Kiến trúc feature-first, performance, platform channel, bảo mật, CI/CD, phát hành, monitoring | [vol3-nang-cao/](vol3-nang-cao/README.md) | [dist/Flutter-Tap3-Nang-Cao.pdf](dist/Flutter-Tap3-Nang-Cao.pdf) | "Sổ Ghi Chú Bảo Mật" |

- Phiên bản và lý do chọn package: [STACK.md](STACK.md) (Flutter 3.47.5, Dart 3.13.4). **App TOEIC (Task 9) dùng đúng bảng ở STACK.md mục 5.**
- Thuật ngữ: [GLOSSARY.md](GLOSSARY.md). Kế hoạch: [PLAN.md](PLAN.md). Tiến độ: [PROGRESS.md](PROGRESS.md).
- Bắt đầu nhanh cho Angular dev: [Tập 1, Chương 2](vol1-co-ban/02-flutter-cho-angular-va-react-native-developer.md).

## Phiên bản công cụ (ghim chính xác)

| Công cụ | Phiên bản |
|---|---|
| Flutter SDK | 3.47.5 (stable, 2026-09-18) |
| Dart SDK | 3.13.4 |
| DevTools | 2.60.0 |
| Xcode / Android Studio | Không có trong sandbox (dùng bản mới nhất trên máy của bạn) |
| pandoc (build PDF) | 3.1.3 |
| Node / playwright-core / mermaid (PDF, smoke test web) | 22.22.2 / 1.56.1 / 12.0.0 |

Phiên bản package từng app nằm trong `vol*/examples/pubspec.yaml` (ghim exact) + `pubspec.lock` (đã commit).

## Chạy một app

```bash
cd books/flutter/vol1-co-ban/examples     # hoặc vol2-trung-cap / vol3-nang-cao
flutter pub get
flutter run -d chrome                     # chạy trên Chrome (máy tính)
flutter run                               # chạy trên iPhone cắm cáp (cần Mac + Xcode)
```

**Không có "Expo Go" cho Flutter.** Muốn chạy app native trên iPhone cần **Mac + Xcode** (Apple ID miễn phí đủ
để test trên máy của mình). Không có Mac: chạy **bản web trên Safari** của iPhone. Chi tiết và các bước:
[STACK.md mục 4](STACK.md) và [Tập 1, Chương 1](vol1-co-ban/01-cai-dat-va-app-dau-tien.md).
**Chạy trên iPhone/Android: NOT RUN** (sandbox không có Mac, Xcode, Android SDK, thiết bị).

## Kiểm tra toàn bộ (format, analyze, test, build web, smoke test)

```bash
(cd books/flutter/scripts && npm ci)          # một lần: Playwright + mermaid cho smoke test và PDF
bash books/flutter/scripts/check-all.sh       # cả 3 tập
bash books/flutter/scripts/check-all.sh vol1-co-ban
```

Kết quả ngày 2026-09-30 (log: [logs/check-all.txt](logs/check-all.txt)):

| Tập | format | analyze | test | build web | smoke web (Chromium) |
|---|---|---|---|---|---|
| 1 | OK | No issues found! | 58 pass | OK | OK |
| 2 | OK | No issues found! | 51 pass (+ integration test trên Chrome: pass, [logs/integration-web-vol2.txt](logs/integration-web-vol2.txt)) | OK | OK (SQLite Wasm chạy) |
| 3 | OK (+ YAML ci/ OK) | No issues found! | 31 pass | OK | OK |

PDF: 87 + 65 + 58 trang ([logs/build-pdf.txt](logs/build-pdf.txt)); dấu tiếng Việt OK ([logs/check-pdf-accents.txt](logs/check-pdf-accents.txt));
link: 282 link, 0 hỏng, 116 bị sandbox chặn (docs.flutter.dev, dart.dev, api.dictionaryapi.dev — bản nguồn trên GitHub đã kiểm tra OK)
([logs/check-links.txt](logs/check-links.txt)).

## Build PDF

```bash
cd books/flutter/scripts
npm ci
node build-pdf.mjs            # → ../dist/*.pdf (pandoc → HTML → Chromium; Mermaid vẽ trong trang)
bash check-pdf-accents.sh     # pdftotext: kiểm tra ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ
python3 check-links.py        # kiểm tra link (host bị chặn được báo riêng)
```

Font: Noto Serif (chữ), Noto Sans (tiêu đề), Noto Sans Mono (code), Noto Color Emoji.

## Cấu trúc

```text
books/flutter/
  README.md PLAN.md PROGRESS.md STACK.md GLOSSARY.md .gitignore
  vol1-co-ban/     01..09-*.md  examples/ (dự án Flutter: app mẫu + lib/chapters/chNN + test/)
  vol2-trung-cap/  01..08-*.md  examples/
  vol3-nang-cao/   01..08-*.md  examples/  ci/ (workflow mẫu)
  scripts/         check-all.sh  web-smoke.mjs  integration-web.sh  build-pdf.mjs  check-pdf-accents.sh  check-links.py
  dist/            3 PDF
  logs/            output thật của các lần kiểm tra
```

## Bản quyền

Nội dung sách do tác giả tự viết. Tham khảo docs Flutter (repo `flutter/website`: nội dung CC BY 3.0, code
mẫu BSD) và docs Dart (repo `dart-lang/site-www`: nội dung CC BY 4.0, code mẫu BSD-3-Clause); mọi chương ghi
nguồn ở cuối. Xem [STACK.md mục 7](STACK.md).
