# Chương 3 — Component, JSX, props, state và các core component

## Mục tiêu

- Viết component bằng hàm + JSX.
- Dùng các **core component** (component lõi): `View`, `Text`, `Image`, `Pressable`, `ScrollView`.
- Hiểu **props** (dữ liệu vào) và **state** (dữ liệu thay đổi bên trong).
- Dùng `useEffect` cho side effect và dọn dẹp (cleanup).

## Giải thích đơn giản

Hãy nghĩ component như một **công thức**: cho vào `props` + `state`, ra **giao diện**.

- **Props** giống tham số hàm. Component con **không được sửa** props.
- **State** là "trí nhớ" của component. Gọi hàm `setX(...)` → React gọi lại component → giao diện mới.
- **Core component** là "thẻ HTML" của React Native. Tài liệu RN liệt kê: `<View>` ~ `<div>`,
  `<Text>` ~ `<p>`, `<Image>` ~ `<img>`, `<ScrollView>` ~ `<div>` cuộn được, `<TextInput>` ~ `<input>`.

## Ví dụ

### ProfileCard — props và core component

`examples/src/chapters/ch03/ProfileCard.tsx`:

```tsx
export interface Profile {
  name: string;
  role: string;
  avatar: ImageSourcePropType; // ảnh local: require('...png'); ảnh mạng: { uri: 'https://...' }
}

export function ProfileCard({ profile, onFollow, following }: {
  profile: Profile;
  following: boolean;
  onFollow: () => void;
}) {
  return (
    <View style={styles.card}>
      <Image source={profile.avatar} style={styles.avatar} accessibilityLabel={`Ảnh của ${profile.name}`} />
      <View style={styles.info}>
        <Text style={styles.name}>{profile.name}</Text>
        <Text style={styles.role}>{profile.role}</Text>
      </View>
      <Pressable accessibilityRole="button" onPress={onFollow} style={styles.button}>
        <Text style={styles.buttonText}>{following ? 'Đang theo dõi' : 'Theo dõi'}</Text>
      </Pressable>
    </View>
  );
}
```

Chú ý: `ProfileCard` không tự lưu `following`. Cha quyết định (**lifting state up** — đưa state
lên cha). Giống component "dumb/presentational" trong Angular.

### Counter — state với `useState`

```tsx
export function Counter({ step = 1 }: { step?: number }) {
  const [count, setCount] = useState(0);
  return (
    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 16 }}>
      <Pressable accessibilityRole="button" accessibilityLabel="Giảm" onPress={() => setCount((c) => c - step)}>
        <Text style={{ fontSize: 28 }}>−</Text>
      </Pressable>
      <Text accessibilityLabel="Giá trị" style={{ fontSize: 28 }}>{count}</Text>
      <Pressable accessibilityRole="button" accessibilityLabel="Tăng" onPress={() => setCount((c) => c + step)}>
        <Text style={{ fontSize: 28 }}>+</Text>
      </Pressable>
    </View>
  );
}
```

`setCount((c) => c + step)` dùng **dạng hàm** (updater): an toàn khi nhiều lần cập nhật liên tiếp.

### Clock — `useEffect` và cleanup

```tsx
export function Clock() {
  const [now, setNow] = useState(() => new Date());
  useEffect(() => {
    const id = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(id);
  }, []);
  return <Text accessibilityLabel="Đồng hồ">{formatTime(now)}</Text>;
}
```

- Mảng `[]` = chỉ chạy **một lần** sau lần render đầu (như `ngOnInit`).
- Hàm `return` chạy khi component bị gỡ (như `ngOnDestroy`).

### Test và kết quả thật

Test Clock dùng **fake timers** (đồng hồ giả) — giống `fakeAsync` + `tick()`:

```tsx
jest.useFakeTimers();
jest.setSystemTime(new Date(2026, 0, 1, 8, 0, 0));
const clearSpy = jest.spyOn(globalThis, 'clearInterval');
const view = await render(<Clock />);
expect(screen.getByLabelText('Đồng hồ')).toHaveTextContent('08:00:00');
await act(async () => { jest.advanceTimersByTime(2000); });
expect(screen.getByLabelText('Đồng hồ')).toHaveTextContent('08:00:02');
await view.unmount();
expect(clearSpy).toHaveBeenCalled(); // cleanup của useEffect đã chạy
```

Kết quả (2026-09-28, `npx jest --verbose src/chapters/ch03`):

```text
PASS src/chapters/ch03/components.test.tsx
  Chương 3 — component, props, state
    ✓ Counter tăng/giảm theo step
    ✓ ProfileCard đổi nhãn nút khi bấm Theo dõi
    ✓ formatTime thêm số 0 phía trước
    ✓ Clock tự cập nhật mỗi giây và dọn interval khi unmount
PASS src/chapters/ch03/exercise.solution.test.tsx
  ✓ LikeButton bật/tắt và đổi số lượt thích
  ✓ Bài 2: Clock dừng khi paused = true và chạy lại khi false
Test Suites: 2 passed, 2 total
Tests:       6 passed, 6 total
```

Xem trên Expo Go: tab **Lab** → "Ch.3" (**NOT RUN** trong sandbox).

## Đi sâu

