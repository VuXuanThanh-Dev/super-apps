# Chương 1 — Cài đặt, app đầu tiên và chạy trên iPhone

## Mục tiêu

- Cài Flutter SDK (Dart đi kèm), kiểm tra bằng `flutter doctor`.
- Tạo và chạy app đầu tiên; dùng **hot reload**.
- Hiểu cấu trúc một dự án Flutter (`lib/`, `test/`, `pubspec.yaml`, `ios/`, `android/`, `web/`).
- Biết **thật rõ** các cách chạy app trên iPhone: Mac + Xcode, hoặc bản web trên Safari.
- Biết DevTools là gì.

## Giải thích đơn giản

Flutter giống **Angular CLI + một engine vẽ**: bạn viết Dart, lệnh `flutter` biên dịch và chạy trên
thiết bị. Khác React Native + Expo: **không có app "Expo Go"** để quét QR. Muốn chạy trên iPhone thật,
app phải được **build bằng Xcode trên máy Mac** rồi cài qua cáp (hoặc qua TestFlight). Nếu chưa có Mac,
bạn vẫn học được toàn bộ sách bằng cách chạy trên **Chrome** (máy tính) và mở **bản web trên Safari** của iPhone.

| Việc | Angular | React Native (Expo) | Flutter |
|---|---|---|---|
| Tạo dự án | `ng new` | `npx create-expo-app` | `flutter create` |
| Chạy dev | `ng serve` | `npx expo start` | `flutter run -d chrome` / `flutter run` |
| Cập nhật khi lưu | HMR | Fast Refresh | **Hot reload** (`r`), hot restart (`R`) |
| Cài package | `npm i x` | `npx expo install x` | `flutter pub add x` |
| Kiểm tra môi trường | — | `npx expo-doctor` | `flutter doctor` |

## Ví dụ

### Bước 1 — Cài Flutter

Docs chính thức (Learning Pathway, bước "Quick install") hướng dẫn cài bằng VS Code + extension Flutter,
hoặc tải SDK thủ công. Cài Flutter là có Dart. Sách dùng **Flutter 3.47.5** (stable, 2026-09-18) — xem [STACK.md](../STACK.md).

Trên macOS/Linux, cách thủ công (sandbox của sách làm đúng như vậy):

```bash
# Linux (bản đã dùng để kiểm tra sách):
curl -sS -o /tmp/f.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.5-stable.tar.xz
tar xf /tmp/f.tar.xz -C /opt
export PATH=/opt/flutter/bin:$PATH
flutter --version
```

Kết quả thật (sandbox, 2026-09-30):

```text
Flutter 3.47.5 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 6a19cca564 (13 days ago) • 2026-09-17 14:13:22 -0400
Engine • hash ab598368592da0064197e2bc15c7f5b0a2c6bb1f (revision af7e796e16) (13 days ago) • 2026-09-16 18:35:09.000Z
Tools • Dart 3.13.4 • DevTools 2.60.0
```

Trên Mac, nên dùng VS Code → Command Palette → "Flutter: New Project" như docs; extension sẽ tải SDK giúp bạn.

### Bước 2 — `flutter doctor`

`flutter doctor` liệt kê cái gì còn thiếu. Kết quả thật trong sandbox (không có Android SDK, Chrome, Xcode):

```text
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.47.5, on Ubuntu 24.04.4 LTS 6.18.44-fc-v50, locale en_US)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
[✗] Chrome - develop for the web (Cannot find Chrome executable at google-chrome)
    ! Cannot find Chrome. Try setting CHROME_EXECUTABLE to a Chrome executable.
[✗] Linux toolchain - develop for Linux desktop
[✓] Connected device (1 available)
[✓] Network resources

! Doctor found issues in 3 categories.
```

(Đã rút gọn vài dòng gợi ý.) Trên Mac của bạn, mục **Xcode** sẽ xuất hiện; cần nó xanh (✓) thì mới chạy được trên iPhone.
Không cần mọi mục đều xanh: chỉ cần nền tảng bạn định chạy.

