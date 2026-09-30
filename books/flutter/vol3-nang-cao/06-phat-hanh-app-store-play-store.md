# Chương 6 — Phát hành App Store và Google Play

## Mục tiêu

- Biết đầy đủ các bước đưa app Flutter lên **App Store** (qua TestFlight) và **Google Play**, theo docs chính thức.
- Hiểu version name / build number, icon, launch screen, ký app (signing).
- Build bản phát hành: `flutter build ipa`, `flutter build appbundle`; obfuscation + file ký hiệu.
- Viết logic "bắt buộc cập nhật" (force update) bằng so sánh version.
- Có checklist phát hành cho app TOEIC.

## Giải thích đơn giản

| Bước | iOS (App Store) | Android (Google Play) |
|---|---|---|
| Tài khoản | Apple Developer Program ($99/năm — developer.apple.com/programs, 2026-09-30) | Google Play Console (phí đăng ký: **UNVERIFIED**, trang Google bị chặn) |
| Định danh app | Bundle ID (`dev.nobin.tap3_so_ghi_chu`) — đăng ký trên developer.apple.com | Application ID (`applicationId` trong `build.gradle.kts`) |
| Tạo app trên store | App Store Connect → New App | Play Console → Create app |
| Ký app | Certificate + provisioning profile (Xcode tự ký được) | Upload keystore (`.jks`) + `key.properties` |
| Build | `flutter build ipa` (cần macOS + Xcode) | `flutter build appbundle` (định dạng Play khuyên) |
| Thử nội bộ | **TestFlight** | Internal testing track |
| Phát hành | Gửi xét duyệt (App Review) | Gửi xét duyệt, phát hành theo % (staged rollout) |

Với Angular dev: giống deploy web nhưng có **người duyệt**, **chữ ký số**, và **không rollback tức thì** — bản lỗi đã cài trên máy
người dùng. Vì vậy kiểm tra kỹ (Chương 5) và có cơ chế **force update**.

## Ví dụ

### Version — một nguồn duy nhất

`pubspec.yaml`: `version: 1.0.0+1`. Docs: iOS dùng phần trước `+` cho `CFBundleShortVersionString`, phần sau cho
`CFBundleVersion`; Android dùng `versionName` / `versionCode`. Ghi đè khi build: `--build-name=1.0.1 --build-number=7`.

### Build bản phát hành

```bash
# iOS (trên Mac): tạo .xcarchive + .ipa trong build/ios/ipa
flutter build ipa --release --obfuscate --split-debug-info=build/symbols
# Upload: mở build/ios/archive/Runner.xcarchive bằng Xcode → Distribute App,
# hoặc ứng dụng Transporter, hoặc:
xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey <key_id> --apiIssuer <issuer_id>

# Android: tạo .aab trong build/app/outputs/bundle/release/
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

**NOT RUN** trong sandbox (không có Xcode / Android SDK). Lệnh và cờ lấy từ docs iOS/Android và `flutter build appbundle -h`
(sandbox có lệnh này và in ra mô tả `--obfuscate`, `--split-debug-info`).

### Ký app Android (theo docs)

1. Tạo upload keystore: `keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -storetype JKS -keysize 2048 -validity 10000 -alias upload`.
2. Tạo `android/key.properties` (mật khẩu, alias, đường dẫn file) — **không commit** (`.gitignore` của sách đã chặn).
3. Sửa `android/app/build.gradle.kts` đọc `key.properties` và dùng `signingConfigs.release` thay cho `debug`.
Docs còn có mục R8 (thu nhỏ code, bật sẵn cho bản release), và mục mới về ký lai hậu lượng tử (Android 17+) — xem docs khi cần.

### Force update — `examples/lib/chapters/ch06/force_update.dart`

```dart
int compareVersions(String a, String b) {
  List<int> parse(String v) => v.split('+').first.split('.').map(int.parse).toList();
  final pa = parse(a), pb = parse(b);
  for (var i = 0; i < 3; i++) {
    final c = pa[i].compareTo(pb[i]);
    if (c != 0) return c;
  }
  return 0;
}

/// Bắt cập nhật khi bản đang cài thấp hơn bản tối thiểu (server/Remote Config trả về).
bool needsForceUpdate({required String installed, required String minimumSupported}) =>
    compareVersions(installed, minimumSupported) < 0;
