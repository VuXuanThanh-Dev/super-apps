# Chương 3 — HTTP và JSON

## Mục tiêu

- Gọi API REST bằng package `http` (docs chính thức dùng package này trong Learning Pathway và cookbook).
- Chuyển JSON ↔ model Dart **bằng tay** (`jsonDecode`, `fromJson`), ép kiểu an toàn.
- Xử lý lỗi mạng: mã trạng thái, timeout, JSON hỏng, mất kết nối — trả về `Result` thay vì ném lỗi lung tung.
- Test HTTP **không cần mạng** bằng `MockClient`.
- Biết khi nào nên dùng code generation (`json_serializable`).

## Giải thích đơn giản

| Angular | Flutter |
|---|---|
| `HttpClient.get<T>(url)` trả `Observable<T>` | `http.Client().get(uri)` trả `Future<Response>` |
| Interceptor | Bọc `http.Client` (class con của `BaseClient`) |
| Kiểu `T` chỉ là "lời hứa" của TypeScript | Dart kiểm tra kiểu **lúc chạy**: phải ép `as String` đúng, sai là lỗi |
| `HttpTestingController` | `MockClient((request) async => Response(...))` |

App "Sổ Từ Vựng" có nút **"Tra từ điển online"** gọi Free Dictionary API
(`https://api.dictionaryapi.dev/api/v2/entries/en/<từ>`, định dạng theo README của dự án
`meetDeveloper/freeDictionaryAPI`). App vẫn **offline-first**: dữ liệu chính nằm trong SQLite (Chương 4); mạng chỉ là phần thêm.

## Ví dụ

### Model từ JSON

`examples/lib/data/services/dictionary_client.dart`:

```dart
class Definition {
  const Definition({required this.partOfSpeech, required this.definition, this.example});

  final String partOfSpeech;
  final String definition;
  final String? example;

  /// Ép kiểu cẩn thận: JSON từ mạng có thể thiếu trường.
  factory Definition.fromJson(String partOfSpeech, Map<String, Object?> json) => Definition(
    partOfSpeech: partOfSpeech,
    definition: json['definition'] as String? ?? '',
    example: json['example'] as String?,
  );
}
```

JSON của API là mảng lồng nhau: entry → `meanings[]` → `definitions[]`. Dùng collection `for` lồng nhau để "làm phẳng":

```dart
List<Definition> parseDefinitions(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! List) throw const FormatException('Cần một mảng JSON');
  return [
    for (final entry in decoded.whereType<Map<String, Object?>>())
      for (final meaning in (entry['meanings'] as List? ?? const []).whereType<Map<String, Object?>>())
        for (final d in (meaning['definitions'] as List? ?? const []).whereType<Map<String, Object?>>())
          Definition.fromJson(meaning['partOfSpeech'] as String? ?? '?', d),
  ];
}
```

`whereType<Map<String, Object?>>()` bỏ qua phần tử sai kiểu thay vì crash.

### Client trả về `Result`

```dart
class DictionaryClient {
  DictionaryClient({http.Client? client, this.timeout = const Duration(seconds: 8)})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  static Uri uriFor(String word) =>
      Uri.https('api.dictionaryapi.dev', '/api/v2/entries/en/${Uri.encodeComponent(word.trim())}');

  Future<Result<List<Definition>>> lookup(String word) async {
    try {
      final response = await _client.get(uriFor(word)).timeout(timeout);
      if (response.statusCode == 404) return const Result.error(DictionaryException('Không tìm thấy từ này'));
      if (response.statusCode != 200) {
        return Result.error(DictionaryException('Lỗi máy chủ (${response.statusCode})'));
      }
      return Result.ok(parseDefinitions(utf8.decode(response.bodyBytes)));
    } on TimeoutException {
      return const Result.error(DictionaryException('Hết thời gian chờ'));
    } on FormatException {
      return const Result.error(DictionaryException('Dữ liệu trả về không đúng định dạng'));
    } on http.ClientException catch (e) {
      return Result.error(DictionaryException('Không kết nối được: ${e.message}'));
    }
  }
}
```

