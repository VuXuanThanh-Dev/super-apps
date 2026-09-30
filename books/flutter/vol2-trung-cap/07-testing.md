# Chương 7 — Testing: unit, widget, integration; fake và mock

## Mục tiêu

- Hiểu 3 loại test của Flutter và khi nào dùng loại nào (bảng đánh đổi của docs).
- Viết **unit test** cho repository/ViewModel bằng **fake**; dùng **mocktail** khi cần `verify` lời gọi.
- Viết **widget test** cho màn hình và cho **toàn app** (router + provider thật, dữ liệu giả).
- Viết và chạy **integration test** (`integration_test`) — trong sandbox đã chạy thật trên Chrome headless.
- Tránh các bẫy: thời gian giả, `pumpAndSettle` treo, State bị giữ giữa các lần pump.

## Giải thích đơn giản

Docs "Testing Flutter apps": app được test tốt có **nhiều** unit test và widget test, cộng **đủ** integration test cho các
luồng quan trọng. Bảng đánh đổi (tóm tắt từ docs):

| | Unit | Widget | Integration |
|---|---|---|---|
| Độ tin cậy | Thấp | Cao hơn | Cao nhất |
| Chi phí bảo trì | Thấp | Cao hơn | Cao nhất |
| Phụ thuộc | Ít | Nhiều hơn | Nhiều nhất |
| Tốc độ | Nhanh | Nhanh | Chậm |

| Angular | Flutter |
|---|---|
| Jasmine/Jest `describe/it` | `group` / `test` (package test, có trong flutter_test) |
| `TestBed` + component test | `testWidgets` + `WidgetTester` |
| `jasmine.createSpyObj` | **fake** tự viết, hoặc `mocktail` (`Mock`, `when`, `verify`) |
| `fakeAsync`/`tick` | `tester.pump(Duration)` (trong `testWidgets` thời gian là giả) |
| Cypress/Playwright E2E | `integration_test` (+ `flutter drive` trên web) |

Kiến trúc chính thức: "Test architectural components separately, and together" và "Make fakes for testing". App "Sổ Từ Vựng"
có: fake cho repository, TTS, nhắc nhở (`test/fakes/fakes.dart`); test data layer với **SQLite thật** qua FFI; test
ViewModel không cần widget; test toàn app bằng widget test; một integration test chạy app thật.

## Ví dụ

### Fake — bản cài đặt đơn giản trong bộ nhớ

```dart
class FakeTts implements TtsService {
  final List<String> spoken = [];
  double rate = 0.5;

  @override
  Future<void> speak(String text) async => spoken.add(text);

  @override
  Future<void> stop() async {}

  @override
  Future<void> setRate(double rate) async => this.rate = rate;
}
```

`FakeWordRepository` còn có "cổng" `searchGate` (một `Completer`) để giả lập kết quả về **chậm** — dùng cho test race condition.

### Unit test ViewModel: bỏ qua kết quả cũ (giống switchMap)

```dart
test('bỏ qua kết quả CŨ về muộn (giống switchMap)', () async {
  final repo = FakeWordRepository();
  final vm = WordListViewModel(repository: repo);
  await pumpEventQueue();
  final slow = Completer<void>();
  repo.searchGate = slow;
  final first = vm.search('b'); // chờ cổng
  repo.searchGate = null;
  await vm.search('inv'); // yêu cầu mới xong trước
  expect(vm.words.single.text, 'invoice');
  slow.complete();
  await first; // kết quả cũ ('budget') về sau → phải bị bỏ
  expect(vm.words.single.text, 'invoice');
  expect(vm.loading, isFalse);
});
```

`pumpEventQueue()` (từ package test) chờ các Future đang xếp hàng chạy xong — ở đây là lần tải đầu trong constructor.

### Mock bằng mocktail — kiểm tra lời gọi

```dart
class MockReminderService extends Mock implements ReminderService {}

// ...
when(() => reminders.isSupported).thenReturn(true);
when(reminders.requestPermission).thenAnswer((_) async => true);
when(() => reminders.scheduleDaily(any())).thenAnswer((_) async {});
// ...
verify(reminders.requestPermission).called(1);
verify(() => reminders.scheduleDaily(const TimeOfDay(hour: 20, minute: 0))).called(1);
```

mocktail không cần sinh code (khác mockito ở cookbook). Dùng mock khi **lời gọi** là điều cần kiểm tra; còn lại dùng fake.

### Widget test toàn app