```

So sánh **từng phần số**: "1.10.0" > "1.9.9" (so chuỗi sẽ sai). Test ở phần Ch.5–6 của `test/chapters_test.dart` (pass).

## Đi sâu

### Icon và launch screen

Docs: icon iOS nằm trong `ios/Runner/Assets.xcassets/AppIcon.appiconset`; Android trong `android/app/src/main/res/mipmap-*`.
Launch screen iOS: `LaunchScreen.storyboard`. Package `flutter_launcher_icons` / `flutter_native_splash` (2.4.8) sinh các file này từ
một ảnh — tùy chọn, sách không dùng.

### App Review — những điều hay bị từ chối (tổng quát)

Thiếu chính sách quyền riêng tư (privacy policy) khi thu thập dữ liệu, xin quyền mà không giải thích (Info.plist cần câu mô tả
cho camera/micro/vị trí…), app "chỉ là trang web", crash khi duyệt. Chi tiết chính thức ở App Review Guidelines của Apple (chưa
mở được trong sandbox — **UNVERIFIED**). App TOEIC dùng thông báo cục bộ và TTS: không cần quyền đặc biệt ngoài thông báo.

### Privacy manifest / nhãn dữ liệu

Apple yêu cầu mô tả dữ liệu app thu thập (App Privacy trên App Store Connect); Google Play có mục Data safety. App offline như
"Sổ Từ Vựng" / TOEIC thường khai "không thu thập dữ liệu" — nếu thêm Sentry (Chương 7) thì phải khai báo. **UNVERIFIED** về chi
tiết biểu mẫu hiện tại.

### Symbols và crash

Giữ thư mục `build/symbols` của **mỗi** bản phát hành (đặt tên theo version). Khi có stack trace đã obfuscate:
`flutter symbolize -i <file stack trace> -d <file .symbols tương ứng trong build/symbols>` (docs "Obfuscate Dart code").

### Web

`flutter build web --release` → thư mục `build/web` tải lên bất kỳ hosting tĩnh (Firebase Hosting, GitHub Pages…); docs
"Build and release a web app". Đây là cách Nobin mở app trên iPhone bằng Safari mà không cần App Store (Tập 1, Ch.1).

## Lỗi và bẫy thường gặp

- **Bundle ID / Application ID đổi sau khi phát hành** → thành app khác. Chọn kỹ ngay từ đầu (`--org` khi `flutter create`).
- **Mất upload keystore** → Play App Signing có quy trình reset nhưng mất thời gian; sao lưu keystore an toàn.
- **Quên tăng build number** → store từ chối.
- **Phát hành bản debug** hoặc còn `debugShowCheckedModeBanner` → xấu, chậm.
- **Xin quyền không giải thích** (thiếu `NS...UsageDescription`) → app crash khi xin quyền trên iOS / bị từ chối.
- **Không lưu symbols** → không đọc được crash.

## Tóm tắt

- iOS: Apple Developer Program → Bundle ID → App Store Connect → `flutter build ipa` → TestFlight → App Review.
- Android: keystore + `key.properties` → `flutter build appbundle` → Internal testing → Production.
- Version từ `pubspec.yaml`; build number luôn tăng; obfuscate + giữ symbols; force update bằng so sánh version.

## Bài tập (có lời giải)

**Bài 1.** Viết `compareVersions` sao cho "1.10.0" > "1.9.9" và bỏ qua phần build (`+7`). Vì sao không so sánh chuỗi?

<details>
<summary>Lời giải</summary>

Code ở trên. So sánh chuỗi theo từ điển: "1.10.0" < "1.9.9" vì ký tự '1' < '9' ở vị trí thứ 3 → sai. Tách thành số rồi so từng
phần. Test: `compareVersions('1.10.0', '1.9.9') > 0`, `compareVersions('1.2.3+7', '1.2.3+1') == 0`,
`needsForceUpdate(installed: '1.2.0', minimumSupported: '1.3.0') == true`.
</details>

**Bài 2.** Viết checklist phát hành bản 1.0.0 của app TOEIC lên TestFlight (không cần code).

<details>
<summary>Lời giải</summary>

1. `flutter pub outdated` + `flutter analyze` + `flutter test` + `scripts/check-all.sh` xanh.
2. `pubspec.yaml`: `version: 1.0.0+1`; Bundle ID cố định (ví dụ `dev.nobin.toeic`).
3. Icon, tên hiển thị (`CFBundleDisplayName`), launch screen.
4. Kiểm tra trên iPhone thật: đọc to, nhắc hằng ngày, dữ liệu offline, dark mode (danh sách NOT RUN của sách).
5. Apple Developer Program đã kích hoạt; tạo app trên App Store Connect.
6. `flutter build ipa --obfuscate --split-debug-info=build/symbols/1.0.0+1`; lưu symbols.
7. Upload (Xcode Organizer / Transporter / `xcrun altool`); điền thông tin TestFlight, mời Nobin làm tester.
8. Ghi App Privacy (không thu thập dữ liệu nếu không có analytics/Sentry).
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30 (đọc file nguồn docs ở commit `ab59c61`):

- Build and release an iOS app — https://docs.flutter.dev/deployment/ios —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/deployment/ios.md
- Build and release an Android app — https://docs.flutter.dev/deployment/android —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/deployment/android.md
- Build and release a web app — https://docs.flutter.dev/deployment/web —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/deployment/web.md
- Obfuscate Dart code — https://docs.flutter.dev/deployment/obfuscate —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/deployment/obfuscate.md
- Apple Developer Program: https://developer.apple.com/programs/
- Package flutter_native_splash: https://pub.dev/packages/flutter_native_splash
- Sách React Native trong repo: [Tập 3, Chương 6 — Phát hành](../../react-native/vol3-nang-cao/06-phat-hanh-app-store-play-store.md)
