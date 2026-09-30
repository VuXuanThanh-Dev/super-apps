# Chương 6 — Device APIs: đọc to (text-to-speech) và thông báo cục bộ

## Mục tiêu

- Thêm **plugin** (package có code native) và hiểu cấu hình theo nền tảng.
- Đọc to từ vựng bằng `flutter_tts`: ngôn ngữ, tốc độ, chế độ im lặng trên iPhone.
- Đặt **thông báo cục bộ hằng ngày** bằng `flutter_local_notifications` + `timezone` + `flutter_timezone`:
  khởi tạo, **xin quyền đúng lúc**, `zonedSchedule`, hủy.
- Bọc plugin sau **interface** (`TtsService`, `ReminderService`) để test không cần thiết bị.
- Biết giới hạn trên web.

## Giải thích đơn giản

Plugin = package Dart + code native (Swift/Kotlin/JS). Bạn gọi hàm Dart; plugin chuyển lời gọi sang API của hệ điều hành
qua **platform channel** (Tập 3, Chương 3). Docs "Using packages" dạy cách thêm: `flutter pub add <tên>`. Hai package của
chương này **không** được docs nêu tên — đây là lựa chọn của sách (xem [STACK.md](../STACK.md) mục 5):

| Việc | Package (phiên bản ghim) | iOS dùng | Android dùng | Web |
|---|---|---|---|---|
| Đọc to | `flutter_tts 4.2.5` | AVSpeechSynthesizer | TextToSpeech | Web Speech API |
| Thông báo theo lịch | `flutter_local_notifications 22.3.1` | UserNotifications | AlarmManager + NotificationManager | Không có lịch |
| Múi giờ | `timezone 0.11.1`, `flutter_timezone 5.1.0` | — | — | — |

So với React Native (sách RN dùng `expo-speech`, `expo-notifications`): ý tưởng giống; khác là Flutter không có "Expo Go",
nên plugin nào cũng dùng được ngay khi build app (nhưng phải build lại app sau khi thêm plugin — hot reload không đủ).

**Nguyên tắc kiến trúc:** UI và ViewModel **không** gọi plugin trực tiếp. Chúng gọi interface; bản thật bọc plugin, bản giả dùng khi test.

## Ví dụ

### TTS — `examples/lib/data/services/tts_service.dart`

```dart
abstract interface class TtsService {
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> setRate(double rate);
}

class FlutterTtsService implements TtsService {
  FlutterTtsService([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _ready = false;

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setLanguage('en-US');
    await _tts.awaitSpeakCompletion(true);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      // Đọc được cả khi iPhone bật chế độ im lặng (README của flutter_tts: setIosAudioCategory).
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ]);
    }
    _ready = true;
  }

  @override
  Future<void> speak(String text) async {
    await _ensureReady();
    await _tts.stop();
    await _tts.speak(text);
  }
  // stop(), setRate() …
}
```

- `awaitSpeakCompletion(true)`: `speak` chỉ hoàn thành khi đọc xong → nút có thể hiện "Đang đọc…".
- Tốc độ đọc (`setSpeechRate`) được lưu trong Cài đặt (0.2–1.0).
- Widget dùng qua provider: `context.read<TtsService>().speak(word.text)`.

Nút phát âm tái sử dụng — `examples/lib/chapters/ch06/speak_button.dart`:

```dart
Future<void> _speak() async {
  setState(() => _speaking = true);
  try {
    await context.read<TtsService>().speak(widget.text);
  } finally {
    if (mounted) setState(() => _speaking = false);
  }
}
```

### Thông báo hằng ngày — `examples/lib/data/services/reminder_service.dart`

```dart
/// Lần tới của giờ [time] tính từ [now] (hôm nay nếu chưa qua, không thì ngày mai). Hàm thuần — dễ test.
tz.TZDateTime nextInstanceOf(TimeOfDay time, tz.TZDateTime now) {
  var scheduled = tz.TZDateTime(now.location, now.year, now.month, now.day, time.hour, time.minute);
  if (!scheduled.isAfter(now)) scheduled = scheduled.add(const Duration(days: 1));
  return scheduled;
}
```

Khởi tạo (một lần): nạp dữ liệu múi giờ, lấy múi giờ của máy, khởi tạo plugin **không xin quyền ngay**:

```dart
Future<void> _init() async {
  if (_initialized) return;
  tzdata.initializeTimeZones();
  final info = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(info.identifier));
  await _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // Không xin quyền ngay khi mở app; xin khi người dùng bật nhắc (requestPermission).
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
  );
  _initialized = true;
}
```

Xin quyền khi người dùng **bật** công tắc "Nhắc ôn hằng ngày", rồi đặt lịch lặp mỗi ngày:

```dart
@override
Future<void> scheduleDaily(TimeOfDay time) async {
  if (!isSupported) return;
  await _init();
  await _plugin.zonedSchedule(
    id: _id,
    title: 'Đến giờ ôn từ vựng',
    body: 'Dành 5 phút ôn lại các từ hôm nay nhé!',
    scheduledDate: nextInstanceOf(time, tz.TZDateTime.now(tz.local)),
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails('daily_review', 'Nhắc ôn hằng ngày'),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time, // lặp lại mỗi ngày cùng giờ
  );
}
```

Ở phiên bản 22, các hàm của plugin dùng **tham số có tên** (`initialize(settings: ...)`, `cancel(id: ...)`,
`zonedSchedule(id: ..., scheduledDate: ...)`) — nhiều bài viết cũ trên mạng dùng tham số vị trí sẽ không biên dịch.

`SettingsViewModel.setReminder` quyết định luồng: web → báo "Bản web không hỗ trợ nhắc theo lịch"; không có quyền →
báo hướng dẫn bật trong Cài đặt; có quyền → đặt lịch + lưu giờ.

### Cấu hình native đã thêm vào dự án (theo README của package)

- **iOS** — `ios/Runner/AppDelegate.swift`: `UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate`
  để hiện thông báo cả khi app đang mở.
- **Android** — `android/app/build.gradle.kts`: `isCoreLibraryDesugaringEnabled = true` +
  `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`; `AndroidManifest.xml`: quyền
  `RECEIVE_BOOT_COMPLETED` và hai `<receiver>` `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver`.
- **Build iOS/Android với cấu hình này: NOT RUN** (không có Xcode/Android SDK trong sandbox).

### Test không cần thiết bị

```dart
testWidgets('SpeakButton gọi TtsService lấy từ provider', (tester) async {
  final tts = FakeTts();
  await pumpApp(tester, Provider<TtsService>.value(value: tts, child: const SpeakButton(text: 'deadline')));
  await tester.tap(find.text('Đọc "deadline"'));
  await tester.pump();
  expect(tts.spoken, ['deadline']);
});
```

Test lịch nhắc dùng múi giờ thật `Asia/Ho_Chi_Minh` (19:00 → nhắc 20:00 cùng ngày; nhắc 19:00 → ngày mai). Kết quả thật
(2026-09-30):

```text
00:00 +0: Chương 6 — device APIs SpeakButton gọi TtsService lấy từ provider
00:00 +1: Chương 6 — device APIs Bài 1: nextWeeklyInstance — thứ Hai tới lúc 8:00
00:00 +2: All tests passed!
```

và trong `test/data/services_test.dart`: "nextInstanceOf (lịch nhắc hằng ngày) hôm nay nếu chưa tới giờ, ngày mai nếu đã qua" — pass.

**Đọc to và thông báo trên iPhone/Android thật: NOT RUN.** Trên web (Chromium headless) TTS không được kiểm tra bằng tai;
test chỉ chứng minh app gọi đúng service.

## Đi sâu

### Xin quyền: khi nào và thế nào?

- iOS: hỏi quyền **một lần**; người dùng từ chối thì chỉ bật lại được trong Settings. Vì vậy: chỉ hỏi khi người dùng chủ
  động bật nhắc, và giải thích trước lợi ích.
- Android 13+: cần quyền `POST_NOTIFICATIONS` (plugin khai báo sẵn), hỏi bằng `requestNotificationsPermission()`.
  Thông báo **đúng từng phút** (exact alarm) cần thêm quyền và chính sách của Play Store — nhắc ôn bài không cần chính xác
  tuyệt đối nên sách dùng `inexactAllowWhileIdle`.
- iOS chỉ giữ tối đa 64 thông báo đang chờ (README của package) — dùng lịch lặp (`matchDateTimeComponents`) thay vì đặt 365 thông báo.

### Múi giờ

`zonedSchedule` cần `TZDateTime`. Nếu quên `tz.setLocalLocation(...)`, `tz.local` mặc định là UTC → nhắc lệch 7 tiếng ở Việt Nam.

### TTS: giọng và ngôn ngữ

`getLanguages`, `getVoices`, `setVoice` cho phép chọn giọng (ví dụ en-US / en-GB). Máy có thể thiếu giọng; kiểm tra
`isLanguageAvailable('en-US')`. Trên web, danh sách giọng phụ thuộc trình duyệt.

### Web

`flutter_local_notifications` trên web không đặt lịch được (sách tắt tính năng qua `isSupported`). `flutter_tts` trên web
dùng Web Speech API của trình duyệt — Safari iOS có hỗ trợ nhưng hành vi cụ thể **UNVERIFIED**.

