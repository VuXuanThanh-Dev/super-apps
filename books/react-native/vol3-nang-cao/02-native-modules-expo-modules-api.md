# Chương 2 — Native modules với Expo Modules API

## Mục tiêu

- Biết khi nào cần viết code native (Swift/Kotlin) và khi nào không.
- Tạo một **local Expo module** bằng `create-expo-module --local`.
- Viết API TypeScript an toàn: dùng native khi có, **dự phòng bằng JS** khi chạy trong Expo Go/web/test.
- Hiểu **development build** và cách chạy module native trên máy thật.

## Giải thích đơn giản

Expo SDK đã có sẵn rất nhiều module (camera, vị trí, lưu trữ...). Chỉ viết native khi:

- Cần API của iOS/Android mà chưa có thư viện (ví dụ SDK riêng của ngân hàng, thiết bị Bluetooth đặc thù).
- Cần hiệu năng cao ở tầng native (xử lý ảnh, mã hóa lớn).

**Expo Modules API** cho bạn viết module bằng Swift và Kotlin với cú pháp ngắn gọn (DSL — ngôn
ngữ khai báo): `Name`, `Constant`, `Function`, `AsyncFunction`, `Events`, `View`... Bên dưới, module
chạy trên JSI của New Architecture.

**Quan trọng:** Expo Go chỉ chứa module có sẵn của Expo. Module bạn tự viết **không có** trong Expo Go
→ cần **development build** ("Expo Go của riêng bạn").

## Ví dụ

### 1. Tạo module

Lệnh thật đã chạy (2026-09-28) trong `vol3-nang-cao/examples`:

```bash
CI=1 npx -y create-expo-module@latest modules/text-stats --local --barrel \
  --name TextStats --description "Dem tu va ky tu (vi du sach)" \
  --package dev.nobin.textstats -p apple android --features Function Constant
```

Output (trích):

```text
✔ Downloaded module template from npm registry.
✔ Created the module from template files
✔ Generated barrel file (index.ts)
✅ Successfully created Expo module in modules/modules/text-stats
```

(Công cụ tạo thêm một cấp `modules/` thừa; chúng tôi chuyển thư mục về `modules/text-stats`.
Template có license MIT của Expo — file `modules/text-stats/LICENSE` được giữ nguyên.)

Cấu trúc:

```text
modules/text-stats/
  expo-module.config.json        # khai báo module cho iOS ("apple") và Android
  ios/TextStatsModule.swift      # code Swift
  ios/TextStats.podspec
  android/build.gradle
  android/src/main/java/dev/nobin/textstats/TextStatsModule.kt
  src/TextStatsModule.ts         # nối JS ↔ native
  src/jsFallback.ts              # bản JavaScript dự phòng
  index.ts                       # API công khai
```

### 2. Code native

Swift (`ios/TextStatsModule.swift`):

```swift
public class TextStatsModule: Module {
  public func definition() -> ModuleDefinition {
    Name("TextStats")

    Constant("platform") {
      "ios"
    }

    Function("stats") { (text: String) -> [String: Int] in
      let words = text.split(whereSeparator: { $0.isWhitespace }).count
      // unicodeScalars = code point, cùng cách đếm với Array.from(text) bên JS
      return ["words": words, "characters": text.unicodeScalars.count]
    }
  }
}
```

Kotlin (`android/.../TextStatsModule.kt`):

```kotlin
class TextStatsModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("TextStats")

    Constant("platform") {
      "android"
    }

    Function("stats") { text: String ->
      val words = text.trim().split(Regex("\\s+")).filter { it.isNotEmpty() }.size
      mapOf("words" to words, "characters" to text.codePointCount(0, text.length))
    }
  }
}
```

**NOT RUN:** sandbox không có Xcode/Android SDK nên chưa biên dịch Swift/Kotlin. Cú pháp theo đúng
template do `create-expo-module` sinh ra và tài liệu "Tutorial: Creating a native module".

### 3. Cầu nối TypeScript có dự phòng

