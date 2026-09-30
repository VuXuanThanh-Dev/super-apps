# Chương 4 — Bảo mật: lưu bí mật, PIN, khóa tự động, deep link, obfuscation

## Mục tiêu

- Lưu bí mật đúng chỗ: **Keychain / Keystore** qua `flutter_secure_storage` — không phải shared_preferences.
- Băm PIN có muối (salt), so sánh constant-time, **khóa tạm** khi nhập sai nhiều lần, từ chối PIN yếu.
- **Tự khóa** khi app vào nền quá lâu (`AppLifecycleListener`) và chặn mọi màn hình bằng `redirect` của go_router.
- Kiểm tra dữ liệu từ bên ngoài (deep link) và **không log dữ liệu nhạy cảm**.
- Biết obfuscation làm được gì và **không** làm được gì; biết lời khuyên bảo mật của team Flutter.

## Giải thích đơn giản

Nguyên tắc: **app chạy trên máy của người khác** — ai có máy (hoặc file cài đặt) đều có thể đọc code và dữ liệu nếu không được
bảo vệ. Docs "Obfuscate Dart code" cảnh báo thẳng: lưu bí mật (API key của server…) **trong app** là thực hành kém; obfuscation
chỉ đổi tên biểu tượng, **không** mã hóa tài nguyên và **không** chống dịch ngược.

| Dữ liệu | Để ở đâu | Vì sao |
|---|---|---|
| Cài đặt (theme) | shared_preferences | Không nhạy cảm |
| Token đăng nhập, PIN (đã băm), ghi chú bí mật | **flutter_secure_storage** (Keychain/Keystore) | Được hệ điều hành mã hóa, gắn với thiết bị |
| API key bí mật của server | **Không để trong app** — để trên server | Ai cũng lấy được từ file cài đặt |

`flutter_secure_storage 11.2.0` (README): iOS dùng **Keychain**; Android mã hóa bằng khóa trong **Keystore** (mặc định
RSA-OAEP bọc khóa + AES-GCM); web dùng WebCrypto và **chỉ chạy trên HTTPS hoặc localhost**.

## Ví dụ

### Kho bí mật — `examples/lib/core/security/secure_store.dart`

```dart
abstract interface class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureStore implements SecureStore {
  FlutterSecureStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // Chỉ đọc được sau khi máy mở khóa lần đầu kể từ lúc khởi động (README: IOSOptions.accessibility).
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
          );
  // read / write / delete gọi _storage
}
```

`first_unlock_this_device`: không đọc được trước lần mở khóa đầu tiên sau khi khởi động, và **không** chuyển sang máy khác qua
bản sao lưu. Android: README khuyên tắt auto backup (`android:allowBackup="false"`) để tránh lỗi khóa khi khôi phục — dự án đã đặt.

### Băm PIN — `examples/lib/features/auth/domain/pin_hasher.dart`

```dart
/// Muối (salt) ngẫu nhiên 16 byte từ bộ sinh số an toàn (Random.secure) — mỗi PIN một muối.
String generateSalt([Random? random]) {
  final r = random ?? Random.secure();
  return base64Encode(List<int>.generate(16, (_) => r.nextInt(256)));
}

/// Băm PIN = SHA-256 lặp [iterations] lần với muối. KHÔNG lưu PIN gốc.
String hashPin(String pin, String salt, {int iterations = 10000}) {
  final saltBytes = base64Decode(salt);
  var digest = sha256.convert([...saltBytes, ...utf8.encode(pin)]).bytes;
  for (var i = 1; i < iterations; i++) {
    digest = sha256.convert([...digest, ...saltBytes]).bytes;
  }
  return base64Encode(digest);
}

/// So sánh không để lộ thời gian (constant-time): luôn duyệt hết chuỗi.
bool constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

/// Thời gian khóa sau [failedAttempts] lần sai liên tiếp: 5 lần → 30 giây, mỗi lần sai thêm gấp đôi, tối đa 1 giờ.
Duration lockoutDuration(int failedAttempts) {
  if (failedAttempts < 5) return Duration.zero;
  final seconds = 30 * pow(2, failedAttempts - 5).toInt();
  return Duration(seconds: min(seconds, 3600));
}
```

**Nói thật về giới hạn:** PIN 4–6 số chỉ có 10⁴–10⁶ khả năng. Nếu kẻ xấu lấy được muối + hash, họ vẫn dò ra PIN (dù lặp
SHA-256 làm chậm hơn). Lớp bảo vệ thật sự là: hash nằm trong **Keychain/Keystore** + **khóa tạm** sau nhiều lần sai + tự khóa.
Thuật toán chuyên cho mật khẩu (PBKDF2, scrypt, Argon2) tốt hơn SHA-256 lặp; package `crypto` không có sẵn chúng — xem "Ideas for later".

