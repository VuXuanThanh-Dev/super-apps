# STACK — Phiên bản và thư viện dùng cho cả bộ sách Flutter

> Kiểm tra ngày **2026-09-30** bằng: file phát hành chính thức `releases_linux.json`,
> API của pub.dev (`https://pub.dev/api/packages/<tên>`), lệnh `flutter pub get` thật trong 3 dự án
> `vol*/examples/`, và **mã nguồn** tài liệu chính thức trên GitHub (`flutter/website`, `dart-lang/site-www`).
> Trang `docs.flutter.dev`, `api.flutter.dev`, `dart.dev` bị chặn trong sandbox, nên chúng tôi đọc file
> Markdown nguồn của các trang đó ở một commit cố định (xem "Nguồn tham khảo").
>
> **Task 9 (app TOEIC Flutter) phải dùng đúng bảng ở mục 5.**

## 1. Tóm tắt nhanh (TL;DR)

| Thành phần | Phiên bản ghim (pinned) | Vì sao |
|---|---|---|
| Flutter SDK | **3.47.5** (kênh stable, phát hành 2026-09-18) | Bản stable mới nhất trong `releases_linux.json` |
| Dart SDK | **3.13.4** (đi kèm Flutter 3.47.5) | Có sẵn trong Flutter; Dart 3.13 thêm *primary constructors* |
| Ràng buộc SDK trong `pubspec.yaml` | `sdk: ^3.13.4` | Mặc định của `flutter create` với SDK trên |
| State + DI | `provider 6.1.5+1` + `ChangeNotifier` (có sẵn trong SDK) | Docs chính thức khuyên dùng (xem mục 3) |
| Điều hướng | `go_router 18.0.2` | Docs chính thức khuyên dùng; do team Flutter duy trì |
| SQLite | `sqflite 2.4.4` (+ `sqflite_common_ffi 2.4.3` để test, `sqflite_common_ffi_web 1.2.0` cho web) | Cookbook chính thức dùng sqflite |
| Key-value | `shared_preferences 2.5.5` | Cookbook chính thức |
| Text-to-speech | `flutter_tts 4.2.5` | Docs không nêu tên — lựa chọn của sách |
| SQLite web | `sqlite3 3.6.0` (ghim, khớp file wasm) | Xem mục 5 |
| Thông báo cục bộ | `flutter_local_notifications 22.3.1` + `timezone 0.11.1` + `flutter_timezone 5.1.0` | Docs không nêu tên — lựa chọn của sách |
| HTTP | `http 1.6.0` | Tutorial chính thức dùng package http |
| Test | `flutter_test`, `integration_test` (trong SDK), `mocktail 1.0.5` | Docs + case study chính thức |
| Lint | `flutter_lints 6.0.0` | Mặc định của `flutter create` |
| Bảo mật (Tập 3) | `flutter_secure_storage 11.2.0`, `crypto 3.0.7` | Docs không nêu tên — lựa chọn của sách |

## 2. Flutter và Dart mới nhất

- `releases_linux.json` (2026-09-30): `current_release.stable` = `6a19cca…` = **Flutter 3.47.5**,
  ngày 2026-09-18, Dart **3.13.4**. Kênh beta đang ở 3.49.0-0.1.pre (Dart 3.14.0) — **không dùng** beta.
- Trong sandbox: `flutter --version` →
  `Flutter 3.47.5 • channel stable • Framework revision 6a19cca564 • Tools • Dart 3.13.4 • DevTools 2.60.0`.
- Flutter 3.47 ra mắt 2026-08-12 (trang "What's new" của docs). Điểm đáng chú ý cho sách:
  Widget Previews lên stable; hướng dẫn Swift Package Manager mở rộng.
- Từ Flutter 3.44, **Swift Package Manager (SwiftPM)** là mặc định để quản lý phụ thuộc native iOS/macOS;
  CocoaPods ở chế độ bảo trì (maintenance mode), và registry CocoaPods sẽ chỉ-đọc từ 2026-12-02
  (docs `packages-and-plugins/swift-package-manager/for-app-developers`).
- Dart 3.13.0 (2026-08-12, CHANGELOG của Dart SDK): thêm **primary constructors**
  (`class Point(var int x, var int y);`) — rất giống "parameter properties" của TypeScript.
  Breaking change nhỏ: không được viết `final`/`var` trước tham số thường nữa.
  Dart 3.12 thêm private named parameters. Sách dùng cú pháp cổ điển là chính và giới thiệu
  primary constructors trong Tập 1, Chương 3 (đã compile thật).