```dart
Future<void> pumpVocab(WidgetTester tester, {String location = '/words', FakeTts? tts, /* ... */}) async {
  await tester.pumpWidget(
    VocabApp(
      key: UniqueKey(),
      initialLocation: location,
      dependencies: fakeDependencies(tts: tts, /* ... */ httpClient: MockClient((_) async => http.Response(sampleJson, 200))),
    ),
  );
  await tester.pumpAndSettle();
}

testWidgets('danh sách → tìm không dấu (debounce) → phát âm', (tester) async {
  final tts = FakeTts();
  await pumpVocab(tester, tts: tts);
  expect(find.text('3 từ'), findsOneWidget);
  await tester.enterText(find.byType(TextField), 'hoa don');
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
  expect(find.text('1 từ'), findsOneWidget);
  await tester.tap(find.byTooltip('Phát âm invoice'));
  expect(tts.spoken, ['invoice']);
});
```

`VocabApp` nhận `AppDependencies` — main.dart truyền bản thật, test truyền bản giả. Không có dòng nào trong UI biết sự khác biệt.

Kết quả thật (2026-09-30, `flutter test --reporter expanded test/app_test.dart`):

```text
00:00 +0: danh sách → tìm không dấu (debounce) → phát âm
00:01 +1: chi tiết: yêu thích, phát âm, tra từ điển online (MockClient)
00:02 +2: deep link /words/2 và id không tồn tại
00:02 +3: ôn tập: lật thẻ, "Đã nhớ" / "Chưa nhớ", hết lượt
00:02 +4: cài đặt: dark mode áp dụng cho cả app
00:03 +5: Lab mở được mọi chương
00:03 +6: All tests passed!
```

và `test/ui/viewmodels_test.dart`:

```text
00:00 +0: WordListViewModel tải lần đầu, tìm không dấu, lọc yêu thích
00:00 +1: WordListViewModel bỏ qua kết quả CŨ về muộn (giống switchMap)
00:00 +2: WordListViewModel lỗi → error, thử lại → hết lỗi
00:00 +3: ReviewViewModel (Command) lật thẻ, trả lời, hết lượt, thống kê
00:00 +4: SettingsViewModel theme đổi ngay và được lưu
00:00 +5: SettingsViewModel bật nhắc: xin quyền → đặt lịch (verify bằng mocktail)
00:00 +6: SettingsViewModel không có quyền / web → không đặt lịch, có thông báo
00:00 +7: SettingsViewModel tốc độ đọc được truyền cho TTS
00:00 +8: All tests passed!
```

(Đã bỏ các dòng `(setUpAll)`/`(tearDownAll)`.)

### Integration test — app thật, dữ liệu thật

`examples/integration_test/app_test.dart`:

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mở app, tìm "dam phan", mở chi tiết negotiate', (tester) async {
    await app.main();
    await tester.pumpAndSettle();
    expect(find.text('Sổ Từ Vựng'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'dam phan');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('negotiate'));
    await tester.pumpAndSettle();
    expect(find.text('(v) đàm phán'), findsOneWidget);
  });
}
```

Chạy trên iPhone/Android (cắm máy): `flutter test integration_test/app_test.dart` — **NOT RUN** (không có thiết bị).

Chạy trên **Chrome headless** theo docs "Integration testing" (cần `chromedriver` cùng phiên bản với Chrome, file
`test_driver/integration_test.dart`):

```bash
chromedriver --port=4444 &
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart \
  -d web-server --browser-name=chrome --headless --no-web-resources-cdn