### Bước 3 — Tạo và chạy app

```bash
flutter create --org dev.nobin --platforms=ios,android,web hello_flutter
cd hello_flutter
flutter run -d chrome        # mở Chrome
# khi app đang chạy: sửa code, lưu, bấm r (hot reload) hoặc R (hot restart), q để thoát
```

`--org` đặt tiền tố bundle id cho iOS/Android (`dev.nobin.hello_flutter`). Dự án của sách tạo đúng bằng lệnh
này (xem `examples/`).

App đầu tiên của sách — bộ đếm tiếng Việt (`examples/lib/chapters/ch01/hello_counter.dart`):

```dart
class HelloCounter extends StatefulWidget {
  const HelloCounter({super.key, this.step = 1});

  final int step;

  @override
  State<HelloCounter> createState() => _HelloCounterState();
}

class _HelloCounterState extends State<HelloCounter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Xin chào Flutter!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text('Bạn đã bấm $_count lần'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => setState(() => _count += widget.step),
            icon: const Icon(Icons.add),
            label: const Text('Bấm tôi'),
          ),
        ],
      ),
    );
  }
}
```

Đọc nhanh (Chương 4 giải thích kỹ):
- `StatefulWidget` = widget có state. State nằm ở class `_HelloCounterState` (dấu `_` = private trong file).
- `setState(() => ...)` báo Flutter: "state đổi rồi, gọi lại `build`".
- `widget.step` = đọc tham số của widget (giống `this.step` của một `@Input`).

Điểm vào app (`examples/lib/main.dart`):

```dart
void main() {
  runApp(const TodoApp());
}
```

### Bước 4 — Test đầu tiên

```dart
testWidgets('HelloCounter tăng theo step khi bấm', (tester) async {
  await pumpApp(tester, const HelloCounter(step: 2));
  expect(find.text('Bạn đã bấm 0 lần'), findsOneWidget);
  await tester.tap(find.text('Bấm tôi'));
  await tester.pump(); // build lại sau setState
  expect(find.text('Bạn đã bấm 2 lần'), findsOneWidget);
});
```

`pumpApp` là hàm nhỏ của sách (`examples/test/helpers.dart`) bọc widget trong `MaterialApp` + `Scaffold`.
Kết quả thật (2026-09-30, `flutter test --reporter expanded test/chapters/ch01_test.dart`):

```text
00:00 +0: Chương 1 — app đầu tiên HelloCounter tăng theo step khi bấm
00:00 +1: Chương 1 — app đầu tiên Bài tập: nút Đặt lại bị vô hiệu khi = 0 và đưa về 0
00:00 +2: All tests passed!
```

### Bước 5 — Chạy app mẫu của sách

```bash
cd books/flutter/vol1-co-ban/examples
flutter pub get
flutter analyze            # kết quả thật: No issues found!
flutter test               # kết quả thật: 58 test, All tests passed!
flutter run -d chrome
```

Tab **Lab** mở ví dụ của từng chương. Toàn bộ kết quả kiểm tra: [../logs/check-all.txt](../logs/check-all.txt).

## Đi sâu

### Chạy trên iPhone: 3 con đường thật

**A. Mac + Xcode + cáp (cách chính thức).** Theo docs `platform-integration/ios/setup`:

1. Cài Xcode; chạy `sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'`,
   `sudo xcodebuild -license`, `xcodebuild -downloadPlatform iOS`.
2. Cắm iPhone vào Mac, bấm **Trust** (Tin cậy).
3. Bật **Developer Mode**: Settings → Privacy & Security → Developer Mode → On → khởi động lại → Turn On.
   (Nếu không thấy mục này: cắm máy, mở Xcode hoặc chạy `flutter run` một lần.)
4. Tạo chứng chỉ ký bằng Apple ID. Docs viết: tài khoản developer **cá nhân, miễn phí** dùng được khi chỉ
   *test* trên máy của mình; muốn lên App Store thì cần tài khoản trả phí.
