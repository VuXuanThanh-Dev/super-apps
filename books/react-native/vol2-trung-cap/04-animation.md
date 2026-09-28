# Chương 4 — Animation: Animated API và Reanimated

## Mục tiêu

- Làm animation đơn giản với **Animated API** có sẵn trong React Native.
- Dùng **Reanimated 4** (có trong Expo Go SDK 57): shared value, `withSpring`, `withTiming`,
  `withSequence`, layout animation (`entering`, `exiting`, `layout`).
- Viết code tương thích **React Compiler** (luật lint mới).
- Test animation trong Jest.

## Giải thích đơn giản

Animation là **thay đổi một giá trị theo thời gian** (opacity 0 → 1, scale 1 → 1.4 → 1) và gắn
giá trị đó vào style. Điều quan trọng trên mobile: animation nên chạy trên **UI thread** (luồng
giao diện native) để mượt 60 khung hình/giây kể cả khi JavaScript đang bận.

- **Animated API** (có sẵn): `new Animated.Value(0)` + `Animated.timing(...)`. Đặt
  `useNativeDriver: true` để chạy trên UI thread.
- **Reanimated**: `useSharedValue` (giá trị dùng chung giữa JS và UI thread) +
  `useAnimatedStyle` (style tính trên UI thread) + các hàm `withTiming`/`withSpring`.

Angular có `@angular/animations` (trigger/state/transition). Ý tưởng tương tự, nhưng trên RN bạn
làm việc với giá trị số và style trực tiếp.

## Ví dụ

### 1. Animated API — hiện dần

`examples/src/chapters/ch04/FadeInView.tsx`:

```tsx
export function FadeInView({ children, duration = 500 }: { children: ReactNode; duration?: number }) {
  // Tài liệu cũ hay viết useRef(new Animated.Value(0)).current — luật react-hooks/refs
  // (có trong eslint-config-expo 57) báo lỗi vì đọc ref khi render. useState(() => ...) tạo
  // giá trị một lần và an toàn.
  const [opacity] = useState(() => new Animated.Value(0));
  useEffect(() => {
    Animated.timing(opacity, { toValue: 1, duration, useNativeDriver: true }).start();
  }, [opacity, duration]);
  return <Animated.View testID="fade" style={{ opacity }}>{children}</Animated.View>;
}
```

**Phát hiện khi viết sách:** trang "Animations" của React Native vẫn dùng mẫu
`useRef(new Animated.Value(0)).current`. Với `eslint-config-expo@57.0.2`, ESLint báo
`Error: Cannot access refs during render (react-hooks/refs)`. Dùng `useState` với hàm khởi tạo.

### 2. Reanimated — nút tim nảy

`examples/src/components/FavoriteButton.tsx` (app mẫu):

```tsx
const scale = useSharedValue(1);
const animatedStyle = useAnimatedStyle(() => ({ transform: [{ scale: scale.get() }] }));

const onPress = () => {
  // Dùng .set()/.get() thay vì gán .value — tương thích React Compiler (luật react-hooks/immutability).
  scale.set(withSequence(withSpring(1.4), withSpring(1)));
  toggle(postId);
  void tapFeedback();
};

<Animated.View style={animatedStyle}>
  <Text style={{ fontSize: 22 }}>{isFav ? '❤️' : '🤍'}</Text>
</Animated.View>
```

Viết `scale.value = ...` vẫn chạy, nhưng ESLint (bộ luật React Compiler trong eslint-config-expo)
báo `This value cannot be modified (react-hooks/immutability)`. Tài liệu `useSharedValue` của
Reanimated khuyên: khi dùng React Compiler, dùng `get()`/`set()` thay vì `.value`.

### 3. Layout animation — thêm/xóa có hiệu ứng

```tsx
{items.map((n) => (
  <Animated.View key={n} entering={FadeIn} exiting={FadeOut} layout={LinearTransition}>
    <Pressable accessibilityRole="button" onPress={() => setItems((l) => l.filter((x) => x !== n))}>
      <Text>Mục {n} (bấm để xóa)</Text>
    </Pressable>
  </Animated.View>
))}
```

