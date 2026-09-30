# Tập 3 — Flutter nâng cao

Kiến trúc feature-first, performance, platform channel, bảo mật, CI/CD, phát hành, monitoring. App mẫu "Sổ Ghi Chú Bảo Mật".

## Mục lục

1. [Kiến trúc: feature-first, các tầng, luật phụ thuộc](01-kien-truc-feature-first.md)
2. [Performance: đo trước, sửa sau](02-performance.md)
3. [Platform channels và plugin](03-platform-channels-va-plugin.md)
4. [Bảo mật: bí mật, PIN, tự khóa, deep link, obfuscation](04-bao-mat.md)
5. [CI/CD](05-ci-cd.md)
6. [Phát hành App Store và Google Play](06-phat-hanh-app-store-play-store.md)
7. [Monitoring: bắt lỗi, logging, crash reporting](07-monitoring.md)
8. [App mẫu "Sổ Ghi Chú Bảo Mật"](08-app-mau-so-ghi-chu-bao-mat.md)

## App mẫu: `examples/` · Workflow mẫu: `ci/`

Phiên bản (ghim exact, khóa trong `pubspec.lock`): Flutter 3.47.5, Dart 3.13.4, go_router 18.0.2, provider 6.1.5+1,
flutter_secure_storage 11.2.0, crypto 3.0.7; dev: mocktail 1.0.5, flutter_lints 6.0.0.

```bash
cd books/flutter/vol3-nang-cao/examples
flutter pub get
flutter run -d chrome     # web (secure storage cần localhost/HTTPS)
flutter run               # iPhone (Mac + Xcode)
flutter analyze && flutter test
```

- Kết quả 2026-09-30: analyze "No issues found!", **31 test pass**, build web OK, smoke web OK, YAML `ci/` hợp lệ ([../logs/](../logs/)).
- **NOT RUN:** iPhone/Android, biên dịch Swift/Kotlin (platform channel), workflow CI thật, TestFlight.
