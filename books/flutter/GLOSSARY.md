# GLOSSARY — Thuật ngữ Flutter (Anh → Việt)

| Thuật ngữ (English) | Giải thích tiếng Việt | Gần giống trong Angular / React Native |
|---|---|---|
| Flutter | Bộ công cụ UI của Google: một codebase Dart → app iOS, Android, web, desktop; tự vẽ mọi pixel | Angular (web) / React Native (mobile) |
| Dart | Ngôn ngữ lập trình của Flutter: có kiểu, null safety, biên dịch AOT/JIT/JS/Wasm | TypeScript |
| Widget | Mô tả bất biến (immutable) của một phần giao diện; "mọi thứ là widget" | Component |
| Widget tree (cây widget) | Các widget lồng nhau tạo thành cây | Cây component / DOM |
| StatelessWidget | Widget không có state riêng; chỉ phụ thuộc tham số | Component "dumb" / presentational |
| StatefulWidget | Widget có object `State` sống lâu, đổi bằng `setState` | Component có state |
| State (object) | Nơi giữ dữ liệu thay đổi và các hàm vòng đời `initState`, `dispose` | Class component + lifecycle hooks |
| `build()` | Hàm trả về cây widget ứng với state hiện tại | Template / render |
| `setState()` | Báo Flutter state đã đổi → build lại widget | `signal.set()` / `setState` của React |
| BuildContext | "Vị trí" của widget trong cây; dùng để tìm Theme, Navigator, provider ở trên | Injector hiện tại |
| Element | Đối tượng Flutter tạo từ widget để quản lý cây thật (ít khi dùng trực tiếp) | — |
| RenderObject | Đối tượng làm layout và vẽ (tầng thấp) | — |
| Key | Định danh giúp Flutter giữ đúng state khi danh sách đổi thứ tự | `track` trong `@for` / `key` của React |
| Constraints (ràng buộc) | Cha nói cho con kích thước tối thiểu/tối đa; con chọn kích thước trong đó | — (khác CSS) |
| Row / Column / Flex | Bố cục ngang / dọc | Flexbox `flex-direction` |
| Expanded / Flexible | Con chiếm phần còn lại của Row/Column | `flex: 1` |
| Material 3 | Hệ thiết kế của Google, mặc định trong Flutter | Angular Material |
| Cupertino | Bộ widget kiểu iOS | — |
| ThemeData / ColorScheme | Cấu hình màu, chữ toàn app; hỗ trợ sáng/tối | Theme SCSS / CSS variables |
| Sliver | Mảnh của vùng cuộn (SliverList, SliverAppBar) cho hiệu ứng cuộn tùy biến | Virtual scroll (CDK) |
| Navigator | Ngăn xếp (stack) màn hình kiểu mệnh lệnh: `push`/`pop` | `router.navigate` + history |
| go_router | Package định tuyến theo URL (declarative), docs chính thức khuyên dùng | Angular Router |
| Deep link | Mở app thẳng vào một màn hình bằng URL | Route URL |
| Redirect (go_router) | Hàm chuyển hướng trước khi hiển thị route | Route guard `canActivate` |
| ShellRoute / StatefulShellRoute | Route "khung" bọc các route con (tab bar) | Layout component + `<router-outlet>` |
| Future | Một giá trị sẽ có trong tương lai | Promise |
| Stream | Chuỗi nhiều giá trị theo thời gian | Observable (RxJS) |
| `async` / `await` | Viết code bất đồng bộ như đồng bộ | Giống TypeScript |
| Isolate | "Luồng" riêng có bộ nhớ riêng để chạy việc nặng | Web Worker |
| ChangeNotifier | Class có sẵn, gọi `notifyListeners()` để báo đổi | Service có state + Subject/Signal |
| ValueNotifier | ChangeNotifier giữ một giá trị | `signal()` |
| ListenableBuilder / ValueListenableBuilder | Widget build lại khi Listenable báo đổi | `async` pipe / đọc signal trong template |
| InheritedWidget | Cơ chế truyền dữ liệu xuống cây, con tìm lên bằng context | Hierarchical injector |
| provider | Package DI + lắng nghe ChangeNotifier, docs chính thức khuyên dùng | Angular DI (`providers`, `inject`) |
| MVVM | Model–View–ViewModel: View = widget, ViewModel = ChangeNotifier | Component + service/facade |
| Repository | Lớp che giấu nguồn dữ liệu (SQLite, API) khỏi UI | Data service |
| Command (pattern) | Đối tượng bọc một hành động bất đồng bộ + trạng thái chạy/lỗi | NgRx effect đơn giản |
| Hot reload | Nạp lại code khi đang chạy, giữ state (phím `r`) | HMR / Fast Refresh |
| Hot restart | Khởi động lại app, mất state (phím `R`) | Tải lại trang |
| pub / pub.dev | Trình quản lý package và kho package của Dart | npm / npmjs.com |
| `pubspec.yaml` / `pubspec.lock` | Khai báo phụ thuộc / khóa phiên bản | `package.json` / `package-lock.json` |
| Plugin | Package có code native (Swift/Kotlin) | Native module (RN) |
| Platform channel (MethodChannel) | Kênh gọi qua lại giữa Dart và code native | TurboModule / bridge (RN) |
| Pigeon | Công cụ sinh code type-safe cho platform channel | Codegen (RN) |
| Swift Package Manager (SwiftPM) | Trình quản lý phụ thuộc iOS, mặc định từ Flutter 3.44 | CocoaPods |
| AOT / JIT | Biên dịch trước (bản release) / biên dịch lúc chạy (debug, hot reload) | `ng build` / `ng serve` |
| Debug / Profile / Release mode | 3 chế độ build: gỡ lỗi / đo hiệu năng / phát hành | dev / prod build |
| DevTools | Bộ công cụ gỡ lỗi, đo hiệu năng của Flutter | Chrome DevTools, Angular DevTools |
| Impeller | Engine vẽ mới của Flutter (mặc định trên iOS) | — |
| CanvasKit / skwasm | Bộ vẽ của Flutter web (Skia biên dịch sang WebAssembly) | — |
| Semantics | Cây thông tin trợ năng (VoiceOver đọc); test cũng tìm theo semantics | ARIA |
| Widget test | Test một widget trong môi trường giả, không cần thiết bị | Component test (TestBed) |
| Integration test | Test cả app trên thiết bị/giả lập (package integration_test) | E2E (Playwright/Cypress) |
| Fake / Mock | Bản giả tự viết (fake) / đối tượng giả kiểm tra lời gọi (mock, mocktail) | `jasmine.createSpyObj` |
| sqflite | Plugin SQLite cho iOS/Android | expo-sqlite |
| shared_preferences | Lưu cặp key-value nhỏ | localStorage / AsyncStorage |
| TTS (text-to-speech) | Đọc chữ thành giọng nói (flutter_tts) | expo-speech |
| Local notification | Thông báo do app tự đặt lịch, không cần server | expo-notifications (local) |
| Keychain / Keystore | Kho bí mật của iOS / Android (flutter_secure_storage) | expo-secure-store |
| Obfuscation | Làm rối tên hàm/lớp trong bản build để khó dịch ngược | Minify |
| Flavor | Biến thể build (dev/staging/prod) | Angular environments |
| TestFlight | Kênh phát bản thử iOS của Apple | — |