- `Result` (sealed class `Ok`/`Error`) là mẫu trong docs chính thức (`app-architecture/design-patterns/result`);
  file `lib/utils/result.dart` lấy nguyên mẫu đó (giấy phép BSD, có ghi công).
- `utf8.decode(response.bodyBytes)` thay vì `response.body`: an toàn khi server không gửi `charset` (chữ có dấu).
- `http.Client` được **tiêm qua constructor** → test thay bằng `MockClient` (docs cookbook "Mock dependencies" làm
  tương tự, nhưng dùng mockito + code generation; sách dùng `MockClient` có sẵn trong package http).

### ViewModel dùng `switch` trên `Result`

Trong `WordDetailScreen`, kết quả của `vm.lookup` (một `Command0<List<Definition>>`) được hiển thị bằng `switch`:

```dart
switch (vm.lookup.result) {
  null => const SizedBox.shrink(),
  Ok(:final value) when value.isEmpty => const Text('Từ điển không có định nghĩa.'),
  Ok(:final value) => Column(/* 3 định nghĩa đầu */),
  Error(:final error) => Text('Không tra được: $error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
},
```

### Test với MockClient — không cần mạng

```dart
test('200: tách định nghĩa, gọi đúng URL', () async {
  Uri? called;
  final client = DictionaryClient(
    client: MockClient((req) async {
      called = req.url;
      return http.Response(sampleJson, 200);
    }),
  );
  final result = await client.lookup('negotiate');
  expect(called.toString(), 'https://api.dictionaryapi.dev/api/v2/entries/en/negotiate');
  switch (result) {
    case Ok(:final value):
      expect(value, hasLength(2));
      expect(value.first.partOfSpeech, 'verb');
    case Error():
      fail('không mong đợi lỗi: $result');
  }
});
```

Kết quả thật (2026-09-30, `flutter test --reporter expanded test/data/services_test.dart`, phần HTTP):

```text
00:00 +3: DictionaryClient (HTTP + JSON, MockClient) 200: tách định nghĩa, gọi đúng URL
00:00 +4: DictionaryClient (HTTP + JSON, MockClient) 404, 500, JSON hỏng, mất mạng → Result.error với thông báo tiếng Việt
00:00 +5: DictionaryClient (HTTP + JSON, MockClient) hết thời gian chờ
00:00 +6: All tests passed!
```

**Gọi API thật: NOT RUN** — sandbox chặn `api.dictionaryapi.dev` (proxy từ chối kết nối). Định dạng JSON lấy từ README
chính thức của dự án (đã mở); hành vi server thật (ví dụ mã 404 cho từ không có) là **UNVERIFIED**.

## Đi sâu

### Quyền mạng trên từng nền tảng

Docs `data-and-backend/networking`: Android phải khai báo `<uses-permission android:name="android.permission.INTERNET" />`
trong `AndroidManifest.xml` (bản debug tự có; bản release cần khai báo — dự án Tập 2 đã thêm). macOS cần entitlement
mạng. iOS không cần khai báo cho HTTPS.

### Code generation: khi nào?

Docs `serialization/json`: **viết tay** cho dự án nhỏ; **code generation** (`json_serializable`, `built_value`) cho dự án
vừa và lớn — đổi lại phải chạy `build_runner`. Kiến trúc chính thức còn gợi ý `freezed` cho model bất biến. Sách viết tay
để thấy rõ cơ chế và để build không cần bước sinh code. App TOEIC có ít model (từ, cụm từ, bài đọc) → viết tay là đủ.

### `dio` hay `http`?

`dio` (5.11.1, 2026-09-04) có interceptor, hủy request, upload tiến độ. `http` đơn giản và là lựa chọn của docs. Sách dùng `http`.

### Hủy request khi rời màn hình

`http` không hủy request đang chạy được, nhưng ta có thể **bỏ qua kết quả** (như `requestId` ở Chương 2) hoặc dùng
`Command` (chặn gọi trùng). Khi ViewModel bị dispose, không `notifyListeners()` nữa.

## Lỗi và bẫy thường gặp

