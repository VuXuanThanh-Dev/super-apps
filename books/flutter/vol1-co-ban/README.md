# Tập 1 — Flutter cơ bản

Dành cho developer đã biết TypeScript/Angular (và đã xem React Native), chưa làm Flutter. Thứ tự chương đi theo
**Flutter Learning Pathway** chính thức (xem bảng đối chiếu trong [../PLAN.md](../PLAN.md)).

## Mục lục

1. [Cài đặt, app đầu tiên và chạy trên iPhone](01-cai-dat-va-app-dau-tien.md)
2. [Flutter cho Angular (và React Native) developer](02-flutter-cho-angular-va-react-native-developer.md) ← bảng đối chiếu
3. [Dart cho TypeScript developer](03-dart-cho-typescript-developer.md)
4. [Widget: Stateless, Stateful, vòng đời, BuildContext](04-widget-stateless-stateful.md)
5. [Layout, styling, theming và adaptive layout](05-layout-styling-theming.md)
6. [Danh sách và cuộn](06-danh-sach-va-cuon.md)
7. [Form và nhập liệu](07-form-va-nhap-lieu.md)
8. [Điều hướng: Navigator và go_router](08-dieu-huong-go-router.md)
9. [App mẫu "Việc Cần Làm"](09-app-mau-viec-can-lam.md)

## App mẫu và code ví dụ: `examples/`

Phiên bản: Flutter 3.47.5, Dart 3.13.4, go_router 18.0.2, cupertino_icons 1.0.9, flutter_lints 6.0.0
(ghim exact trong `examples/pubspec.yaml`, khóa trong `pubspec.lock`).

### Chạy

```bash
cd books/flutter/vol1-co-ban/examples
flutter pub get
flutter run -d chrome     # trình duyệt Chrome
flutter run               # iPhone cắm vào Mac (cần Xcode; Apple ID miễn phí đủ để test)
```

- Tab **Việc cần làm**: app mẫu. Tab **Lab**: ví dụ từng chương. Tab **Cài đặt**: sáng / tối / theo hệ thống.
- **Chạy trên iPhone/Android: NOT RUN** (sandbox không có Mac/Xcode/Android SDK). Không có Mac → dùng bản web trên
  Safari: xem [Chương 1](01-cai-dat-va-app-dau-tien.md).

### Kiểm tra

```bash
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
```

Hoặc từ gốc repo: `bash books/flutter/scripts/check-all.sh vol1-co-ban`.
Kết quả ngày 2026-09-30: format OK, analyze "No issues found!", **58 test pass**, build web OK, smoke test web OK
([../logs/check-all.txt](../logs/check-all.txt)).

### Cấu trúc

```text
examples/lib/
  main.dart app.dart theme.dart router.dart
  features/tasks/      model thuần + TaskStore (ChangeNotifier)
  screens/             màn hình của app mẫu
  lab/                 tab Lab
  chapters/chNN/       ví dụ + lời giải bài tập từng chương
examples/test/         test từng chương, test model/store, test toàn app (app_test.dart)
```
