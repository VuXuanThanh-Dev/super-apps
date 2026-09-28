# Chương 3 — Performance (hiệu năng)

## Mục tiêu

- Hiểu nguyên nhân chính làm app RN chậm: render thừa, danh sách dài, việc nặng trên JS thread.
- Đo bằng `<Profiler>` của React (cả trong test).
- Dùng `memo`, `useCallback`, `useMemo` đúng chỗ; hiểu **React Compiler** (bật trong app Tập 3).
- Dùng **FlashList v2** cho danh sách.

## Giải thích đơn giản

App RN có (ít nhất) hai luồng quan trọng: **JS thread** (chạy React, logic) và **UI thread** (vẽ,
cuộn, animation native). App "giật" khi một trong hai bị nghẽn quá ~16 ms (60 khung hình/giây).

Nguồn chậm phổ biến nhất trên JS thread: **render thừa** — component render lại dù dữ liệu của nó
không đổi. Trong Angular, bạn dùng `OnPush` + signals. Trong React:

- `memo(Component)`: bỏ qua render nếu props **bằng nhau** (so sánh nông).
- `useCallback(fn, deps)`: giữ **cùng một hàm** giữa các lần render (để `memo` so sánh được).
- `useMemo(() => value, deps)`: giữ kết quả tính toán.
- **React Compiler**: tự động chèn các memo này lúc build.

## Ví dụ

### 1. Đếm render bằng Profiler

`examples/src/chapters/ch03/RenderCountDemo.tsx` (trích):

```tsx
function Row({ id, label, onPress, onRender }: RowProps) {
  return (
    <Profiler id={id} onRender={onRender}>
      <Pressable onPress={onPress}>
        <Text>{label}</Text>
      </Pressable>
    </Profiler>
  );
}
const MemoRow = memo(Row);

export function RenderCountDemo({ onRender = noop, inlineCallback = false }) {
  const [query, setQuery] = useState('');
  const [taps, setTaps] = useState(0);
  const handlePress = useCallback(() => setTaps((t) => t + 1), []); // hàm ổn định giữa các lần render

  return (
    <View style={{ padding: 16, gap: 8 }}>
      <TextInput accessibilityLabel="Gõ để làm cha render lại" value={query} onChangeText={setQuery} />
      <Row id="plain" label="Row thường" onPress={handlePress} onRender={onRender} />
      <MemoRow id="memo" label="Row có memo" onPress={inlineCallback ? () => setTaps((t) => t + 1) : handlePress} onRender={onRender} />
    </View>
  );
}
```

`<Profiler>` đặt **bên trong** Row: chỉ khi Row thật sự render thì `onRender` mới chạy. (Lần đầu chúng
tôi đặt Profiler bên ngoài và test đếm sai: Profiler vẫn báo commit dù MemoRow không render.)

Test:

```tsx
test('memo + useCallback: gõ vào ô tìm kiếm không làm MemoRow render lại', async () => {
  const counts: Record<string, number> = { plain: 0, memo: 0 };
  const onRender: ProfilerOnRenderCallback = (id) => { counts[id] += 1; };
  const user = userEvent.setup();
  await render(<RenderCountDemo onRender={onRender} />);
  const afterMount = { ...counts };
  await user.type(screen.getByLabelText('Gõ để làm cha render lại'), 'abc');
  expect(counts.plain - afterMount.plain).toBeGreaterThan(0);
  expect(counts.memo - afterMount.memo).toBe(0);
});
```

Kết quả (2026-09-28):

```text
PASS src/chapters/ch03/performance.test.tsx
  ✓ memo + useCallback: gõ vào ô tìm kiếm không làm MemoRow render lại
  ✓ bài tập: hàm inline (tạo mới mỗi lần render) làm memo mất tác dụng
Tests:       2 passed, 2 total
```

### 2. FlashList v2 trong app

`examples/src/app/(app)/index.tsx`:

```tsx
<FlashList
  data={visible}
  keyExtractor={(n) => n.id}
  renderItem={({ item }) => <NoteRow note={item} onOpen={open} />}
  ListEmptyComponent={<Text style={styles.empty}>{loaded ? 'Chưa có ghi chú.' : 'Đang tải...'}</Text>}
/>
```

README của FlashList 2.0.2: v2 "has been rebuilt from the ground up for RN's new architecture",
**không cần** `estimatedItemSize`, là "JS-only solution", và **chỉ chạy trên New Architecture**.
FlashList **tái sử dụng** (recycle) view khi cuộn thay vì tạo mới — nhanh hơn FlatList với danh sách dài.

### 3. React Compiler trong app Tập 3

`examples/app.json`:

```json
"experiments": { "reactCompiler": true }
```

Tài liệu Expo: từ SDK 54, Babel đã tự cấu hình cho React Compiler — chỉ cần bật cờ này.

**Kiểm chứng thật:** chúng tôi chạy `npx expo export --platform ios --no-bytecode` cho app Tập 3 và tìm
trong bundle: code của layout `(app)/_layout.tsx` đã được biến đổi thành dạng cache
(`j[3]===Symbol.for("react.memo_cache_sentinel")?(...)`) — dấu hiệu của React Compiler. Bundle Tập 1
(không bật cờ) không có dạng này trong code app.