- **`json['x'] as String` khi server trả `null`** → `TypeError`. Dùng `as String?` + giá trị mặc định.
- **Dùng `response.body` với tiếng Việt** mà server không gửi charset → lỗi font chữ (mojibake). Dùng `utf8.decode(bodyBytes)`.
- **Nối chuỗi URL bằng tay** → quên encode ký tự đặc biệt. Dùng `Uri.https(host, path, query)`.
- **Tạo `http.Client()` mới cho mỗi request** mà không `close()` → tốn kết nối. Tạo một lần, tiêm vào.
- **Ném exception từ repository lên thẳng UI** → màn hình đỏ. Bắt ở data layer, trả `Result`.
- **Quên timeout** → spinner quay mãi khi mạng chập chờn.

## Tóm tắt

- `http` + `jsonDecode` + `fromJson` viết tay; ép kiểu an toàn (`as T?`, `whereType`).
- Bắt lỗi ở data layer, trả `Result<T>`; View dùng `switch` để hiển thị.
- Tiêm `http.Client` → test bằng `MockClient`, không cần mạng.

## Bài tập (có lời giải)

**Bài 1.** Từ JSON của Free Dictionary API, viết `firstAudioUrl(body)` trả về link mp3 phát âm đầu tiên **không rỗng**.
API trả `"audio": "//ssl.gstatic.com/..."` (thiếu `https:`) — hãy thêm vào. Không có thì trả `null`.

<details>
<summary>Lời giải</summary>

`examples/lib/chapters/ch03/exercise_solution.dart`:

```dart
String? firstAudioUrl(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! List) return null;
  for (final entry in decoded.whereType<Map<String, Object?>>()) {
    for (final p in (entry['phonetics'] as List? ?? const []).whereType<Map<String, Object?>>()) {
      final audio = p['audio'] as String? ?? '';
      if (audio.isEmpty) continue;
      return audio.startsWith('//') ? 'https:$audio' : audio;
    }
  }
  return null;
}
```

Test (`ch03_ch04_test.dart`): JSON mẫu có một audio rỗng và một `//ssl.example/negotiate.mp3` → nhận
`https://ssl.example/negotiate.mp3`; `{}` hoặc `phonetics` rỗng → `null`.
</details>

**Bài 2.** Vì sao `DictionaryClient` nhận `http.Client?` trong constructor thay vì tự tạo `http.Client()` bên trong hàm `lookup`?

<details>
<summary>Lời giải</summary>

(1) **Test**: truyền `MockClient` để kiểm tra URL, mã 404/500, JSON hỏng, mất mạng, timeout — không cần mạng thật
(4 test trong `services_test.dart` làm đúng vậy). (2) **Tái sử dụng kết nối**: một client dùng chung giữ kết nối
HTTP keep-alive. (3) **Mở rộng**: có thể truyền một client bọc thêm header/log (giống interceptor). Đây là DI bằng
constructor — cùng tinh thần "Use dependency injection" của docs kiến trúc.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30:

- Tutorial: Make HTTP requests — https://docs.flutter.dev/learn/pathway/tutorial/http-requests —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/learn/pathway/tutorial/http-requests.md
- Cookbook: Fetch data from the internet — https://docs.flutter.dev/cookbook/networking/fetch-data —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/networking/fetch-data.md
- Networking — https://docs.flutter.dev/data-and-backend/networking —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/data-and-backend/networking.md
- JSON and serialization — https://docs.flutter.dev/data-and-backend/serialization/json —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/data-and-backend/serialization/json.md
- Cookbook: Mock dependencies using Mockito — https://docs.flutter.dev/cookbook/testing/unit/mocking —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/testing/unit/mocking.md
- Design pattern: Result — https://docs.flutter.dev/app-architecture/design-patterns/result —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/design-patterns/result.md
- Mã nguồn mẫu Result (BSD): https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/examples/app-architecture/result/lib/result.dart
- Free Dictionary API README: https://github.com/meetDeveloper/freeDictionaryAPI
- pub.dev: https://pub.dev/packages/http · https://pub.dev/packages/dio · https://pub.dev/packages/json_serializable