### JSX chỉ là lời gọi hàm

`<Text style={s}>Hi</Text>` được biên dịch thành `jsx(Text, { style: s, children: 'Hi' })`.
Vì vậy trong `{...}` bạn viết **biểu thức** JS: `{a && <X/>}`, `{list.map(...)}`,
nhưng không viết được `if` hay `for` trực tiếp.

### Khi nào component render lại?

1. State của nó đổi (`setX` với giá trị khác — so sánh bằng `Object.is`).
2. Cha render lại (kể cả khi props giống cũ!) — trừ khi bọc bằng `memo`.
3. Context mà nó dùng đổi.

Đây giống `ChangeDetectionStrategy.Default`. `memo(Component)` giống `OnPush`.
Tập 3 (Performance) nói kỹ hơn, kèm React Compiler.

### Ảnh: local và từ mạng

- Local: `source={require('./avatar.png')}` — Metro đóng gói ảnh, tự biết kích thước.
- Mạng: `source={{ uri: 'https://...' }}` — **phải** đặt `width`/`height` trong style, nếu không
  ảnh có kích thước 0.

### `Pressable` và accessibility

`Pressable` có `onPress`, `onLongPress`, `hitSlop` (mở rộng vùng chạm), và style dạng hàm
`style={({ pressed }) => ...}` để làm hiệu ứng khi nhấn. Luôn thêm `accessibilityRole="button"`
và nhãn (`accessibilityLabel` hoặc chữ bên trong) để VoiceOver đọc được — và để test tìm được
bằng `getByRole('button', { name })`.

## Lỗi và bẫy thường gặp

- **Chữ nằm ngoài `<Text>`** → lỗi đỏ khi chạy.
- **Sửa state trực tiếp**: `count++` không làm gì. Luôn dùng `setCount`.
- **Gọi `setState` trong thân component** → vòng lặp render vô hạn.
- **Quên cleanup** interval/listener → rò rỉ bộ nhớ, cảnh báo "state update on unmounted component".
- **Ảnh mạng không hiện**: quên width/height.
- **`onPress={doIt()}`** (gọi ngay) thay vì `onPress={doIt}` hoặc `onPress={() => doIt(x)}`.

## Tóm tắt

- Component = hàm(props) → JSX. Props đi xuống, sự kiện đi lên qua callback.
- `useState` cho dữ liệu thay đổi; dùng updater `setX(prev => ...)`.
- `useEffect` cho side effect; `return` để dọn dẹp.
- Core component: `View`, `Text`, `Image`, `Pressable`, `ScrollView`, `TextInput`.

## Bài tập (có lời giải)

**Bài 1.** Viết `LikeButton` nhận `initialLikes`. Bấm lần 1: ❤️ và +1; bấm lần 2: 🤍 và trở lại.
Nhãn accessibility đổi giữa "Thích"/"Bỏ thích".

<details>
<summary>Lời giải</summary>

`examples/src/chapters/ch03/exercise.solution.tsx`:

```tsx
export function LikeButton({ initialLikes = 0 }: { initialLikes?: number }) {
  const [liked, setLiked] = useState(false);
  const likes = initialLikes + (liked ? 1 : 0); // "derived state": tính từ state, không lưu thêm
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected: liked }}
      accessibilityLabel={liked ? 'Bỏ thích' : 'Thích'}
      onPress={() => setLiked((v) => !v)}
    >
      <Text>{liked ? '❤️' : '🤍'} {likes}</Text>
    </Pressable>
  );
}
```

Điểm chính: **không** tạo state thứ hai `likes`. Giá trị suy ra được thì tính khi render
(giống `computed()`), tránh hai state lệch nhau.
</details>

**Bài 2.** Đồng hồ `Clock` chạy mãi. Hãy thêm prop `paused: boolean`; khi `paused = true` thì
dừng interval. Gợi ý: dependency của `useEffect`.

<details>
<summary>Lời giải</summary>

```tsx
useEffect(() => {
  if (paused) return;                 // không tạo interval
  const id = setInterval(() => setNow(new Date()), 1000);
  return () => clearInterval(id);     // chạy khi paused đổi hoặc unmount
}, [paused]);
```

Khi `paused` đổi từ `false` → `true`, React chạy cleanup của effect cũ (xóa interval), rồi chạy
effect mới (thoát sớm). Đây là mẫu "đăng ký lại khi input đổi", giống `switchMap` trong RxJS.

Lời giải đã có trong `ch03/Clock.tsx` (prop `paused`) và được test trong
`ch03/exercise.solution.test.tsx` ("Bài 2: Clock dừng khi paused = true…"): dùng
`view.rerender(<Clock paused={false} />)` để đổi prop.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- Core Components and Native Components: https://github.com/facebook/react-native-website/blob/main/docs/intro-react-native-components.md
- React Fundamentals (props, state): https://github.com/facebook/react-native-website/blob/main/docs/intro-react.md
- Props: https://github.com/facebook/react-native-website/blob/main/docs/props.md
- State: https://github.com/facebook/react-native-website/blob/main/docs/state.md
- Images: https://github.com/facebook/react-native-website/blob/main/docs/images.md
- Pressable: https://github.com/facebook/react-native-website/blob/main/docs/pressable.md