`PinRepository.verify` trả về sealed class `PinOk` / `PinWrong(failedAttempts)` / `PinLocked(remaining)` và lưu bộ đếm sai +
thời điểm hết khóa **trong SecureStore** (không trong bộ nhớ — đóng app mở lại không xóa được bộ đếm).

### Tự khóa + chặn màn hình

```dart
// app.dart — theo dõi vòng đời app
_lifecycle = AppLifecycleListener(onHide: _auth.onBackground, onShow: _auth.onResume);

// router.dart — guard
redirect: (context, state) {
  final atLock = state.matchedLocation == '/lock';
  final unlocked = auth.status == AuthStatus.unlocked;
  if (!unlocked) return atLock ? null : '/lock';
  if (atLock) return '/notes';
  return null;
},
refreshListenable: auth,
```

`AuthController.onResume` khóa lại nếu app ở nền lâu hơn `autoLockAfter` (30 giây, chỉnh trong Cài đặt). Test:

```dart
auth.onBackground();
now = now.add(const Duration(minutes: 2));
auth.onResume();
expect(auth.status, AuthStatus.locked);
```

### Deep link — kiểm tra trước khi dùng

```dart
String? parseNoteDeepLink(Uri uri) {
  final idRe = RegExp(r'^[a-z0-9-]{1,40}$');
  final segments = switch (uri) {
    Uri(scheme: 'sochichu', host: 'notes') => uri.pathSegments,
    Uri(scheme: 'https', host: 'nobin.dev') when uri.pathSegments.firstOrNull == 'notes' =>
      uri.pathSegments.skip(1).toList(),
    _ => const <String>[],
  };
  if (segments.length != 1) return null;
  final id = segments.single;
  return idRe.hasMatch(id) ? id : null;
}
```

Phát hiện khi test: `Uri.parse('sochichu://notes/../../etc')` được **chuẩn hóa** thành path `/etc` → hàm trả `'etc'`. Vẫn an
toàn vì id chỉ dùng để tra cứu (không ghép thành đường dẫn file); bài học: **kiểm tra trên giá trị sau cùng**, sau khi parse.
(Sách React Native trong repo gặp đúng hiện tượng này với `URL()` của JavaScript.)

### Không log dữ liệu nhạy cảm

`AppLogger` luôn chạy `redact()` trước khi lưu/gửi: email → `<email>`, dãy từ 4 chữ số → `<số>`. `AuthController` chỉ log
"Đã tạo PIN", không bao giờ log giá trị. Test toàn app kiểm tra không bản ghi nào chứa "2468".

Kết quả thật (2026-09-30, `flutter test --reporter expanded test/auth_test.dart`):

```text
00:00 +0: pin_hasher (domain thuần) muối khác nhau → hash khác nhau; cùng muối → cùng hash; không chứa PIN gốc
00:00 +1: pin_hasher (domain thuần) constantTimeEquals, isValidPinFormat
00:00 +2: pin_hasher (domain thuần) lockoutDuration: 5 lần → 30s, gấp đôi, tối đa 1 giờ
00:00 +3: pin_hasher (domain thuần) shouldAutoLock
00:00 +4: PinRepository chỉ lưu muối + hash; sai 5 lần thì khóa tạm; hết giờ khóa thì mở được
00:00 +5: AuthController tạo PIN: từ chối PIN yếu và PIN không khớp
00:00 +6: AuthController khóa, mở sai, mở đúng; tự khóa khi ở nền quá lâu
00:00 +7: All tests passed!
```

## Đi sâu

### Obfuscation

```bash
flutter build apk --obfuscate --split-debug-info=build/symbols
flutter build ipa --obfuscate --split-debug-info=build/symbols
```

Docs: chỉ có hiệu lực ở **release**; `--obfuscate` luôn đi cùng `--split-debug-info` (file ký hiệu để giải mã stack trace bằng
`flutter symbolize` — **phải lưu lại** file này cho từng bản phát hành); web không obfuscate mà được minify. Code dựa vào tên
kiểu (`runtimeType.toString()`, `Enum.toString()`) sẽ ra tên lạ sau khi obfuscate — app của sách dùng `enum.name`/chuỗi cố định.

### Lời khuyên của team Flutter (trang Security)

- Luôn dùng **Flutter stable mới nhất** và **cập nhật package** (bản vá bảo mật).
- Docs khuyên **tránh ghim cứng phiên bản** package; nếu ghim thì phải kiểm tra định kỳ. **Sách ghim exact** để mọi người (và
  app TOEIC — Task 9) build ra cùng kết quả; đổi lại, hãy chạy `flutter pub outdated` hằng tháng và nâng phiên bản có chủ đích
  (xem STACK.md). Đây là đánh đổi có ý thức, không phải bỏ qua lời khuyên.