## Lỗi và bẫy thường gặp

- **Hot reload sau khi thêm plugin** → lỗi `MissingPluginException`. Dừng app và `flutter run` lại.
- **Xin quyền ngay khi mở app** → người dùng từ chối theo phản xạ.
- **Quên múi giờ** → giờ nhắc lệch.
- **Gọi plugin trong test** → `MissingPluginException`; dùng fake qua interface.
- **Không có desugaring** (Android) → build lỗi với flutter_local_notifications 22 (theo README; NOT RUN trong sandbox).
- **iPhone ở chế độ im lặng** → TTS không kêu nếu không đặt audio category `playback`.

## Tóm tắt

- Plugin = Dart + native. Bọc sau interface; test bằng fake.
- TTS: `flutter_tts` (`setLanguage`, `setSpeechRate`, `awaitSpeakCompletion`, iOS audio category).
- Nhắc hằng ngày: `timezone` + `flutter_timezone` + `zonedSchedule(... matchDateTimeComponents: time)`; xin quyền khi bật.
- Web: có TTS, không có lịch thông báo.

## Bài tập (có lời giải)

**Bài 1.** Viết `nextWeeklyInstance(time, weekday, now)` cho nhắc "mỗi thứ Hai 8:00" (dùng với
`DateTimeComponents.dayOfWeekAndTime`).

<details>
<summary>Lời giải</summary>

`examples/lib/chapters/ch06/exercise_solution.dart`:

```dart
tz.TZDateTime nextWeeklyInstance(TimeOfDay time, int weekday, tz.TZDateTime now) {
  var d = tz.TZDateTime(now.location, now.year, now.month, now.day, time.hour, time.minute);
  while (d.weekday != weekday || !d.isAfter(now)) {
    d = tz.TZDateTime(d.location, d.year, d.month, d.day + 1, time.hour, time.minute);
  }
  return d;
}
```

Tạo lại `TZDateTime` với `day + 1` (thay vì `add(Duration(days: 1))`) để giữ đúng giờ khi có đổi giờ mùa hè ở múi giờ
khác. Test: thứ Tư 30/9/2026 10:00 → thứ Hai 5/10/2026 8:00; thứ Tư 9:00 (đã qua) → thứ Tư tuần sau 7/10.
</details>

**Bài 2.** Vì sao `SettingsViewModel` nhận `ReminderService` (interface) thay vì `FlutterLocalNotificationsPlugin`? Viết một test
kiểm tra "bật nhắc → xin quyền đúng 1 lần → đặt lịch lúc 20:00".

<details>
<summary>Lời giải</summary>

Vì plugin cần thiết bị thật và hộp thoại quyền của hệ điều hành; trong test ta cần điều khiển kết quả (cho phép / từ chối /
web). Test dùng **mocktail** để kiểm tra lời gọi (`test/ui/viewmodels_test.dart`):

```dart
final reminders = MockReminderService();
when(() => reminders.isSupported).thenReturn(true);
when(reminders.requestPermission).thenAnswer((_) async => true);
when(() => reminders.scheduleDaily(any())).thenAnswer((_) async {});
final vm = SettingsViewModel(settings: SettingsRepository(MemoryStore()), reminders: reminders, tts: FakeTts());
await vm.setReminder(const TimeOfDay(hour: 20, minute: 0));
verify(reminders.requestPermission).called(1);
verify(() => reminders.scheduleDaily(const TimeOfDay(hour: 20, minute: 0))).called(1);
expect(vm.message, 'Sẽ nhắc lúc 20:00 mỗi ngày');
```

`registerFallbackValue(const TimeOfDay(hour: 0, minute: 0))` (trong `setUpAll`) cần cho `any()` với kiểu không phải cơ bản.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30:

- Using packages — https://docs.flutter.dev/packages-and-plugins/using-packages —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/packages-and-plugins/using-packages.md
- Platform channels (plugin hoạt động thế nào) — https://docs.flutter.dev/platform-integration/platform-channels —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/platform-integration/platform-channels.md
- flutter_tts 4.2.5 (README đọc trong pub cache): https://pub.dev/packages/flutter_tts
- flutter_local_notifications 22.3.1 (README: iOS setup, Android Gradle/Manifest, giới hạn 64 thông báo iOS): https://pub.dev/packages/flutter_local_notifications
- timezone 0.11.1: https://pub.dev/packages/timezone · flutter_timezone 5.1.0: https://pub.dev/packages/flutter_timezone
- mocktail 1.0.5: https://pub.dev/packages/mocktail
