# Chương 1 — Quản lý state: useReducer, Context, Zustand

## Mục tiêu

- Phân biệt **local state**, **global client state** và **server state**.
- Biết khi nào dùng `useState`/`useReducer`, Context, và một store như **Zustand**.
- Viết store Zustand có **selector** và **persist** (lưu xuống máy).
- Test store không cần render.

## Giải thích đơn giản

Có 3 loại state trong một app:

| Loại | Ví dụ | Công cụ trong sách |
|---|---|---|
| Local (cục bộ) | ô input đang gõ, modal mở/đóng | `useState`, `useReducer` |
| Global client state | giỏ hàng, bài yêu thích, cài đặt | **Zustand** |
| Server state | danh sách bài viết từ API | **TanStack Query** (Chương 2) |

Ở Tập 1, app "Việc Cần Làm" dùng `useReducer` + Context. Cách đó ổn cho app nhỏ, nhưng có 2
nhược điểm: mọi component dùng Context sẽ render lại khi **bất kỳ** phần nào đổi, và phải
viết Provider. **Zustand** là một store nhỏ: tạo bằng một hàm, dùng bằng một hook, component
chỉ render lại khi **phần nó chọn** (selector) thay đổi.

Với Angular developer: Zustand store ≈ một `@Injectable({ providedIn: 'root' })` service có
các signal bên trong; selector ≈ `computed()`.

## Ví dụ

### useReducer — state cục bộ, logic tập trung

`examples/src/chapters/ch01/counterReducer.ts`:

```ts
export type CounterAction = { type: 'inc' } | { type: 'dec' } | { type: 'reset' };

export function counterReducer(state: number, action: CounterAction): number {
  switch (action.type) {
    case 'inc':
      return state + 1;
    case 'dec':
      return Math.max(0, state - 1);
    case 'reset':
      return 0;
  }
}
```

### Zustand — store toàn cục

`examples/src/chapters/ch01/cartStore.ts`:

```ts
export const useCart = create<CartState>()((set) => ({
  items: [],
  add: (item) =>
    set((s) => {
      const found = s.items.find((i) => i.id === item.id);
      return {
        items: found
          ? s.items.map((i) => (i.id === item.id ? { ...i, qty: i.qty + 1 } : i))
          : [...s.items, { ...item, qty: 1 }],
      };
    }),
  remove: (id) => set((s) => ({ items: s.items.filter((i) => i.id !== id) })),
  clear: () => set({ items: [] }),
}));

export const selectTotal = (s: Pick<CartState, 'items'>) => s.items.reduce((sum, i) => sum + i.price * i.qty, 0);
export const selectCount = (s: Pick<CartState, 'items'>) => s.items.reduce((n, i) => n + i.qty, 0);
```

Dùng trong component — **không cần Provider**:

```tsx
function CartBadge() {
  const count = useCart(selectCount); // chỉ render lại khi số lượng đổi
  return <Text accessibilityLabel="Số món">🛒 {count}</Text>;
}
```

### Persist — lưu store xuống máy

Store "yêu thích" của app mẫu (`examples/src/state/favorites.ts`) tự lưu vào AsyncStorage:

```ts
export const useFavorites = create<FavoritesState>()(
  persist(
    (set) => ({
      ids: [],
      toggle: (id) =>
        set((s) => ({ ids: s.ids.includes(id) ? s.ids.filter((x) => x !== id) : [...s.ids, id] })),
      clear: () => set({ ids: [] }),
    }),
    {
      name: 'favorites-v1', // khóa trong AsyncStorage
      storage: createJSONStorage(() => AsyncStorage),
    },
  ),
);

export const useIsFavorite = (id: number) => useFavorites((s) => s.ids.includes(id));
```

Tắt app mở lại, danh sách yêu thích vẫn còn.

### Test store — không cần render

Store Zustand dùng được ngoài React qua `getState()`:

```ts
beforeEach(() => useCart.getState().clear());

it('store Zustand: thêm cùng món thì tăng qty', () => {
  const { add } = useCart.getState();
  add({ id: 'a', name: 'A', price: 10000 });
  add({ id: 'a', name: 'A', price: 10000 });
  add({ id: 'b', name: 'B', price: 5000 });
  const state = useCart.getState();
  expect(selectCount(state)).toBe(3);
  expect(selectTotal(state)).toBe(25000);
});
```

Kết quả thật (2026-09-28):

```text
PASS src/chapters/ch01/state.test.tsx
    ✓ counterReducer không cho số âm
    ✓ store Zustand: thêm cùng món thì tăng qty
    ✓ bài tập: remove và formatVnd
    ✓ nhiều component đọc cùng store và cùng cập nhật
Tests:       4 passed, 4 total
PASS src/state/favorites.test.ts
  useFavorites (Zustand + persist)
    ✓ toggle thêm rồi bỏ một id
    ✓ tự lưu xuống AsyncStorage dưới khóa favorites-v1
```