## 3. Docs chính thức khuyên gì? (state, DI, routing, dữ liệu, test)

Trang **Architecture recommendations** (`app-architecture/recommendations`, dữ liệu trong
`src/data/architectureRecommendations.yml`) xếp hạng khuyến nghị:

| Khuyến nghị của docs | Mức độ | Sách áp dụng thế nào |
|---|---|---|
| Tách rõ data layer và UI layer | strong | Tập 2–3: `data/` (repository, service) và `ui/` (view, view model) |
| Repository pattern ở data layer | strong | `WordRepository`, `NoteRepository` (abstract + bản SQLite + bản giả để test) |
| MVVM: View + ViewModel ở UI layer | strong | ViewModel = `ChangeNotifier`; View = widget "ngốc" |
| Dùng `ChangeNotifier` + `Listenable` để cập nhật widget | conditional | Dùng; so sánh Riverpod, Bloc, signals ở Tập 2 Ch.1 |
| **DI bằng package `provider`** | strong | `MultiProvider` ở gốc app |
| **Điều hướng bằng `go_router`** ("preferred way to write 90% of Flutter applications") | recommend | Cả 3 tập |
| Command pattern cho sự kiện người dùng | recommend | Tập 3 (`Command0/Command1`) và app mẫu Tập 2 dạng đơn giản |
| Model bất biến (immutable) | strong | `final` field + `copyWith` viết tay (không dùng freezed để tránh code generation) |
| Test từng thành phần + dùng **fake** | strong | Mỗi repository có bản `Fake…`; `mocktail` chỉ khi cần kiểm tra lời gọi |

Thêm:
- Trang `ui/navigation` không khuyên dùng named routes cho đa số app; khuyên dùng go_router.
- Trang `data-and-backend/state-mgmt/simple` dạy `provider`; Learning Pathway dạy
  `ChangeNotifier` + `ListenableBuilder` (không cần package).
- Cookbook `persistence/sqlite` dùng `sqflite` + `path`; ví dụ kiến trúc chính thức
  `examples/app-architecture/todo_data_service` dùng `sqflite`, `sqflite_common_ffi`, `shared_preferences`.
- Case study kiến trúc (`app-architecture/case-study/testing`) mock router bằng `package:mocktail`;
  cookbook `testing/unit/mocking` dùng `mockito` (cần build_runner sinh code). **Quyết định:** fake viết tay
  là chính, `mocktail` (không sinh code) khi cần `verify`.

### So sánh thư viện state (Tập 2)

| Repo | Stars | Cập nhật gần nhất (updated_at) | License | Hữu ích | Ngày kiểm tra |
|---|---|---|---|---|---|
| https://github.com/rrousselGit/provider | 5.2k | 2026-09-29 | MIT | Docs chính thức khuyên; giống DI của Angular | 2026-09-30 |
| https://github.com/rrousselGit/riverpod | 7.4k | 2026-09-29 | MIT | Mạnh, an toàn compile-time, cache async | 2026-09-30 |
| https://github.com/felangel/bloc | 12.5k | 2026-09-30 | MIT | Luồng sự kiện → state, giống NgRx | 2026-09-30 |
| https://github.com/rodydavis/signals.dart | 0.8k | 2026-09-22 | Apache-2.0 | API giống Angular Signals | 2026-09-30 |

Số liệu pub.dev (2026-09-30, API `/score`): provider 11,008 likes; flutter_riverpod 2,910 likes
(pub.dev không gắn tag web cho flutter_riverpod 3.4.3); flutter_bloc 8,081 likes; signals 710 likes.

**Quyết định:** `provider` + `ChangeNotifier`. Lý do: (1) docs chính thức khuyên; (2) `ChangeNotifier`
nằm trong SDK, ít thứ phải học; (3) map thẳng sang service + DI của Angular; (4) một agent khác (Task 9)
sẽ làm theo sách — chọn con đường chính thức ít bất ngờ nhất.

## 4. Chạy app Flutter trên iPhone — nói thật

**Không có "Expo Go" cho Flutter.** Flutter biên dịch Dart thành mã máy (AOT) cho iOS, nên muốn chạy
app native trên iPhone phải **build bằng Xcode trên máy Mac**. Các lựa chọn thật của Nobin:

| Cách | Cần gì | Ưu / nhược |
|---|---|---|
| **A. Mac + Xcode + cáp** (`flutter run`) | Máy Mac, Xcode, Apple ID miễn phí | Cách chính thức. Hot reload trên máy thật. Xem các bước dưới |
| **B. Web build trên Safari** (`flutter run -d web-server` hoặc `flutter build web`) | Chỉ cần máy tính + iPhone cùng Wi-Fi | Không cần Mac. Nhưng là **web**, không phải app native: không có thông báo cục bộ theo lịch; SQLite chạy bằng WebAssembly |
| **C. TestFlight** | Mac (hoặc Mac trên cloud CI), **Apple Developer Program trả phí** | Cài qua app TestFlight, giống app thật; cần build + upload |

**Cách A — các bước theo docs chính thức (`platform-integration/ios/setup`):**
1. Cài Xcode, chạy `sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'`,
   `sudo xcodebuild -license`, `xcodebuild -downloadPlatform iOS`.
2. (Tùy chọn) CocoaPods cho plugin chưa hỗ trợ SwiftPM.
3. Cắm iPhone vào Mac → bấm **Trust**.
4. Bật **Developer Mode**: Settings → Privacy & Security → Developer Mode → On → khởi động lại.
5. Tạo chứng chỉ ký (signing) bằng Apple ID; docs viết: tài khoản developer cá nhân miễn phí
   dùng được khi chỉ *test* trên máy của mình.
6. Trên iPhone: Settings → VPN & Device Management → tin cậy (Trust) chứng chỉ developer.
7. `cd books/flutter/vol1-co-ban/examples && flutter run` (chọn iPhone).

- **UNVERIFIED:** app ký bằng tài khoản miễn phí hết hạn sau 7 ngày và phải cài lại. Đây là điều cộng
  đồng hay nói; chúng tôi không mở được trang Apple nào xác nhận con số này.
