# GLOSSARY — Thuật ngữ React Native (Anh → Việt)

| Thuật ngữ (English) | Giải thích tiếng Việt | Gần giống trong Angular |
|---|---|---|
| React Native (RN) | Framework viết app iOS/Android bằng React; vẽ view native thật | Ionic/Capacitor (nhưng Ionic dùng WebView) |
| Expo | Framework cho RN: CLI, router, thư viện module native, dịch vụ build | Angular CLI + thư viện chính thức |
| Expo SDK | Bộ phiên bản Expo đi cùng một phiên bản RN (sách dùng SDK 57 ↔ RN 0.86) | Phiên bản Angular major |
| Expo Go | App trên App Store để chạy thử project mà không cần build | — |
| Development build | Bản app "Expo Go của riêng bạn", có native module tùy ý | — |
| EAS (Expo Application Services) | Dịch vụ cloud: build, submit, update | CI/CD dịch vụ |
| Metro | Bundler (công cụ đóng gói JS) của RN | esbuild/webpack trong Angular CLI |
| Hermes | JavaScript engine chạy trên điện thoại; V1 mặc định từ RN 0.84 | V8 trong trình duyệt |
| Fast Refresh | Cập nhật app ngay khi lưu file, giữ state | HMR (`ng serve --hmr`) |
| New Architecture | Kiến trúc mới của RN: JSI + Fabric + TurboModules; bắt buộc từ RN 0.82 | — |
| JSI (JavaScript Interface) | Lớp C++ cho JS gọi native trực tiếp, không qua "bridge" | — |
| Fabric | Hệ thống render mới của RN | Renderer |
| TurboModules | Native module thế hệ mới, tải lười (lazy) | — |
| Codegen | Sinh code C++/native từ type TypeScript | — |
| Component | Hàm trả về JSX | `@Component` |
| JSX | Cú pháp giống HTML viết trong TypeScript | Template |
| Props | Tham số truyền vào component (chỉ đọc) | `@Input()` |
| Callback prop | Hàm truyền xuống để con báo sự kiện lên | `@Output()` |
| State | Dữ liệu thay đổi được của component (`useState`) | `signal()` / field của class |
| Hook | Hàm `use...` dùng tính năng React trong component hàm | Lifecycle hooks + `inject()` |
| Effect (`useEffect`) | Side effect sau khi render, có hàm dọn dẹp | `ngOnInit` + `ngOnDestroy`, `effect()` |
| Memo (`useMemo`, `memo`) | Ghi nhớ kết quả/Component để tránh tính/render lại | `computed()`, `OnPush` |
| Context | Truyền giá trị xuống cây component không qua props | Dependency Injection |
| Controlled component | Input mà giá trị nằm trong state React | `[(ngModel)]`, `FormControl` |
| Pressable | Component bắt sự kiện chạm | `(click)` trên `<button>` |
| FlatList / SectionList | Danh sách ảo hóa (virtualized), chỉ render dòng đang thấy | `cdk-virtual-scroll` |
| Virtualization | Chỉ render phần tử đang nằm trên màn hình | Virtual scroll |
| Flexbox | Hệ thống bố cục; RN mặc định `flexDirection: 'column'` | CSS Flexbox |
| StyleSheet | API tạo style cho component | SCSS của component |
| Safe area | Vùng không bị tai thỏ/thanh home che | — |
| Expo Router | Router theo file (file-based routing) cho Expo | Angular Router |
| Layout (`_layout.tsx`) | File định nghĩa navigator (Stack, Tabs) cho một thư mục | Component chứa `<router-outlet>` |
| Stack / Tabs | Kiểu điều hướng: chồng màn hình / thanh tab dưới | — |
| Deep link | Link mở thẳng vào một màn hình trong app | URL route |
| Accessibility (a11y) | Khả năng tiếp cận: VoiceOver, vai trò, nhãn | ARIA |
| jest-expo | Preset Jest của Expo | Karma/Jest preset Angular |
| RNTL | React Native Testing Library — test theo cách người dùng dùng app | TestBed + Testing Library |
| Continuous Native Generation (CNG) | Thư mục `ios/` và `android/` được sinh ra từ `app.json`, không sửa tay | — |
| Config plugin | Plugin sửa cấu hình native khi sinh `ios/`/`android/` | Angular schematics (gần giống) |