### Thêm nếu app có server

HTTPS bắt buộc (iOS chặn HTTP mặc định); token ngắn hạn + refresh; kiểm tra quyền **ở server**; cân nhắc certificate pinning
cho app nhạy cảm (có rủi ro khi chứng chỉ đổi).

### Sinh trắc học (Face ID)

Package `local_auth` (3.0.2, pub.dev 2026-09-30) cho phép mở khóa bằng Face ID/vân tay; `flutter_secure_storage` có
`AndroidOptions.biometric`. Sách không dùng trong app mẫu (cần thiết bị thật để kiểm tra) — "Ideas for later".

## Lỗi và bẫy thường gặp

- **Lưu token/PIN trong shared_preferences** (dạng rõ) → ai có file sao lưu là đọc được.
- **Lưu PIN gốc** hoặc băm không muối → dò bảng (rainbow table).
- **So sánh hash bằng `==`** → về lý thuyết lộ thời gian; dùng constant-time.
- **Bộ đếm sai chỉ trong RAM** → tắt app mở lại là hết khóa.
- **Tin deep link** → mở màn hình / tham số không mong muốn; luôn kiểm tra.
- **Log dữ liệu nhạy cảm** (PIN, token, nội dung ghi chú) → lộ qua crash report.
- **Nhét API key bí mật vào app** rồi tin obfuscation che được.

## Tóm tắt

- Bí mật → Keychain/Keystore (`flutter_secure_storage`); cài đặt → shared_preferences; khóa server → server.
- PIN: muối + băm + constant-time + khóa tạm lưu bền + từ chối PIN yếu; tự khóa khi vào nền; guard bằng `redirect`.
- Kiểm tra deep link sau khi parse; `redact` log; obfuscation chỉ là lớp phụ.

## Bài tập (có lời giải)

**Bài 1.** Viết `isWeakPin(pin)`: yếu nếu mọi chữ số giống nhau (0000), là dãy tăng/giảm liên tiếp (1234, 9876), hoặc nằm trong danh
sách hay gặp. Dùng nó khi tạo PIN.

<details>
<summary>Lời giải</summary>

`examples/lib/features/auth/domain/pin_hasher.dart` (file `chapters/ch04/exercise_solution.dart` export lại):

```dart
bool isWeakPin(String pin) {
  if (pin.isEmpty) return true;
  if (pin.split('').toSet().length == 1) return true; // 0000, 1111
  final digits = pin.codeUnits.map((c) => c - 48).toList();
  bool stepBy(int step) {
    for (var i = 1; i < digits.length; i++) {
      if (digits[i] - digits[i - 1] != step) return false;
    }
    return true;
  }

  if (stepBy(1) || stepBy(-1)) return true; // 1234, 9876
  const common = {'1212', '1004', '2000', '6969', '4321', '1122', '2580', '0852'};
  return common.contains(pin);
}
```

`AuthController.createPin` gọi `isWeakPin` và báo "PIN quá dễ đoán, hãy chọn PIN khác" (test toàn app nhập 1234 và thấy thông
báo này). Danh sách "hay gặp" ở đây là ví dụ do sách chọn, không phải thống kê chính thức.
</details>

**Bài 2.** Vì sao bộ đếm số lần sai và thời điểm hết khóa được lưu trong `SecureStore` chứ không phải trong một biến của `AuthController`?

<details>
<summary>Lời giải</summary>

Nếu chỉ trong RAM, kẻ xấu vuốt tắt app rồi mở lại là bộ đếm về 0 → thử PIN không giới hạn. Lưu trong Keychain/Keystore thì bộ
đếm sống qua các lần mở app và khó bị sửa. Test "PinRepository … sai 5 lần thì khóa tạm; hết giờ khóa thì mở được" chứng minh:
lần sai thứ 5 trả `PinLocked(30 giây)`, nhập **đúng** PIN trong lúc khóa vẫn bị từ chối, sau 31 giây mới mở được.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30 (đọc file nguồn docs ở commit `ab59c61`):

- Security — https://docs.flutter.dev/security —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/security/index.md
- Obfuscate Dart code — https://docs.flutter.dev/deployment/obfuscate —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/deployment/obfuscate.md
- Navigation and routing (redirect / deep link) — https://docs.flutter.dev/ui/navigation —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/ui/navigation/index.md
- flutter_secure_storage 11.2.0 (README: Keychain/Keystore, web chỉ HTTPS/localhost, tắt auto backup): https://pub.dev/packages/flutter_secure_storage
- crypto 3.0.7: https://pub.dev/packages/crypto · local_auth: https://pub.dev/packages/local_auth
- Sách React Native trong repo: [Tập 3, Chương 4 — Security](../../react-native/vol3-nang-cao/04-security.md)