5. Trên iPhone: Settings → VPN & Device Management → chọn chứng chỉ developer → **Trust**.
6. `flutter run` (chọn iPhone). Hot reload chạy được trên máy thật.

Từ Flutter 3.44, phụ thuộc native iOS được quản lý bằng **Swift Package Manager** (mặc định); CocoaPods chỉ
còn dùng cho plugin chưa hỗ trợ SwiftPM (docs `swift-package-manager/for-app-developers`).

**UNVERIFIED:** bản cài bằng Apple ID miễn phí hết hạn sau 7 ngày (cộng đồng hay nói; chưa mở được trang Apple xác nhận).

**B. Bản web trên Safari (không cần Mac).** Flutter web chạy trên Safari mobile (docs `web/faq`):

```bash
cd books/flutter/vol1-co-ban/examples
flutter build web --no-web-resources-cdn --release
cd build/web && python3 -m http.server 8080 --bind 0.0.0.0
# iPhone cùng Wi-Fi: Safari → http://<IP-máy-tính>:8080 → Chia sẻ → "Thêm vào MH chính"
```

- Không dùng `--wasm` cho iPhone: docs `web/wasm` nói bản Wasm không chạy trên trình duyệt nào của iOS.
- Web **không phải app native**: không có thông báo cục bộ theo lịch, giọng đọc TTS dùng Web Speech của Safari.
- Trong sandbox, sách đã kiểm tra bản web bằng Chromium headless (script `scripts/web-smoke.mjs`); trên Safari iOS: **NOT RUN**.

**C. TestFlight.** Build trên Mac (hoặc Mac trên cloud CI), upload lên App Store Connect, cài bằng app TestFlight.
Cần **Apple Developer Program ($99/năm** — trang developer.apple.com/programs, mở 2026-09-30). Tập 3 Ch.5–6.

### Cấu trúc dự án

```text
examples/
  pubspec.yaml         # tên app, phiên bản, phụ thuộc (≈ package.json)
  pubspec.lock         # khóa phiên bản (≈ package-lock.json) — commit với app
  analysis_options.yaml# luật lint (≈ eslint config)
  lib/main.dart        # điểm vào
  lib/...              # code Dart của bạn
  test/                # test (chạy bằng flutter test)
  ios/ android/ web/   # dự án native / web do flutter create sinh ra
```

### Hot reload hoạt động thế nào?

Ở chế độ debug, Dart chạy bằng **JIT** (biên dịch lúc chạy) nên có thể nạp code mới vào app đang chạy mà
giữ state. Bản release dùng **AOT** (biên dịch trước ra mã máy) nên nhanh hơn nhưng không hot reload. Docs
`testing/build-modes` mô tả 3 chế độ: debug, profile, release.

### DevTools

`flutter run` in ra một đường link DevTools. DevTools có: **Widget Inspector** (xem cây widget, giống
Angular DevTools), **Performance**, **CPU profiler**, **Memory**, **Network**, **Logging**. Learning Pathway có
một bài riêng về DevTools; sách dùng lại ở Tập 3 (Performance).

## Lỗi và bẫy thường gặp

- **Tưởng có "Expo Go cho Flutter"** — không có. Cần Mac + Xcode cho app native trên iPhone.
- **`flutter doctor` đỏ hết rồi hoảng**: chỉ cần nền tảng bạn dùng xanh.
- **Chạy với quyền root** in cảnh báo "Woah! You appear to be trying to run flutter as root" — vô hại trong
  sandbox, nhưng trên máy cá nhân đừng dùng `sudo flutter`.
- **Quên `flutter pub get`** sau khi clone → lỗi "Target of URI doesn't exist".
- **Hot reload không áp dụng** khi sửa `main()` hoặc `initState` — dùng hot restart (`R`).
- **Web trắng trang khi mạng bị chặn**: mặc định Flutter web tải CanvasKit từ CDN; dùng `--no-web-resources-cdn`.