App mẫu dùng `entering={FadeInDown.delay(Math.min(index, 10) * 40)}` trong `PostCard` để các thẻ
trượt lên lần lượt.

### Test

Cấu hình Jest cho Reanimated/Worklets (theo hướng dẫn "Testing with Jest" của Worklets và Reanimated):

```json
"jest": {
  "preset": "jest-expo",
  "resolver": "react-native-worklets/jest/resolver",
  "setupFilesAfterEnv": ["./jest.setup.js"]
}
```

```js
// jest.setup.js
require('react-native-reanimated').setUpTests();
```

Không có `resolver`, test báo lỗi `TypeError: Cannot read properties of undefined (reading 'loadUnpackers')`
(chúng tôi đã gặp). Lưu ý: tài liệu Reanimated nhắc `react-native-reanimated/jest/resolver`, nhưng gói
`react-native-reanimated@4.5.1` đã cài không có thư mục `jest/`; resolver của `react-native-worklets@0.10.1` thì có.

Test "shake" dùng matcher `toHaveAnimatedStyle` của Reanimated và fake timers:

```tsx
jest.useFakeTimers();
const view = await render(<ShakeOnError error={null} />);
expect(screen.getByTestId('shake')).toHaveAnimatedStyle({ transform: [{ translateX: 0 }] });
await view.rerender(<ShakeOnError error="Sai mật khẩu" />);
await act(async () => { jest.advanceTimersByTime(50); });
expect(screen.getByTestId('shake')).toHaveAnimatedStyle({ transform: [{ translateX: -10 }] });
```

Với Animated API + native driver, khung hình chạy trên UI thread nên Jest không thấy opacity đổi
dần; ta kiểm tra giá trị đầu và cấu hình gửi cho `Animated.timing`.

Kết quả (2026-09-28):

```text
PASS src/chapters/ch04/animation.test.tsx
    ✓ FadeInView: bắt đầu opacity 0 và chạy Animated.timing tới 1 bằng native driver
    ✓ bài tập: ShakeOnError lệch sang trái rồi về 0
    ✓ layout animation: thêm và xóa phần tử
Tests:       3 passed, 3 total
```

Trên Expo Go: tab **Lab** → "Ch.4 — Animation" (**NOT RUN**).

## Đi sâu

### Animated API hay Reanimated?

| | Animated (có sẵn) | Reanimated 4 |
|---|---|---|
| Cài thêm | Không | Có trong Expo Go SDK 57 (`react-native-reanimated@4.5.1` + `react-native-worklets@0.10.1`) |
| Chạy trên UI thread | Có, với `useNativeDriver: true` (một số thuộc tính) | Có, mặc định (worklet) |
| Gesture, layout animation | Hạn chế | Mạnh (`entering`, `exiting`, `layout`) |
| Khi nào dùng | Fade/slide đơn giản | Tương tác phức tạp, danh sách, gesture |

RN 0.85 giới thiệu "Shared Animation Backend" viết cùng Software Mansion, dùng chung cho cả
Animated và Reanimated (thử nghiệm, bật qua kênh experimental). Sách không bật tính năng này.

### Worklet là gì?

Hàm trong `useAnimatedStyle(() => ...)` là **worklet**: được copy sang UI thread và chạy ở đó.
Vì vậy trong worklet chỉ nên đọc shared value và tính toán nhẹ; không gọi `setState` trực tiếp.

### Accessibility: giảm chuyển động

Người dùng có thể bật "Reduce Motion" trên iPhone. Reanimated có hook `useReducedMotion()`; RN có
`AccessibilityInfo.isReduceMotionEnabled()`. Với animation trang trí, hãy tắt hoặc rút ngắn khi
người dùng bật tùy chọn này.

## Lỗi và bẫy thường gặp