`src/TextStatsModule.ts`:

```ts
import { NativeModule, requireOptionalNativeModule } from 'expo';

declare class TextStatsNativeModule extends NativeModule<Record<string, never>> {
  platform: string;
  stats(text: string): TextStatsResult;
  reverse(text: string): string;
}

// requireOptionalNativeModule trả về null khi module native không có (ví dụ trong Expo Go),
// thay vì ném lỗi như requireNativeModule. Nhờ vậy app vẫn chạy trong Expo Go.
export default requireOptionalNativeModule<TextStatsNativeModule>('TextStats');
```

Template gốc dùng `requireNativeModule` (ném lỗi nếu thiếu). Sách đổi sang
`requireOptionalNativeModule` (có trong `expo` SDK 57) để cùng một code chạy được cả trong Expo Go.

`index.ts`:

```ts
export function textStats(text: string): TextStatsResult & { source: StatsSource } {
  if (NativeTextStats) return { ...NativeTextStats.stats(text), source: 'native' };
  return { ...statsInJs(text), source: 'js' };
}
```

`src/jsFallback.ts`:

```ts
export function statsInJs(text: string): TextStatsResult {
  const words = text.trim() === '' ? 0 : text.trim().split(/\s+/).length;
  return { words, characters: Array.from(text).length };
}
```

### 4. Test cả hai nhánh

```ts
it('có module native (giả lập development build) → gọi native', async () => {
  jest.resetModules();
  const stats = jest.fn(() => ({ words: 42, characters: 99 }));
  jest.doMock('expo', () => ({
    ...jest.requireActual('expo'),
    requireOptionalNativeModule: () => ({ platform: 'ios', stats }),
  }));
  const mod = require('../../../modules/text-stats');
  expect(mod.isNativeAvailable()).toBe(true);
  expect(mod.textStats('abc')).toEqual({ words: 42, characters: 99, source: 'native' });
});
```

Kết quả (2026-09-28):

```text
PASS src/chapters/ch02/nativeModule.test.tsx
    ✓ bản JS đếm từ và ký tự theo code point (emoji = 1)
    ✓ bài tập: reverseText không làm vỡ emoji (bản JS)
    ✓ không có module native (như Expo Go) → dùng JS
    ✓ có module native (giả lập development build) → gọi native
```

Trong app: **Cài đặt → Lab → "Ch.2 — Native module text-stats"**. Trong Expo Go sẽ hiện
"Nguồn: JavaScript" (**NOT RUN** trên máy).

## Đi sâu

### Chạy module native thật (development build)

```bash
# Cách 1: build trên máy (cần Mac + Xcode cho iOS)
npx expo run:ios
# Cách 2: build trên cloud bằng EAS (không cần Mac), rồi cài lên iPhone
npx eas-cli@latest build --profile development --platform ios
```

Profile `development` trong `examples/eas.json` có `"developmentClient": true`. Khi đó cần cài thêm
`expo-dev-client` (**chưa cài** trong dự án để app vẫn tối giản cho Expo Go). Thư mục `ios/` và
`android/` được sinh ra (Continuous Native Generation) và bị `.gitignore` — không sửa tay.

### Các khối của Expo Modules API

| Khối | Dùng khi |
|---|---|
| `Constant("x") { ... }` | Giá trị không đổi (đọc như thuộc tính) |
| `Function("f") { ... }` | Hàm đồng bộ, nhanh |
| `AsyncFunction("f") { ... }` | Việc lâu → trả Promise |
| `Events("onChange")` + `sendEvent` | Native báo sự kiện lên JS |
| `View(...)` | Component giao diện native |

### Inline modules (thử nghiệm)

Tài liệu Expo nói **inline modules** (từ SDK 56, trạng thái *experimental*) cho phép đặt file Swift/Kotlin
ngay trong thư mục app mà không cần package riêng. Sách dùng local module (ổn định hơn).

### Mock mặc định cho module