Trên Expo Go: tab **Lab** → "Ch.1 — Zustand vs useReducer" (**NOT RUN** trong sandbox).

## Đi sâu

### So sánh các lựa chọn

| Thư viện | Stars (2026-09-28) | License | Hợp với ai |
|---|---|---|---|
| Zustand | 58.8k | MIT | Hầu hết app; ít code |
| Redux Toolkit | 11.2k | MIT | Team lớn, quen NgRx, cần DevTools/time-travel |
| Jotai | 21.3k | MIT | Thích mô hình "atom" giống Signals |

Chi tiết (last commit, nguồn) ở `STACK.md`. Quyết định của sách: **Zustand** cho client state
và **TanStack Query** cho server state — không trộn dữ liệu API vào store.

### Selector và render lại

`useCart((s) => s.items)` trả về mảng mới mỗi khi `items` đổi → component render lại.
`useCart(selectCount)` trả về một **số**; nếu số không đổi, không render lại.
Tránh selector trả về **object mới** mỗi lần (`(s) => ({ a: s.a, b: s.b })`). Hướng dẫn nâng cấp
lên Zustand v5 nói rõ: selector trả tham chiếu mới "may cause infinite loops" (lỗi
"Maximum update depth exceeded"). Dùng nhiều selector nhỏ, hoặc `useShallow` từ `zustand/react/shallow`.

### Persist: version và migrate

Khi đổi cấu trúc state, tăng tên khóa (`favorites-v2`) hoặc dùng tùy chọn `version` + `migrate`
của middleware persist để chuyển dữ liệu cũ. `partialize` để chỉ lưu một phần state.

## Lỗi và bẫy thường gặp

- **Để dữ liệu API trong Zustand** → phải tự viết loading/error/cache/refetch. Dùng TanStack Query.
- **Selector tạo object mới** → có thể lặp vô hạn ở Zustand v5. Dùng `useShallow`.
- **State rò giữa các test** vì store là singleton → `beforeEach(() => useStore.getState().clear())`.
- **Gọi `act()` không cần thiết** quanh `getState()` → RNTL 14 cảnh báo
  "You called act(async () => ...) without await". Store không cần `act` khi không có component.
- **Lưu dữ liệu nhạy cảm** (token) bằng persist + AsyncStorage → **không mã hóa**. Dùng
  `expo-secure-store` (Tập 3).

## Tóm tắt

- Local → `useState`/`useReducer`; global client → Zustand; server → TanStack Query.
- Zustand: không Provider, selector để giảm render, `persist` để lưu.
- Test store bằng `getState()`; reset giữa các test.

## Bài tập (có lời giải)

**Bài 1.** Thêm hành động `remove(id)` vào giỏ hàng và hàm `formatVnd(amount)` hiển thị
`1234567` thành `1.234.567 ₫`.

<details>
<summary>Lời giải</summary>

```ts
remove: (id) => set((s) => ({ items: s.items.filter((i) => i.id !== id) })),

export function formatVnd(amount: number): string {
  return `${amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.')} ₫`;
}
```

Test: `useCart.getState().remove('a')` → `items` rỗng; `formatVnd(1234567) === '1.234.567 ₫'`.
Có thể dùng `Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' })`, nhưng kết quả
phụ thuộc dữ liệu locale của engine (Hermes trên máy thật so với Node trong test), nên sách dùng
hàm tự viết để test ổn định.
</details>

**Bài 2.** Màn hình giỏ hàng cần hiển thị cả `count` và `total`. Viết sao cho component chỉ render
lại khi một trong hai giá trị đổi.

<details>
<summary>Lời giải</summary>

Cách 1 — hai selector riêng (dùng trong `CartDemo.tsx`: `CartBadge` và `CartTotal` là 2 component):

```tsx
const count = useCart(selectCount);
const total = useCart(selectTotal);
```

Cách 2 — một selector trả object, bọc `useShallow`:

```tsx
import { useShallow } from 'zustand/react/shallow';
const { count, total } = useCart(useShallow((s) => ({ count: selectCount(s), total: selectTotal(s) })));
```

`useShallow` so sánh từng thuộc tính thay vì so sánh tham chiếu object. (Cách 2 là lời giải tham
khảo, không có trong code dự án.)
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- Zustand — Persisting store data: https://github.com/pmndrs/zustand/blob/main/docs/reference/integrations/persisting-store-data.md
- Zustand — Testing guide: https://github.com/pmndrs/zustand/blob/main/docs/learn/guides/testing.md
- Zustand — Migrating to v5 (stable selector outputs): https://github.com/pmndrs/zustand/blob/main/docs/reference/migrations/migrating-to-v5.md
- Zustand repo: https://github.com/pmndrs/zustand
- Redux Toolkit repo: https://github.com/reduxjs/redux-toolkit
- Jotai repo: https://github.com/pmndrs/jotai
- React — Scaling up with Reducer and Context: https://github.com/reactjs/react.dev/blob/main/src/content/learn/scaling-up-with-reducer-and-context.md
