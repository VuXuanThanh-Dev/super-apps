# TOEIC 900 — app học từ vựng (Flutter)

App học riêng cho hai cuốn sách ở gốc repo (*TOEIC 900 — Word Families & Collocations*, Tập 1 + Tập 2).
Đây là bản **Flutter** của app React Native ở [`apps/toeic/`](../toeic/) (Task 5), cùng tính năng.

**Ý tưởng đơn giản:** mọi từ trên mọi màn hình đều **chạm được**. Chạm vào → popup hiện nghĩa tiếng Anh +
tiếng Việt, IPA, nút loa (đọc to), họ từ, collocation và câu ví dụ — **không cần mạng**.

**Ví dụ:** trong bài đọc, bạn chạm vào *"negotiations"* → popup mở *negotiation (n)*, ghi
"negotiations → negotiation", họ từ *negotiate · negotiator · negotiable*, và các collocation.
Bấm **Save to my list** để ôn lại sau (flashcard, quiz, nhắc hằng ngày).

## Tính năng

| # | Tính năng | Ở đâu |
|---|---|---|
| ★ | Chạm từ bất kỳ → popup (định nghĩa, nghĩa Việt, IPA, text-to-speech, họ từ, collocation, ví dụ, Save). Dạng từ → từ gốc (*ran → run*, *companies → company*, *company's*, *don't*). Từ lạ → "not found". Chạm từ trong popup → mở tiếp trong popup (có nút Back). | mọi màn hình chữ |
| 1 | Từ vựng theo unit/chủ đề + tìm kiếm (tiếng Anh, tiếng Việt có/không dấu) | tab **Words** |
| 2 | Flashcard lặp lại ngắt quãng (SM-2), 4 nút Again/Hard/Good/Easy có số ngày | tab **Practice** |
| 3 | Quiz: nghĩa, điền chỗ trống, dạng từ (word family), nối collocation, nghe | tab **Practice** |
| 4 | Bài đọc ngắn kiểu TOEIC (mỗi unit một bài, có câu hỏi A–D) | tab **Read** |
| 5 | Hội thoại nhập vai (văn phòng, họp, email, điện thoại) — che câu của vai bạn để luyện nói | tab **Read** |
| 6 | Từ đã lưu + nhắc ôn hằng ngày (thông báo cục bộ — local notification) | tab **Saved** |
| 7 | Tiến độ: đã thuộc, cần ôn, chuỗi ngày (streak), 7 ngày qua, từ hay sai | tab **Home** |
| 8 | Chế độ tối (System / Light / Dark) | Home → ⚙ Settings |

### Vì sao SM-2 (không phải FSRS)?
Giống Task 5: SM-2 ngắn (~30 dòng), dễ hiểu, dễ test, không cần dữ liệu huấn luyện. FSRS xếp lịch tốt hơn
một chút nhưng cần bộ trọng số nên được "fit" theo lịch sử ôn của chính bạn; với một người học và vài trăm
thẻ, SM-2 là đủ và dễ đoán. Code ở `lib/domain/srs/sm2.dart` (test case giống hệt Task 5).

## Phiên bản (ghim — pinned, kiểm tra 2026-09-30)

Dùng đúng bảng trong [`books/flutter/STACK.md`](../../books/flutter/STACK.md) (mục 5). `pubspec.lock` được commit.

| Thành phần | Phiên bản |
|---|---|
| Flutter / Dart | **3.47.5** stable / **3.13.4** (`sdk: ^3.13.4`) |
| provider · go_router | 6.1.5+1 · 18.0.2 |
| sqflite · sqflite_common_ffi_web · sqlite3 · path | 2.4.4 · 1.2.0 · 3.6.0 · 1.9.1 |
| shared_preferences | 2.5.5 |
| flutter_tts | 4.2.5 |
| flutter_local_notifications · timezone · flutter_timezone | 22.3.1 · 0.11.1 · 5.1.0 |
| dev: flutter_lints · sqflite_common_ffi | 6.0.0 · 2.4.3 |
| Công cụ dữ liệu (Python, dùng lại của Task 5) | Python 3.11, pymupdf 1.28.2, cmudict 1.1.3, nltk 3.10.3 |
| Smoke test web | Node 22.22.2, Playwright 1.56.1 (Chromium 1194) |

(`http` và `mocktail` trong STACK.md không dùng: app hoàn toàn offline, và test chỉ cần fake viết tay.)

## Chạy trên iPhone — nói thật