Tài liệu "Mocking native calls" của Expo: đặt file mock trong thư mục `mocks` của module để jest-expo tự
dùng khi test. Sách dùng cách đơn giản hơn: bản JS dự phòng + `jest.doMock('expo', ...)`.

## Lỗi và bẫy thường gặp

- **Dùng `requireNativeModule` rồi chạy trong Expo Go** → lỗi "Cannot find native module".
- **Sửa code native rồi chờ Fast Refresh** → không có tác dụng; phải build lại app.
- **Đếm ký tự khác nhau giữa iOS/Android/JS**: Swift `String.count` đếm grapheme, Kotlin `length` đếm
  UTF-16, JS `length` đếm UTF-16. Chọn **một** quy ước (sách chọn code point) và test nó.
- **Tách chuỗi bằng `split('')`** → vỡ emoji (xem bài tập).
- **Commit thư mục `ios/`, `android/` sinh tự động** → xung đột khi nâng SDK.

## Tóm tắt

- Chỉ viết native khi thật cần; Expo Modules API giúp viết Swift/Kotlin ngắn gọn.
- `requireOptionalNativeModule` + bản JS dự phòng = một code cho Expo Go và development build.
- Module tự viết cần development build (`npx expo run:ios` hoặc EAS Build).

## Bài tập (có lời giải)

**Bài 1.** Thêm hàm `reverse(text)` vào module: Swift, Kotlin và bản JS dự phòng. Đảo chuỗi không
được làm vỡ emoji (`'ab👋'` → `'👋ba'`).

<details>
<summary>Lời giải</summary>

Swift: `Function("reverse") { (text: String) -> String in String(text.reversed()) }`

Kotlin:

```kotlin
Function("reverse") { text: String ->
  val cps = text.codePoints().toArray().reversedArray()
  String(cps, 0, cps.size)
}
```

JS (`src/jsFallback.ts`):

```ts
export function reverseInJs(text: string): string {
  return Array.from(text).reverse().join('');
}
```

Test:

```ts
expect(reverseText('ab👋')).toBe('👋ba');
expect('ab👋'.split('').reverse().join('')).not.toBe('👋ba'); // cách sai: tách theo UTF-16
```

Lưu ý: Swift `reversed()` đảo theo grapheme (ký tự hiển thị), Kotlin đảo theo code point — với emoji
ghép (ví dụ 👨‍👩‍👧) hai bên có thể khác nhau. Phần native **NOT RUN**.
</details>

**Bài 2.** Biến `stats` thành bất đồng bộ cho văn bản rất dài. Cần đổi những gì?

<details>
<summary>Lời giải</summary>

1. Native: đổi `Function("stats")` thành `AsyncFunction("stats")` (Swift/Kotlin giữ nguyên thân hàm).
2. TypeScript: `stats(text: string): Promise<TextStatsResult>`.
3. `textStats` trở thành `async` và trả Promise; bản JS: `async function statsInJs(...)`.
4. Component gọi trong `useEffect` hoặc dùng TanStack Query.

(Lời giải tham khảo; code dự án giữ bản đồng bộ.)
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- Expo Modules — Get started (`create-expo-module --local`): https://github.com/expo/expo/blob/main/docs/pages/modules/get-started.mdx
- Expo Modules — Tutorial: Creating a native module: https://github.com/expo/expo/blob/main/docs/pages/modules/native-module-tutorial.mdx
- Expo Modules — Module API reference: https://github.com/expo/expo/blob/main/docs/pages/modules/module-api.mdx
- Expo Modules — Inline modules tutorial (experimental): https://github.com/expo/expo/blob/main/docs/pages/modules/inline-modules-tutorial.mdx
- Expo Modules — Mocking native calls: https://github.com/expo/expo/blob/main/docs/pages/modules/mocking.mdx
- Expo — Development builds introduction: https://github.com/expo/expo/blob/main/docs/pages/develop/development-builds/introduction.mdx
- Gói npm `create-expo-module` (chạy trực tiếp bằng npx): https://www.npmjs.com/package/create-expo-module