**Nhưng trong Jest thì không:** test ở trên cho thấy "Row thường" vẫn render lại khi gõ. Nếu Compiler
chạy trong Jest, phần tử `<Row ... />` với props ổn định đã được cache và không render lại. Vì vậy
test chạy **code chưa biên dịch bởi Compiler** — đó là lý do sách vẫn dạy `memo`/`useCallback` thủ công
và test chúng. (Kết luận này suy ra từ hành vi quan sát được; chúng tôi chưa tìm thấy tài liệu nói rõ.)

## Đi sâu

### Danh sách: checklist

1. `keyExtractor` ổn định (id, không dùng index).
2. Component dòng bọc `memo`; callback bằng `useCallback` (hoặc để Compiler lo).
3. Không tạo object/array mới trong `renderItem` nếu truyền xuống dòng memo.
4. Ảnh: kích thước cố định; ảnh lớn dùng thumbnail.
5. Danh sách rất dài / nhiều loại dòng → FlashList.

### Đo trên máy thật

- **React Native DevTools** (mở từ Dev Menu): tab Profiler của React.
- `useBenchmark` / `useFlatListBenchmark` (có trong exports của FlashList) để so sánh.
- Luôn đo trên **bản release** hoặc máy thật: bản dev chậm hơn nhiều vì kiểm tra thêm.

### Công việc nặng

- Tính toán lớn: chia nhỏ, dùng `useDeferredValue`/`startTransition` (React 19, Fabric hỗ trợ), hoặc chuyển xuống native (Chương 2).
- Animation: Reanimated chạy trên UI thread (Tập 2 Chương 4).
- Khởi động app: Hermes biên dịch bytecode trước; tránh import thư viện lớn ở màn hình đầu.

## Lỗi và bẫy thường gặp

- **`memo` + callback inline** → memo vô dụng (xem bài tập).
- **`useMemo` cho mọi thứ** → code rối, đôi khi chậm hơn. Đo trước, tối ưu sau.
- **Đo trong Jest rồi kết luận về app** → Jest không chạy React Compiler; chỉ dùng để khẳng định hành vi.
- **FlashList v2 + test**: file `@shopify/flash-list/jestSetup` của bản 2.0.2 thay `FlashList` bằng
  `RecyclerView` lấy từ gói — nhưng gói không export `RecyclerView` → lỗi "Element type is invalid".
  Chúng tôi gặp lỗi này (ErrorBoundary của app đã bắt và hiện nó!). Cách sửa trong `jest.setup.js`:
  chỉ giả lập các hàm đo layout.
- **Profiler bọc bên ngoài component memo** → đếm sai.

## Tóm tắt

- Render thừa là thủ phạm số 1; đo bằng Profiler.
- `memo` + `useCallback` (hoặc React Compiler) + FlashList cho danh sách.
- React Compiler chạy khi build bằng Metro (đã kiểm chứng trong bundle), không chạy trong Jest.

## Bài tập (có lời giải)

**Bài 1.** Chứng minh bằng test: nếu truyền **hàm inline** (`onPress={() => ...}`) cho `MemoRow`, nó sẽ
render lại mỗi lần cha render.

<details>
<summary>Lời giải</summary>

```tsx
test('bài tập: hàm inline (tạo mới mỗi lần render) làm memo mất tác dụng', async () => {
  const counts: Record<string, number> = { plain: 0, memo: 0 };
  const user = userEvent.setup();
  await render(<RenderCountDemo inlineCallback onRender={(id) => (counts[id] += 1)} />);
  const before = counts.memo;
  await user.type(screen.getByLabelText('Gõ để làm cha render lại'), 'abc');
  expect(counts.memo - before).toBe(3); // render lại mỗi phím
});
```

Mỗi lần render, `() => ...` là **hàm mới** → `memo` thấy prop `onPress` khác → render lại.
</details>

**Bài 2.** Trong `NotesScreen`, tìm kiếm lọc trên mọi phím gõ. Với 10.000 ghi chú, làm sao để gõ vẫn mượt?

<details>
<summary>Lời giải</summary>

Dùng `useDeferredValue` của React 19 để việc lọc có độ ưu tiên thấp hơn việc cập nhật ô input:

```tsx
const [query, setQuery] = useState('');
const deferredQuery = useDeferredValue(query);
const visible = useMemo(() => filterNotes(notes, deferredQuery), [notes, deferredQuery]);
```

Hoặc debounce 200–300 ms (hook `useDebouncedValue` ở Tập 1 Chương 2). Với dữ liệu rất lớn, lọc
bằng SQL (`WHERE title LIKE ?`) thay vì trong JS. (Lời giải tham khảo; chưa đo trên máy thật.)
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- Expo — React Compiler: https://github.com/expo/expo/blob/main/docs/pages/guides/react-compiler.mdx
- React Native — Optimizing FlatList Configuration: https://github.com/facebook/react-native-website/blob/main/docs/optimizing-flatlist-configuration.md
- React Native — Performance overview: https://github.com/facebook/react-native-website/blob/main/docs/performance.md
- Expo — FlashList (SDK 57): https://github.com/expo/expo/blob/main/docs/pages/versions/v57.0.0/sdk/flash-list.mdx
- FlashList repo (README v2): https://github.com/Shopify/flash-list
- React — Profiler (mã nguồn react.dev): https://github.com/reactjs/react.dev/blob/main/src/content/reference/react/Profiler.md
- React — useDeferredValue: https://github.com/reactjs/react.dev/blob/main/src/content/reference/react/useDeferredValue.md