```

Sách gói lệnh này trong `scripts/integration-web.sh`. Kết quả thật (2026-09-30, Chromium 141 + chromedriver 141, log đầy đủ:
[../logs/integration-web-vol2.txt](../logs/integration-web-vol2.txt)), vài dòng cuối:

```text
Launching integration_test/app_test.dart on Web Server in debug mode...
Waiting for connection from debug service on Web Server...         61.0s
All tests passed.
Application finished.
```

Test này chạy app **thật**: `main()` → SQLite Wasm → seed 24 từ → tìm "dam phan" → mở chi tiết.

## Đi sâu

### Chọn finder

`find.text`, `find.byType`, `find.byTooltip`, `find.byKey`, `find.bySemanticsLabel`, `find.widgetWithText(TextFormField, 'Email')`.
Ưu tiên finder theo thứ **người dùng thấy** (chữ, tooltip, nhãn) — test vừa kiểm tra chức năng vừa kiểm tra trợ năng.

### Thời gian giả

Trong `testWidgets`, `Timer` và `Future.delayed` chạy theo **đồng hồ giả**: phải `pump(duration)` để thời gian trôi.
Debounce 300 ms → `pump(const Duration(milliseconds: 300))`. Trong `test()` thường (không phải testWidgets), thời gian là thật.

### Ba bẫy sách đã gặp thật

1. **Pump lại app mà không đổi key** → State cũ (và router cũ) được giữ → test deep link thứ hai không đổi trang.
   Sửa: `key: UniqueKey()` (Tập 1, Chương 9).
2. **`pumpAndSettle` với animation lặp** (`PulsingDot`) → "pumpAndSettle timed out". Sửa: `pump(duration)` (Chương 5).
3. **Thiếu `setUpAll(() => registerFallbackValue(...))`** khi dùng `any()` của mocktail với kiểu tự định nghĩa → lỗi lúc chạy.

### Coverage

`flutter test --coverage` tạo `coverage/lcov.info` (đã có trong `.gitignore`). Tập 3 (CI/CD) chạy trong pipeline.

### Golden test

`matchesGoldenFile` so ảnh chụp widget với ảnh chuẩn — hữu ích cho UI ổn định, nhưng ảnh khác nhau giữa máy (font, nền tảng).
Sách không dùng.

## Lỗi và bẫy thường gặp

- **Gọi plugin thật trong widget test** → `MissingPluginException`. Tiêm fake.
- **Quên `await`** trước `tester.tap`/`pump` → kiểm tra quá sớm.
- **Test phụ thuộc thứ tự / dữ liệu dùng chung** → mỗi test tạo DB/fake mới (`setUp`).
- **Dùng mock cho mọi thứ** → test gắn chặt vào cách cài đặt; ưu tiên fake.
- **Integration test trên web cần chromedriver đúng phiên bản** với Chrome; lệch phiên bản → "session not created".

## Tóm tắt

- Nhiều unit + widget test, ít integration test (theo docs).
- Fake cho dữ liệu/dịch vụ; mocktail khi cần `verify`.
- Widget test toàn app: tiêm `AppDependencies` giả.
- Integration test chạy app thật; trên web dùng `flutter drive` + chromedriver (đã chạy thật trong sandbox).

## Bài tập (có lời giải)

**Bài 1.** Viết test chứng minh `WordListViewModel` hiện lỗi khi repository ném exception, và "Thử lại" xóa lỗi.

<details>
<summary>Lời giải</summary>

```dart
test('lỗi → error, thử lại → hết lỗi', () async {
  final repo = FakeWordRepository()..failNextSearch = Exception('ổ đĩa hỏng');
  final vm = WordListViewModel(repository: repo);
  await pumpEventQueue();
  expect(vm.error, isNotNull);
  await vm.refresh();
  expect(vm.error, isNull);
  expect(vm.words, hasLength(3));
});
```

Fake có "công tắc" `failNextSearch` — ném lỗi **một lần**. Trong app, `ErrorView` có nút "Thử lại" gọi `vm.refresh`.
</details>

**Bài 2.** Viết widget test cho luồng ôn tập: lật thẻ, trả lời "Đã nhớ" 1 lần và "Chưa nhớ" 2 lần, thấy "Bạn nhớ 1/3 từ",
và repository ghi đủ 3 lần ôn.

<details>
<summary>Lời giải</summary>

```dart
testWidgets('ôn tập: lật thẻ, "Đã nhớ" / "Chưa nhớ", hết lượt', (tester) async {
  final words = FakeWordRepository();
  await pumpVocab(tester, location: '/review', words: words);
  expect(find.text('Thẻ 1/3'), findsOneWidget);
  await tester.tap(find.text('Chạm để xem nghĩa'));
  await tester.pumpAndSettle(); // chờ animation lật xong
  expect(find.text('(n) ngân sách'), findsOneWidget);
  await tester.tap(find.text('Đã nhớ'));
  await tester.pumpAndSettle();
  for (var i = 0; i < 2; i++) {
    await tester.tap(find.text('Chạm để xem nghĩa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chưa nhớ'));
    await tester.pumpAndSettle();
  }
  expect(find.text('Bạn nhớ 1/3 từ'), findsOneWidget);
  expect(words.reviews, hasLength(3));
});
```

Test này nằm trong `test/app_test.dart` và pass (kết quả ở trên).
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30 (đọc file nguồn docs ở commit `ab59c61`):

- Testing Flutter apps (overview) — https://docs.flutter.dev/testing/overview —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/testing/overview.md
- Cookbook: Introduction to widget testing — https://docs.flutter.dev/cookbook/testing/widget/introduction —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/testing/widget/introduction.md
- Cookbook: Find widgets — https://docs.flutter.dev/cookbook/testing/widget/finders —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/testing/widget/finders.md
- Cookbook: Introduction to unit testing — https://docs.flutter.dev/cookbook/testing/unit/introduction —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/testing/unit/introduction.md
- Integration testing — https://docs.flutter.dev/testing/integration-tests —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/testing/integration-tests/index.md
- Case study — Testing each layer — https://docs.flutter.dev/app-architecture/case-study/testing —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/case-study/testing.md
- Architecture recommendations (testing) — https://docs.flutter.dev/app-architecture/recommendations —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/recommendations.md
- Chrome for Testing (chromedriver 141.0.7390.37): https://storage.googleapis.com/chrome-for-testing-public/141.0.7390.37/linux64/chromedriver-linux64.zip
- pub.dev: https://pub.dev/packages/mocktail