- Trang Apple (đã mở 2026-09-30, https://developer.apple.com/programs/): đăng ký tài khoản miễn phí
  cho phép chạy app trên thiết bị của mình bằng Xcode; **Apple Developer Program: $99 mỗi năm**, cần cho
  TestFlight và App Store.

**Cách B — web trên Safari (không cần Mac):**
```bash
cd books/flutter/vol2-trung-cap/examples
flutter build web --no-web-resources-cdn --release
cd build/web && python3 -m http.server 8080 --bind 0.0.0.0
# trên iPhone (cùng Wi-Fi): mở Safari → http://<IP-máy-tính>:8080
```
- Docs (`platform-integration/web/faq`): Flutter web chạy trên Safari (mobile & desktop).
- Docs (`platform-integration/web/wasm`): bản build **Wasm** không chạy trên bất kỳ trình duyệt nào của iOS
  → **không** dùng `--wasm` cho iPhone; bản JavaScript mặc định thì được.
- `--no-web-resources-cdn`: dùng CanvasKit đóng gói sẵn thay vì tải từ CDN (sandbox chặn CDN; trên iPhone
  cũng giúp chạy khi mạng chậm).
- **Chạy trên iPhone: NOT RUN** (không có iPhone/Mac trong sandbox). Bản web đã được kiểm tra trong
  Chromium headless (xem `logs/`). Hành vi trên Safari iOS (TTS bằng Web Speech, SQLite Wasm) là **UNVERIFIED**.

**Cách C — Mac trên cloud:** GitHub Actions có runner macOS; Codemagic cũng build iOS. Vẫn cần Apple
Developer Program để ký và phân phối. Chi tiết ở Tập 3 Ch.5–6. Giá/điều khoản dịch vụ CI: **UNVERIFIED**
(trang docs.github.com và codemagic.io bị chặn trong sandbox).

## 5. Thư viện cho từng tập (bảng cho Task 9)

Tất cả ghim **exact** (không `^`) trong `pubspec.yaml`; `pubspec.lock` được commit.
Đã chạy `flutter pub get` thành công với Flutter 3.47.5 / Dart 3.13.4 trong các dự án `vol*/examples`.

| Tập | Package | Phiên bản | Publisher (pub.dev) | License | Nền tảng (tag pub.dev) | Docs nêu tên? | Dùng để |
|---|---|---|---|---|---|---|---|
| 1 | go_router | 18.0.2 | flutter.dev | BSD-3-Clause | android, ios, web, … | Có | Điều hướng, deep link, tab (ShellRoute) |
| 2 | shared_preferences | 2.5.5 | flutter.dev | BSD-3-Clause | android, ios, web, … | Có | Lưu cài đặt (theme sáng/tối) |
| 1–3 | flutter_lints (dev) | 6.0.0 | flutter.dev | BSD-3-Clause | tất cả | Có (mặc định) | Lint |
| 2 | provider | 6.1.5+1 | dash-overflow.net | MIT | android, ios, web, … | Có | DI + lắng nghe ChangeNotifier |
| 2 | sqflite | 2.4.4 | tekartik.com | BSD-2-Clause | android, ios, macos | Có | SQLite trên điện thoại |
| 2 | path | 1.9.1 | dart.dev | BSD-3-Clause | tất cả | Có | Ghép đường dẫn file DB |
| 2 | sqflite_common_ffi (dev) | 2.4.3 | tekartik.com | BSD-2-Clause | tất cả | Có (trong ví dụ kiến trúc) | Chạy SQLite thật trong `flutter test` |
| 2 | sqflite_common_ffi_web | 1.2.0 | tekartik.com | BSD-2-Clause | web | Có (docs gọi là *experimental*) | SQLite (Wasm) cho bản web / Safari |
| 2 | sqlite3 | 3.6.0 | simonbinder.eu | MIT | tất cả | Không (phụ thuộc gián tiếp) | Ghim để khớp `web/sqlite3.wasm` (bản sqlite3-3.6.0) |
| 2 | http | 1.6.0 | dart.dev | BSD-3-Clause | tất cả | Có | Gọi API REST |
| 2 | flutter_tts | 4.2.5 | eyedeadevelopment.com | MIT | android, ios, web, … | Không | Đọc to từ vựng (text-to-speech) |
| 2 | flutter_local_notifications | 22.3.1 | dexterx.dev | BSD-3-Clause | android, ios, … | Không | Nhắc ôn bài hằng ngày |
| 2 | timezone | 0.11.1 | labs.dart.dev | BSD-2-Clause | tất cả | Không | Lịch theo múi giờ (`zonedSchedule`) |
| 2 | flutter_timezone | 5.1.0 | wolverinebeach.net | Apache-2.0 | android, ios, web, … | Không | Lấy múi giờ của máy (IANA) |
| 2 | mocktail (dev) | 1.0.5 | felangel.dev | MIT | tất cả | Có (case study) | Mock khi cần `verify` |
| 2 | integration_test (dev) | SDK | flutter.dev | BSD-3-Clause | — | Có | Integration test |
| 3 | flutter_secure_storage | 11.2.0 | steenbakker.dev | BSD-3-Clause | android, ios, web, … | Không | Lưu bí mật (Keychain/Keystore) |
| 3 | crypto | 3.0.7 | dart.dev | BSD-3-Clause | tất cả | Không | Băm PIN (SHA-256 + salt) |

Không dùng (và lý do):
- `drift` 2.35.0 (type-safe SQL, reactive) — mạnh nhưng cần code generation (build_runner); sqflite đủ cho
  app TOEIC và là lựa chọn của cookbook. Ghi ở "Ideas for later".
- `hive` 2.2.3, `isar` 3.1.0+1 — bản mới nhất từ 2022/2023, ràng buộc SDK `<3.0.0` → **không** dùng được với Dart 3.13.
- `sqlite3_flutter_libs` — bản mới nhất là `0.6.0+eol` (end of life).
- `freezed`/`json_serializable` — docs "recommend" freezed, nhưng sách viết `fromJson`/`copyWith` bằng tay để
  người mới thấy rõ cơ chế và để build không cần build_runner. Tập 2 Ch.3 giới thiệu json_serializable.

Ghi chú nền tảng quan trọng cho Task 9:
- `sqflite` không có bản web. Trên web phải gán `databaseFactory = databaseFactoryFfiWeb` và có 2 file
  `web/sqlite3.wasm` + `web/sqflite_sw.js` (tạo bằng `dart run sqflite_common_ffi_web:setup`, đã commit trong
  dự án Tập 2).
- `flutter_local_notifications` 22 cần bật *core library desugaring* trong Gradle của Android
  (README của package). Trên iOS phải xin quyền (`requestPermissions`). Web không có lịch thông báo.
- `flutter_tts` trên iOS: dùng `setIosAudioCategory` nếu muốn đọc cả khi bật chế độ im lặng (README).

## 6. Công cụ trong sandbox (để kiểm tra sách)

| Công cụ | Phiên bản |
|---|---|
| Flutter / Dart / DevTools | 3.47.5 / 3.13.4 / 2.60.0 (tại `/opt/flutter`) |
| Node / npm | 22.22.2 / 10.9.7 |
| pandoc | 3.1.3 |
| playwright-core / mermaid (build PDF, smoke test web) | 1.56.1 / 12.0.0 |
| Chromium (Playwright) | `/opt/pw-browsers/chromium-1194` |

Không có: Xcode, Android SDK, thiết bị thật, máy ảo. Mọi mục "chạy trên iPhone/Android" là **NOT RUN**.

## 7. Bản quyền nội dung tham khảo

- Repo `flutter/website` (nguồn của docs.flutter.dev): "Except as otherwise noted", nội dung theo
  **Creative Commons Attribution 3.0**, code mẫu theo **BSD License** (file LICENSE của repo, kiểm tra 2026-09-30).
- Repo `dart-lang/site-www` (nguồn của dart.dev): nội dung **CC BY 4.0**, code mẫu **BSD-3-Clause** (file LICENSE).
- Sách viết lại bằng lời của mình (paraphrase), chỉ trích ngắn, luôn ghi nguồn. Code trong `examples/` do sách tự viết.

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30:
- Flutter releases (Linux): https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json
- Dart SDK CHANGELOG (3.12, 3.13): https://github.com/dart-lang/sdk/blob/main/CHANGELOG.md
- Docs Flutter — mã nguồn tại commit `ab59c614e780e2d6d44f07ae4a96238028f581a5`
  (trang tương ứng trên docs.flutter.dev bị chặn trong sandbox):
  - Architecture recommendations — https://docs.flutter.dev/app-architecture/recommendations —
    https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/recommendations.md
    và https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/data/architectureRecommendations.yml
  - Navigation and routing — https://docs.flutter.dev/ui/navigation —
    https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/ui/navigation/index.md
  - Simple app state management — https://docs.flutter.dev/data-and-backend/state-mgmt/simple —
    https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/data-and-backend/state-mgmt/simple.md
  - State management options — https://docs.flutter.dev/data-and-backend/state-mgmt/options —
    https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/data-and-backend/state-mgmt/options.md
  - Persist data with SQLite — https://docs.flutter.dev/cookbook/persistence/sqlite —
    https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/persistence/sqlite.md
  - Ví dụ kiến trúc todo_data_service (pubspec): https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/examples/app-architecture/todo_data_service/pubspec.yaml
  - Case study — testing — https://docs.flutter.dev/app-architecture/case-study/testing —
    https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/case-study/testing.md
  - Set up iOS development — https://docs.flutter.dev/platform-integration/ios/setup —
    https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/platform-integration/ios/setup.md
  - Swift Package Manager for app developers — https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers —
    https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/packages-and-plugins/swift-package-manager/for-app-developers.md
  - Web FAQ — https://docs.flutter.dev/platform-integration/web/faq —
    https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/platform-integration/web/faq.md
  - Wasm — https://docs.flutter.dev/platform-integration/web/wasm —
    https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/platform-integration/web/wasm.md
  - What's new — https://docs.flutter.dev/release/whats-new —
    https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/release/whats-new.md
  - LICENSE của repo docs: https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/LICENSE
- Dart docs — LICENSE: https://github.com/dart-lang/site-www/blob/001b59a9ba35a4f578c1dc6f922730c2cd413988/LICENSE
- pub.dev (phiên bản, publisher, license, nền tảng):
  https://pub.dev/packages/provider, https://pub.dev/packages/go_router, https://pub.dev/packages/sqflite,
  https://pub.dev/packages/sqflite_common_ffi, https://pub.dev/packages/sqflite_common_ffi_web,
  https://pub.dev/packages/shared_preferences, https://pub.dev/packages/http, https://pub.dev/packages/path,
  https://pub.dev/packages/flutter_tts, https://pub.dev/packages/flutter_local_notifications,
  https://pub.dev/packages/timezone, https://pub.dev/packages/flutter_timezone, https://pub.dev/packages/mocktail,
  https://pub.dev/packages/flutter_lints, https://pub.dev/packages/flutter_secure_storage, https://pub.dev/packages/crypto,
  https://pub.dev/packages/flutter_riverpod, https://pub.dev/packages/flutter_bloc, https://pub.dev/packages/signals,
  https://pub.dev/packages/drift, https://pub.dev/packages/hive, https://pub.dev/packages/isar,
  https://pub.dev/packages/sqlite3_flutter_libs, https://pub.dev/packages/sqlite3
- README của package (đọc trong pub cache sau `flutter pub get`): flutter_local_notifications 22.3.1, flutter_tts 4.2.5.
- Apple Developer Program: https://developer.apple.com/programs/
