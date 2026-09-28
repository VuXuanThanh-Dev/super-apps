# Chương 5 — Danh sách: FlatList và SectionList

## Mục tiêu

- Biết khi nào dùng `ScrollView`, `FlatList`, `SectionList`.
- Hiển thị danh sách có tìm kiếm, danh sách có nhóm, trạng thái rỗng, kéo để làm mới.
- Xử lý **tiếng Việt có dấu** khi tìm kiếm và sắp xếp.
- Viết test cho danh sách.

## Giải thích đơn giản

- `ScrollView` render **tất cả** con cùng lúc. Tốt cho màn hình ngắn (form, trang chi tiết).
- `FlatList` chỉ render các dòng **đang thấy** trên màn hình (virtualization — ảo hóa),
  giống `cdk-virtual-scroll-viewport` của Angular CDK. Dùng cho danh sách dài.
- `SectionList` là `FlatList` có **tiêu đề nhóm** (A, B, C... như danh bạ iPhone).

`FlatList` cần 3 thứ: `data` (mảng), `renderItem` (vẽ một dòng), `keyExtractor` (khóa duy nhất —
giống `track item.id` trong `@for`).

## Ví dụ

### Dữ liệu và hàm thuần

`examples/src/chapters/ch05/contacts.ts`:

```ts
// Bỏ dấu tiếng Việt để tìm kiếm và nhóm: "Ánh" → "anh", "Đặng" → "dang".
export function removeDiacritics(s: string): string {
  return s
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D');
}

export function searchContacts(list: Contact[], query: string): Contact[] {
  const q = removeDiacritics(query.trim().toLowerCase());
  if (!q) return list;
  return list.filter((c) => removeDiacritics(c.name.toLowerCase()).includes(q) || c.phone.replace(/\s/g, '').includes(q));
}
```

`normalize('NFD')` tách "á" thành "a" + dấu sắc; regex xóa phần dấu. Chữ **đ/Đ** không tách
được theo cách này nên phải thay riêng — một bẫy rất hay gặp với tiếng Việt.

### FlatList có tìm kiếm

```tsx
export function ContactList({ contacts = CONTACTS }: { contacts?: Contact[] }) {
  const [query, setQuery] = useState('');
  const data = useMemo(() => searchContacts(contacts, query), [contacts, query]);
  return (
    <View style={{ flex: 1 }}>
      <TextInput accessibilityLabel="Tìm liên hệ" placeholder="Tìm tên hoặc số" value={query} onChangeText={setQuery} style={styles.search} />
      <FlatList
        data={data}
        keyExtractor={(c) => c.id}
        renderItem={({ item }) => <Row contact={item} />}
        ItemSeparatorComponent={() => <View style={styles.sep} />}
        ListEmptyComponent={<Text style={styles.empty}>Không tìm thấy</Text>}
      />
    </View>
  );
}
```

### SectionList có nhóm chữ cái

```ts
export function groupByLetter(list: Contact[]): ContactSection[] {
  const map = new Map<string, Contact[]>();
  for (const c of list) {
    const letter = removeDiacritics(c.name.charAt(0)).toUpperCase();
    map.set(letter, [...(map.get(letter) ?? []), c]);
  }
  return [...map.entries()]
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([title, data]) => ({ title, data: [...data].sort((x, y) => x.name.localeCompare(y.name, 'vi')) }));
}
```

```tsx
<SectionList
  sections={sections}
  keyExtractor={(c) => c.id}
  renderItem={({ item }) => <Row contact={item} />}
  renderSectionHeader={({ section }) => <Text accessibilityRole="header" style={styles.header}>{section.title}</Text>}
  stickySectionHeadersEnabled
/>
```

### Kết quả test thật (2026-09-28)

```text
PASS src/chapters/ch05/lists.test.tsx
  Chương 5 — danh sách
    ✓ removeDiacritics xử lý cả chữ đ/Đ
    ✓ searchContacts tìm không dấu và theo số điện thoại
    ✓ groupByLetter gom "An" và "Ánh" vào nhóm A
    ✓ ContactList lọc khi gõ
    ✓ Bài tập 2: phân biệt "Danh bạ trống" và "Không tìm thấy"
    ✓ ContactSections hiện tiêu đề nhóm
PASS src/chapters/ch05/exercise.solution.test.tsx
  ✓ sortContacts theo tiếng Việt
  ✓ bấm nút đổi thứ tự, kéo để làm mới gọi load()
Test Suites: 2 passed, 2 total
Tests:       8 passed, 8 total
```

Trên Expo Go: tab **Lab** → "Ch.5 — FlatList + tìm kiếm" và "Ch.5 — SectionList" (**NOT RUN**).

## Đi sâu

### Hiệu năng FlatList

Tài liệu RN có trang "Optimizing FlatList Configuration". Các ý chính:

- `keyExtractor` trả về id ổn định (không dùng index nếu danh sách thay đổi thứ tự).
- Component dòng bọc `memo` (xem `TaskItem` ở Chương 8) và callback ổn định (`useCallback`),
  để dòng không render lại khi không đổi.
- `initialNumToRender`, `windowSize`: đánh đổi giữa bộ nhớ và khoảng trắng khi cuộn nhanh.
- `getItemLayout`: nếu mọi dòng cùng chiều cao, cho FlatList biết trước để khỏi đo.
- `FlatList` là `PureComponent`: nếu dòng phụ thuộc state bên ngoài `data`, truyền
  `extraData={selectedId}` để nó biết cần render lại.

