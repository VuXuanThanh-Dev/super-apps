# Tập 2 — Flutter trung cấp

State, bất đồng bộ, HTTP, SQLite, animation, TTS + thông báo, testing — theo khuyến nghị kiến trúc chính thức
(MVVM + ChangeNotifier + provider, repository, Command/Result). App mẫu "Sổ Từ Vựng" là **bản tập dượt cho app TOEIC (Task 9)**.

## Mục lục

1. [Quản lý state: setState → ChangeNotifier → provider (MVVM)](01-quan-ly-state.md)
2. [Bất đồng bộ: Future, async/await, Stream, isolate](02-bat-dong-bo-future-stream.md)
3. [HTTP và JSON](03-http-va-json.md)
4. [Lưu trữ offline: shared_preferences và SQLite](04-luu-tru-sqlite.md)
5. [Animation: implicit, explicit, Hero](05-animation.md)
6. [Device APIs: đọc to (TTS) và thông báo cục bộ](06-device-apis-tts-thong-bao.md)
7. [Testing: unit, widget, integration; fake và mock](07-testing.md)
8. [App mẫu "Sổ Từ Vựng"](08-app-mau-so-tu-vung.md)

## App mẫu: `examples/`

Phiên bản (ghim exact trong `examples/pubspec.yaml`, khóa trong `pubspec.lock`): Flutter 3.47.5, Dart 3.13.4,
provider 6.1.5+1, go_router 18.0.2, sqflite 2.4.4, sqflite_common_ffi_web 1.2.0, sqlite3 3.6.0, path 1.9.1,
shared_preferences 2.5.5, http 1.6.0, flutter_tts 4.2.5, flutter_local_notifications 22.3.1, timezone 0.11.1,
flutter_timezone 5.1.0; dev: sqflite_common_ffi 2.4.3, mocktail 1.0.5, flutter_lints 6.0.0, integration_test (SDK).

```bash
cd books/flutter/vol2-trung-cap/examples
flutter pub get
flutter run -d chrome     # web
flutter run               # iPhone (Mac + Xcode)
flutter analyze && flutter test
bash ../../scripts/integration-web.sh vol2-trung-cap   # integration test trên Chrome headless
```

- Tab **Từ vựng** (tìm có/không dấu, yêu thích, phát âm), **Ôn tập** (thẻ lật), **Lab** (ví dụ từng chương), **Cài đặt**
  (theme, nhắc hằng ngày, tốc độ đọc).
- Kết quả 2026-09-30: analyze "No issues found!", **51 test pass**, build web OK, smoke web OK, integration test web pass
  ([../logs/](../logs/)).
- **Chạy trên iPhone/Android: NOT RUN** (không có thiết bị trong sandbox).