**Không có "Expo Go" cho Flutter.** Flutter biên dịch Dart thành mã máy cho iOS, nên muốn cài app thật lên
iPhone phải build bằng **Xcode trên máy Mac**. Có 3 cách:

| Cách | Cần gì | Ghi chú |
|---|---|---|
| **A. Mac + Xcode + cáp** (khuyên dùng) | Máy Mac, Xcode, Apple ID **miễn phí** | App native đầy đủ: SQLite, đọc to, thông báo nhắc hằng ngày |
| **B. Bản web trên Safari** | Chỉ cần máy tính + iPhone cùng Wi-Fi | Không cần Mac. Nhưng là **web**: không có thông báo theo lịch |
| **C. TestFlight** | Mac + **Apple Developer Program ($99/năm)** | Cài qua app TestFlight như app thật |

Trạng thái trong PR này: **Chạy trên iPhone: NOT RUN** (sandbox không có Mac/iPhone). Đã chạy: analyze,
141 test, `flutter build web`, và smoke test bản web trong Chromium headless (xem mục "Kiểm tra").

### Cách A — Mac + Xcode + Apple ID miễn phí (theo docs chính thức "Set up iOS development")

1. Cài Flutter 3.47.5 trên Mac (docs: https://docs.flutter.dev/install) và **Xcode** bản mới nhất.
2. Chạy trong Terminal:
   ```bash
   sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
   sudo xcodebuild -license          # đọc và đồng ý
   xcodebuild -downloadPlatform iOS
   ```
3. Cài **CocoaPods** (docs bước "Install CocoaPods") — cần cho plugin có mã native iOS nếu plugin chưa hỗ trợ
   Swift Package Manager. (Plugin nào của app đã hỗ trợ SwiftPM: **UNVERIFIED**.)
4. Lấy code và (tuỳ chọn) tạo dữ liệu đầy đủ:
   ```bash
   git clone https://github.com/VuXuanThanh-Dev/super-apps.git
   cd super-apps/apps/toeic-flutter
   flutter pub get
   bash tools/build_data.sh          # tuỳ chọn, xem mục "Tạo dữ liệu đầy đủ"; không có thì app dùng 16 từ mẫu
   ```
5. Cắm iPhone vào Mac bằng cáp → trên iPhone bấm **Trust** (Tin cậy máy tính này).
6. Bật **Developer Mode** trên iPhone: Settings → Privacy & Security → Developer Mode → On → khởi động lại →
   bấm **Turn On**.
7. Ký app bằng Apple ID: mở `ios/Runner.xcworkspace` trong Xcode → chọn target **Runner** → tab
   **Signing & Capabilities** → **Team**: chọn Apple ID của bạn (Xcode → Settings → Accounts để thêm Apple ID).
   Nếu Xcode báo Bundle Identifier đã bị dùng, đổi `dev.nobin.toeicFlutter` thành tên riêng
   (ví dụ `dev.nobin.toeic900.<tên bạn>`). Docs: "a personal Apple Developer account is free and works"
   khi chỉ *test* trên máy của mình.
8. Chạy:
   ```bash
   flutter devices                   # thấy iPhone trong danh sách
   flutter run --release             # hoặc bỏ --release để có hot reload
   ```
9. Lần đầu, iPhone có thể chặn app: Settings → General → **VPN & Device Management** → chứng chỉ dưới
   **Developer App** → **Trust**. Rồi mở app lại.

Lưu ý:
- **UNVERIFIED:** app ký bằng tài khoản miễn phí hết hạn sau 7 ngày, phải cài lại (điều cộng đồng hay nói;
  chưa mở được trang Apple nào xác nhận — giống ghi chú trong `books/flutter/STACK.md`).
- Đọc to (TTS) dùng giọng của iPhone; app đặt `setIosAudioCategory(playback)` để đọc được cả khi gạt im lặng
  (README của flutter_tts). Nếu không có tiếng: Settings → Accessibility → Spoken Content → Voices (English).
- Nhắc hằng ngày xin quyền thông báo khi bạn bật lần đầu (tab Saved).

### Cách B — bản web trên Safari (không cần Mac)

```bash
cd apps/toeic-flutter
flutter build web --no-web-resources-cdn --release
cd build/web && python3 -m http.server 8080 --bind 0.0.0.0
# iPhone (cùng Wi-Fi): mở Safari → http://<IP-máy-tính>:8080
```

- Docs (`platform-integration/web/faq`): Flutter web chạy trên Safari (mobile & desktop).
- **Không** dùng `--wasm`: docs (`platform-integration/web/wasm`) nói bản Wasm không chạy trên trình duyệt iOS.
- `--no-web-resources-cdn`: đóng gói CanvasKit trong bản build (không tải từ CDN). Font Noto Sans cũng được
  đóng gói, nên chữ Việt và IPA hiện đúng.
- Có thể **Add to Home Screen** trong Safari để mở như app (manifest `web/manifest.json`). Nhưng docs nói Flutter
  **không còn tạo service worker cache** mặc định → bản web chưa chắc chạy khi mất mạng; máy tính phục vụ
  file phải đang bật (hoặc bạn tự đưa `build/web` lên hosting riêng tư).
- Trên web: không có nhắc theo lịch (app báo "Bản web không hỗ trợ"); SQLite chạy bằng WebAssembly
  (`web/sqlite3.wasm`, `web/sqflite_sw.js`) và dữ liệu học lưu trong trình duyệt.
- **UNVERIFIED:** TTS (Web Speech) và SQLite Wasm trên Safari iOS — chỉ kiểm tra trong Chromium headless.
- ⚠ Bản web build khi có `private-data/toeic.db` sẽ **chứa dữ liệu từ sách** (`build/web/assets/private-data/`).
  Chỉ phục vụ trong mạng nhà bạn, **đừng** đưa lên hosting công khai.

## Chạy trên Android (NOT RUN)

1. Cài Android Studio (docs `platform-integration/android/setup`), chạy `flutter doctor --android-licenses`.
2. Điện thoại: bật **Developer options** và **USB debugging** → cắm cáp → chấp nhận máy tính.
3. Chạy:
   ```bash
   cd apps/toeic-flutter
   flutter devices
   flutter run --release
   ```
   Hoặc tạo file cài đặt: `flutter build apk --release` → chép `build/app/outputs/flutter-apk/app-release.apk`
   vào điện thoại và mở để cài (mẫu của `flutter create` ký bản release bằng khoá debug — chỉ dùng cá nhân).
- Nhắc hằng ngày: Android 13+ hỏi quyền thông báo; app đã bật *core library desugaring* và khai báo receiver
  như README của flutter_local_notifications.

## Chạy trên máy tính (web)

```bash
cd apps/toeic-flutter
flutter pub get
flutter run -d chrome              # hoặc: flutter run -d web-server
```

## Tạo dữ liệu đầy đủ (từ hai file PDF)

App **dùng lại pipeline của Task 5**, không trích xuất lại:

```bash
cd apps/toeic-flutter
pip install -r ../toeic/tools/requirements.txt
python3 -c "import nltk; nltk.download('wordnet')"
bash tools/build_data.sh
```

Lệnh này chạy `apps/toeic/tools/extract_books.py` + `build_dataset.py` (ghi vào `apps/toeic/private-data/`,
đã git-ignore), chép `dataset.json` sang `private-data/source/`, rồi `tools/import_dataset.py` tạo
`private-data/toeic.db` (312 họ từ, 1.120 dạng từ, 1.296 collocation, 24 unit) và **kiểm tra import không mất
dữ liệu** (đọc ngược SQLite → JSON, so sánh từng trường). Khi mở app, nếu bản build có `private-data/toeic.db`
thì app dùng nó, không thì dùng `assets/data/sample.db`. Số liệu và chất lượng: [DATA-REPORT.md](DATA-REPORT.md).

Sau khi đổi dữ liệu: **dừng app và chạy lại** (`flutter run`) — hot reload không nạp lại asset.

## Thêm từ của bạn

1. Tạo file text, mỗi dòng một từ, các trường cách nhau bằng `|` (giống hệt Task 5):
   ```
   word|pos|định nghĩa tiếng Anh đơn giản|câu ví dụ|nghĩa tiếng Việt|mã unit (tuỳ chọn)|collocation (tuỳ chọn)
   ```
   Collocation: `cụm từ = nghĩa = ví dụ`, nhiều cái cách nhau bằng `;`. Ví dụ
   [`examples/my-words.example.txt`](examples/my-words.example.txt):
   ```
   deadline|n|the last day or time to finish something|The deadline for the report is Friday.|hạn chót|MY|meet a deadline = kịp hạn chót = We worked late to meet the deadline.
   ```
2. Import:
   ```bash
   python3 tools/import_words.py my-words.txt
   ```
   File được chép vào `private-data/my-words/` và gộp vào `private-data/toeic.db` (từ mới vào unit
   **MY · My words** nếu không ghi mã unit). Chạy lại `tools/build_data.sh` vẫn giữ từ của bạn.
   Parser và luật gộp **dùng lại code của Task 5** (`apps/toeic/tools/import_words.py`).
   Nếu chưa chạy `build_data.sh`, từ của bạn được gộp vào bộ mẫu.
3. Chạy lại app.

## Xoá dữ liệu riêng trước khi public

Repo GitHub là public nên `private-data/` đã bị **git-ignore** (chỉ commit README của nó). Trước khi phát hành
app (App Store, web công khai, file zip…):

1. Xoá dữ liệu từ sách:
   ```bash
   cd apps/toeic-flutter
   find private-data -mindepth 1 ! -name README.md -exec rm -rf {} +
   rm -rf build                      # bản build cũ có thể còn toeic.db
   ```
2. Chứng minh app vẫn chạy và không còn chữ trong sách:
   ```bash
   bash tools/check_no_private.sh
   ```
   Script dời `private-data/*` ra chỗ khác (tự trả lại khi xong), chạy leak check, `pub get`, format,
   `flutter analyze`, `flutter test`, `flutter build web`, kiểm tra bản web có `sample.db` và **không** có
   `toeic.db`, rồi smoke test Chromium (nếu có Playwright).
3. Nhớ: hai file PDF nằm ở gốc repo. Nếu repo thành dự án public thật, hãy xoá chúng.

Không phải dữ liệu từ sách (giữ được): code app, bộ mẫu, hội thoại, định nghĩa/ví dụ/bài đọc tự viết của Task 5,
dữ liệu WordNet/CMUdict (giấy phép mở, xem `apps/toeic/tools/LICENSES.md`), font Noto Sans (OFL).

## Kiến trúc (theo docs chính thức)

Theo trang **Guide to app architecture** và **Architecture recommendations** của docs.flutter.dev:

- **UI layer = MVVM:** mỗi màn hình có một *View* (widget) và một *ViewModel* (`ChangeNotifier`).
  View chỉ hiển thị và gọi hàm; ViewModel giữ trạng thái và gọi repository.
- **Data layer = Repository + Service:** `DatasetRepository` (bộ dữ liệu trong RAM, chỉ đọc),
  `UserRepository` (từ đã lưu, thẻ SM-2, thống kê — SQLite), `SettingsRepository` (shared_preferences).
  Service bọc plugin: `DatasetService`, `UserDatabaseService` (sqflite), `TtsService` (flutter_tts),
  `ReminderService` (flutter_local_notifications). Docs "Plugins in Flutter tests": bọc plugin để test dùng bản giả.
- **Command + Result:** thao tác async của ViewModel bọc trong `Command0/Command1`; repository trả `Result<T>`
  (`lib/utils/command.dart`, `result.dart` lấy từ ví dụ chính thức qua app mẫu Tập 2, giấy phép BSD).
- **DI bằng provider**, **điều hướng bằng go_router** (`StatefulShellRoute` cho 5 tab).
- **Test bằng fake** (`testing/fakes/`), SQLite thật qua FFI trong `flutter test`.

```
lib/
  main.dart · app.dart
  config/dependencies.dart      DI: tạo mọi repository/service, danh sách provider
  routing/router.dart           go_router: 5 tab + màn hình con
  domain/                       model bất biến + logic thuần
    models/  lookup/ (tokenizer, lemmatizer, dictionary)  srs/ (sm2, queue)  quiz/  stats/  vocabulary/  reminders/
  data/
    services/                   dataset_service, user_database_service, content_service, tts, reminder, key_value
    repositories/               dataset_repository, user_repository (+ sqlite_), settings_repository
  ui/
    core/ (themes, home_shell, sample_banner)
    lookup/ vocabulary/ flashcards/ quiz/ practice/ reading/ roleplay/ saved/ home/ settings/
      view_models/  widgets/    (mỗi tính năng: ViewModel + widget)
  utils/                        command, result, dates, random (mulberry32), vietnamese, change_signal
test/  domain/ data/ ui/        unit + widget test          testing/  fakes, sample_data, app_harness
tools/                          import dữ liệu, kiểm tra, smoke test
assets/                         data/sample.db, content/*.json (Task 5), fonts/ (Noto Sans)
private-data/                   dữ liệu từ sách (git-ignore)
```

Luồng dữ liệu: `toeic.db`/`sample.db` (asset, chỉ đọc; chọn theo AssetManifest) → `DatasetService` → RAM
(`DataIndex`) → từ điển, danh sách, quiz. Dữ liệu người dùng → SQLite `toeic_user.db` trên máy (khoá = chữ
thường của từ, nên còn nguyên sau khi build lại dataset). Cài đặt (theme, giờ nhắc, tốc độ đọc) → shared_preferences.

Khác Task 5: bộ dữ liệu là file **SQLite** (Task 5: JSON đóng gói bằng Metro); tokenizer/lemmatizer/SM-2/quiz/
thống kê là port 1:1 và dùng lại **đúng test case** của Task 5, nên hai app tra từ giống nhau
(cả bộ sinh số ngẫu nhiên mulberry32 cũng cho cùng dãy số — có test).

## Kiểm tra

```bash
cd apps/toeic-flutter
flutter analyze                    # 0 issue (flutter_lints 6 + strict-casts/inference/raw-types)
flutter test                       # 141 test pass (+1 test dữ liệu riêng, bỏ qua khi private-data rỗng)
flutter build web --no-web-resources-cdn --release
bash tools/check_no_private.sh     # tất cả ở trên với private-data RỖNG + smoke test web
python3 tools/check_no_book_text.py
NODE_PATH=$(npm root -g) node tools/web-smoke.cjs build/web [thư-mục-ảnh]   # cần Playwright
```

Kết quả thật (2026-09-30): [`logs/check-no-private.txt`](logs/check-no-private.txt) (private-data rỗng:
analyze 0 issue, 141 test pass, build web OK, smoke PASS), [`logs/web-smoke-private.txt`](logs/web-smoke-private.txt)
(bản có dữ liệu đầy đủ: smoke PASS), ảnh chụp bản web với dữ liệu mẫu: [`logs/screenshots/`](logs/screenshots/).

## Nguồn tham khảo (Sources)

Docs Flutter — mã nguồn tại commit `ab59c614e780e2d6d44f07ae4a96238028f581a5` của `flutter/website`
(docs.flutter.dev bị chặn trong sandbox; đã đọc file nguồn ngày 2026-09-30):
- Guide to app architecture — https://docs.flutter.dev/app-architecture/guide —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/guide.md
- Architecture recommendations — https://docs.flutter.dev/app-architecture/recommendations —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/recommendations.md
- Architecture case study (package structure) — https://docs.flutter.dev/app-architecture/case-study —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/case-study/index.md
- Testing each layer — https://docs.flutter.dev/app-architecture/case-study/testing —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/case-study/testing.md
- Persistent storage architecture: SQL — https://docs.flutter.dev/app-architecture/design-patterns/sql —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/design-patterns/sql.md
- Command pattern — https://docs.flutter.dev/app-architecture/design-patterns/command —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/design-patterns/command.md
- Result — https://docs.flutter.dev/app-architecture/design-patterns/result —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/app-architecture/design-patterns/result.md
- Persist data with SQLite (cookbook) — https://docs.flutter.dev/cookbook/persistence/sqlite —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/persistence/sqlite.md
- Plugins in Flutter tests — https://docs.flutter.dev/testing/plugins-in-tests —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/testing/plugins-in-tests.md
- Set up iOS development — https://docs.flutter.dev/platform-integration/ios/setup —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/platform-integration/ios/setup.md
- Build and release an iOS app (Signing & Capabilities) — https://docs.flutter.dev/deployment/ios —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/deployment/ios.md
- Set up Android development — https://docs.flutter.dev/platform-integration/android/setup —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/platform-integration/android/setup.md
- Web FAQ (Safari, service worker) — https://docs.flutter.dev/platform-integration/web/faq —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/platform-integration/web/faq.md
- Wasm (không chạy trên iOS) — https://docs.flutter.dev/platform-integration/web/wasm —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/platform-integration/web/wasm.md

Khác:
- Stack của sách Flutter (Task 8): `books/flutter/STACK.md`; app mẫu Tập 2: `books/flutter/vol2-trung-cap/examples/`
- README của package (đọc trong pub cache sau `flutter pub get`): flutter_local_notifications 22.3.1
  (desugaring, receiver, iOS delegate), flutter_tts 4.2.5 (`setIosAudioCategory`) —
  https://pub.dev/packages/flutter_local_notifications , https://pub.dev/packages/flutter_tts
- Apple Developer Program ($99/năm): https://developer.apple.com/programs/
- SM-2: https://github.com/cnnrhill/sm-2 (giống Task 5)
- Noto Sans (SIL OFL 1.1): https://github.com/notofonts/latin-greek-cyrillic