## Tóm tắt

- Cài Flutter = có Dart. Kiểm tra bằng `flutter doctor`. Sách ghim Flutter 3.47.5 / Dart 3.13.4.
- `flutter create` → `flutter run -d chrome` → sửa code → `r` hot reload.
- iPhone: Mac + Xcode (Apple ID miễn phí để test), hoặc bản web trên Safari, hoặc TestFlight (trả phí).
- Mọi code của sách nằm trong `examples/` và được `flutter analyze` + `flutter test` kiểm tra.

## Bài tập (có lời giải)

**Bài 1.** Viết widget `CounterWithReset`: nút "+1" và nút "Đặt lại". Nút "Đặt lại" bị **vô hiệu** khi bộ đếm = 0.

<details>
<summary>Lời giải</summary>

`examples/lib/chapters/ch01/exercise_solution.dart` (đoạn chính):

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    FilledButton(onPressed: () => setState(() => _count++), child: const Text('+1')),
    const SizedBox(width: 8),
    // onPressed = null → nút tự vô hiệu (disabled). Không cần thuộc tính [disabled] riêng.
    OutlinedButton(
      onPressed: _count == 0 ? null : () => setState(() => _count = 0),
      child: const Text('Đặt lại'),
    ),
  ],
),
```

Test kiểm tra `onPressed` là `null` lúc đầu, bấm "+1" hai lần rồi "Đặt lại" về 0 (`ch01_test.dart`).
Trong Angular bạn viết `[disabled]="count === 0"`; trong Flutter, "vô hiệu" = không có hàm xử lý.
</details>

**Bài 2.** Bạn không có Mac. Liệt kê các lệnh để Nobin mở app Tập 1 trên iPhone, và nói 2 giới hạn của cách đó.

<details>
<summary>Lời giải</summary>

```bash
cd books/flutter/vol1-co-ban/examples
flutter build web --no-web-resources-cdn --release
cd build/web && python3 -m http.server 8080 --bind 0.0.0.0
# iPhone cùng Wi-Fi → Safari → http://<IP máy tính>:8080
```

Giới hạn: (1) đây là web, không phải app native — không có thông báo cục bộ theo lịch, không truy cập đủ
API thiết bị; (2) không dùng được `--wasm` trên iOS. Lệnh build web đã chạy thật trong sandbox
(`logs/check-all.txt`: "✓ Built build/web" và "WEB SMOKE OK"); mở trên Safari iOS: NOT RUN.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30 (docs.flutter.dev bị chặn trong sandbox; đọc file nguồn ở commit `ab59c61`):

- Learning pathway — https://docs.flutter.dev/learn/pathway —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/learn/pathway/index.md
- Quick install / test drive — https://docs.flutter.dev/install/quick —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/install/quick.md
- Tutorial: Create a Flutter app — https://docs.flutter.dev/learn/pathway/tutorial/create-an-app —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/learn/pathway/tutorial/create-an-app.md
- Tutorial: DevTools — https://docs.flutter.dev/learn/pathway/tutorial/devtools —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/learn/pathway/tutorial/devtools.md
- Set up iOS development — https://docs.flutter.dev/platform-integration/ios/setup —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/platform-integration/ios/setup.md
- Swift Package Manager for app developers — https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/packages-and-plugins/swift-package-manager/for-app-developers.md
- Building a web application — https://docs.flutter.dev/platform-integration/web/building —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/platform-integration/web/building.md
- Web FAQ — https://docs.flutter.dev/platform-integration/web/faq —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/platform-integration/web/faq.md
- Wasm — https://docs.flutter.dev/platform-integration/web/wasm —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/platform-integration/web/wasm.md
- Build modes — https://docs.flutter.dev/testing/build-modes —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/testing/build-modes.md
- Flutter releases (Linux): https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json
- Apple Developer Program: https://developer.apple.com/programs/