Tập 3 so sánh với `@shopify/flash-list` (có trong Expo Go SDK 57).

### Sắp xếp tiếng Việt: `localeCompare(…, 'vi')`

Bảng chữ cái tiếng Việt: A Ă Â B C D **Đ** E Ê ... Với `localeCompare(b, 'vi')`, "Đặng" đứng
**sau** "Dũng". Test ở bài tập chứng minh điều này (sắp Z→A thì "Đặng Minh" đứng đầu). Nếu
chỉ dùng `a < b`, thứ tự sẽ theo mã Unicode và sai với người Việt.

> Lưu ý: kết quả `localeCompare` phụ thuộc dữ liệu ICU của môi trường chạy. Test trong sách
> chạy trên Node 22 (có full ICU). Trên iPhone, Hermes dùng dữ liệu locale của hệ điều hành —
> chúng tôi **chưa kiểm tra** trên máy thật (**UNVERIFIED**).

### Pull-to-refresh

`FlatList` có sẵn `refreshing` + `onRefresh`: kéo xuống ở đầu danh sách → hiện vòng xoay → gọi
`onRefresh`. Không cần thư viện.

## Lỗi và bẫy thường gặp

- **`FlatList` trong `ScrollView` cùng chiều** → cảnh báo "VirtualizedLists should never be nested"
  và mất ảo hóa. Dùng `ListHeaderComponent`/`ListFooterComponent` thay vì bọc ScrollView.
- **Thiếu `keyExtractor`/key trùng** → dòng nhảy lung tung khi lọc.
- **Tìm kiếm không ra "Đặng" khi gõ "dang"**: quên thay `đ`.
- **FlatList không cuộn**: cha không có `flex: 1` (không có chiều cao xác định).
- **Dòng không cập nhật khi chọn**: quên `extraData`.

## Tóm tắt

- Ngắn → `ScrollView`; dài → `FlatList`; có nhóm → `SectionList`.
- Luôn có `keyExtractor`, `ListEmptyComponent`, và `flex: 1` ở cha.
- Tiếng Việt: `normalize('NFD')` + thay `đ/Đ`; sắp xếp bằng `localeCompare(…, 'vi')`.

## Bài tập (có lời giải)

**Bài 1.** Thêm nút đổi thứ tự **A→Z / Z→A** và **kéo để làm mới** (gọi một hàm `load()` trả
Promise). Viết test cho cả hai.

<details>
<summary>Lời giải</summary>

`examples/src/chapters/ch05/exercise.solution.tsx`:

```tsx
export function sortContacts(list: Contact[], dir: SortDir): Contact[] {
  const sorted = [...list].sort((a, b) => a.name.localeCompare(b.name, 'vi'));
  return dir === 'asc' ? sorted : sorted.reverse();
}

export function SortableContacts({ load = async () => CONTACTS }: { load?: () => Promise<Contact[]> }) {
  const [dir, setDir] = useState<SortDir>('asc');
  const [items, setItems] = useState(CONTACTS);
  const [refreshing, setRefreshing] = useState(false);
  const data = useMemo(() => sortContacts(items, dir), [items, dir]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    setItems(await load());
    setRefreshing(false);
  }, [load]);

  return (
    <View style={{ flex: 1 }}>
      <Pressable accessibilityRole="button" onPress={() => setDir((d) => (d === 'asc' ? 'desc' : 'asc'))}>
        <Text style={{ padding: 12 }}>{dir === 'asc' ? 'Sắp xếp: A→Z' : 'Sắp xếp: Z→A'}</Text>
      </Pressable>
      <FlatList testID="sortable-list" data={data} keyExtractor={(c) => c.id}
        renderItem={({ item }) => <Text style={{ padding: 12 }}>{item.name}</Text>}
        refreshing={refreshing} onRefresh={onRefresh} />
    </View>
  );
}
```

Trong test, kéo để làm mới được giả lập bằng `await fireEvent(list, 'refresh')`.
Chú ý `[...list].sort()` — `sort()` sửa mảng tại chỗ, nên phải sao chép trước (immutability).
</details>

**Bài 2.** Trong `ContactList`, khi danh sách rỗng vì **chưa có dữ liệu** (khác với "không tìm
thấy"), hiện "Danh bạ trống". Chỉ sửa `ListEmptyComponent`.

<details>
<summary>Lời giải</summary>

```tsx
ListEmptyComponent={
  <Text style={styles.empty}>{contacts.length === 0 ? 'Danh bạ trống' : 'Không tìm thấy'}</Text>
}
```

Lời giải này đã được áp dụng trong `ContactList.tsx`, và test nằm trong `lists.test.tsx`
("Bài tập 2: phân biệt …"): `await render(<ContactList contacts={[]} />)` rồi
`expect(screen.getByText('Danh bạ trống')).toBeOnTheScreen()`.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- Using List Views: https://github.com/facebook/react-native-website/blob/main/docs/using-a-listview.md
- FlatList: https://github.com/facebook/react-native-website/blob/main/docs/flatlist.md
- SectionList: https://github.com/facebook/react-native-website/blob/main/docs/sectionlist.md
- ScrollView: https://github.com/facebook/react-native-website/blob/main/docs/scrollview.md
- Optimizing FlatList Configuration: https://github.com/facebook/react-native-website/blob/main/docs/optimizing-flatlist-configuration.md