- **Quên `useNativeDriver: true`** → animation chạy trên JS thread, giật khi JS bận.
- **`useNativeDriver: true` với `width`/`height`/`top`...**: theo mục "Caveats" của trang Animations,
  native driver chỉ animate thuộc tính **không phải layout** (`transform`, `opacity`). Blog RN 0.85
  nói giới hạn này được gỡ khi bật Shared Animation Backend (kênh experimental) — sách không bật.
- **Gán `sv.value` trong component** → ESLint (React Compiler) báo lỗi; dùng `set()`.
- **`useRef(new Animated.Value(0)).current`** → ESLint `react-hooks/refs` báo lỗi; dùng `useState(() => …)`.
- **Thiếu resolver trong Jest** → lỗi `loadUnpackers`.

## Tóm tắt

- Animated API cho hiệu ứng đơn giản; Reanimated cho mọi thứ còn lại.
- Shared value + animated style + `withTiming/withSpring/withSequence`; layout animation bằng `entering/exiting/layout`.
- Viết theo chuẩn React Compiler: `get()/set()`, không đọc ref khi render.

## Bài tập (có lời giải)

**Bài 1.** Viết `ShakeOnError({ error })`: mỗi khi `error` đổi (khác null), dòng lỗi rung ngang
−10 → 10 → −6 → 0 trong 200 ms. Viết test bằng `toHaveAnimatedStyle`.

<details>
<summary>Lời giải</summary>

`examples/src/chapters/ch04/ShakeOnError.tsx`:

```tsx
export function ShakeOnError({ error }: { error: string | null }) {
  const x = useSharedValue(0);
  useEffect(() => {
    if (!error) return;
    x.set(
      withSequence(
        withTiming(-10, { duration: 50 }),
        withTiming(10, { duration: 50 }),
        withTiming(-6, { duration: 50 }),
        withTiming(0, { duration: 50 }),
      ),
    );
  }, [error, x]);
  const style = useAnimatedStyle(() => ({ transform: [{ translateX: x.get() }] }));
  return (
    <Animated.View testID="shake" style={style}>
      <Text style={{ color: '#dc2626' }}>{error ?? ' '}</Text>
    </Animated.View>
  );
}
```

Dùng kèm form đăng nhập: khi server trả "Sai mật khẩu", người dùng thấy ngay dòng lỗi rung.
</details>

**Bài 2.** Tôn trọng "Reduce Motion": nếu người dùng bật, `ShakeOnError` không rung. Sửa thế nào?

<details>
<summary>Lời giải</summary>

```tsx
import { useReducedMotion } from 'react-native-reanimated';

const reduceMotion = useReducedMotion();
useEffect(() => {
  if (!error || reduceMotion) return;
  x.set(withSequence(/* ... */));
}, [error, reduceMotion, x]);
```

Dòng lỗi vẫn hiện (thông tin không mất), chỉ bỏ hiệu ứng. (Lời giải tham khảo; chưa có test riêng
trong dự án.)
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- React Native — Animations: https://github.com/facebook/react-native-website/blob/main/docs/animations.md
- React Native 0.85 blog (Shared Animation Backend): https://github.com/facebook/react-native-website/blob/main/website/blog/2026-04-07-react-native-0.85.mdx
- Reanimated — useSharedValue (React Compiler support): https://github.com/software-mansion/react-native-reanimated/blob/main/docs/docs-reanimated/docs/core/useSharedValue.mdx
- Reanimated — Testing with Jest: https://github.com/software-mansion/react-native-reanimated/blob/main/docs/docs-reanimated/docs/guides/testing-with-jest.mdx
- Worklets — Testing with Jest: https://github.com/software-mansion/react-native-reanimated/blob/main/docs/docs-worklets/docs/guides/testing-with-jest.mdx
- Reanimated — Entering/Exiting animations: https://github.com/software-mansion/react-native-reanimated/blob/main/docs/docs-reanimated/docs/layout-animations/entering-exiting-animations.mdx
- Expo — Reanimated (SDK 57): https://github.com/expo/expo/blob/main/docs/pages/versions/v57.0.0/sdk/reanimated.mdx
