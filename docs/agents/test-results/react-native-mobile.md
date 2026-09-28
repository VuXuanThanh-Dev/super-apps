# Test result — react-native-mobile

- Date: 2026-09-28
- Mode: real (headless `claude -p`)
- Delegated to: react-native-mobile
- Correct agent triggered: yes
- Tools the subagent used: Bash, Read, Write

## Prompt

ContactList.tsx is slow with 2000 contacts and React warns about keys. Rewrite it properly for our Expo app (write ContactList.fixed.tsx).

## Result (verbatim)

The `react-native-mobile` subagent finished. Here is its full answer, unchanged:

---

### Kế hoạch
Đọc `ContactList.tsx` gốc, xác định 2 vấn đề (ScrollView/.map không ảo hoá + key không ổn định), viết bản sửa vào file mới `ContactList.fixed.tsx` cùng thư mục, không sửa file gốc.

### Ghi chú về repo
Thư mục này chỉ chứa `ContactList.tsx`, `.git`, `.claude` — không có `package.json`, `node_modules`, hay `tsconfig.json` (không phải một dự án Expo đầy đủ). Không có `@shopify/flash-list` trong dependencies (vì không có dependencies nào cả) nên tôi dùng `FlatList` từ `react-native`.

### File gốc (`ContactList.tsx`) — vấn đề tìm thấy
```tsx
export default function ContactList({ load }: { load: () => Promise<Contact[]> }) {
  const [contacts, setContacts] = useState<Contact[]>([]);
  useEffect(() => {
    load().then(setContacts);
  });                      // <-- không có dependency array
  return (
    <ScrollView>
      {contacts.map((c) => (
        <View>            // <-- không có key -> React warning
          <Text>{c.name}</Text>
          <Text>{c.phone}</Text>
        </View>
      ))}
    </ScrollView>
  );
}
```
Ngoài 2 lỗi được mô tả (ScrollView/.map không ảo hoá, thiếu key ổn định), tôi phát hiện thêm một bug nghiêm trọng: `useEffect` không có mảng dependency, nên nó chạy lại sau **mỗi lần render** — kể cả lần render do chính `setContacts` bên trong nó gây ra → tạo vòng lặp gọi `load()` vô hạn. Với 2000 contact, bug này còn gây hại hơn cả việc thiếu virtualization, nên tôi đã sửa luôn (giải thích bên dưới).

### File mới: `ContactList.fixed.tsx`
Đường dẫn: `<workdir>/react-native-mobile/ContactList.fixed.tsx`

```tsx
import React, { useCallback, useEffect, useState } from 'react';
import { FlatList, ListRenderItemInfo, Text, View } from 'react-native';

type Contact = { id: string; name: string; phone: string };

type ContactRowProps = {
  contact: Contact;
};

// Memoized row: with ~2000 items, this keeps FlatList from re-rendering
// every row whenever the parent list re-renders (e.g. on scroll/state churn).
const ContactRow = React.memo(function ContactRow({ contact }: ContactRowProps) {
  return (
    <View>
      <Text>{contact.name}</Text>
      <Text>{contact.phone}</Text>
    </View>
  );
});

export default function ContactList({ load }: { load: () => Promise<Contact[]> }) {
  const [contacts, setContacts] = useState<Contact[]>([]);

  useEffect(() => {
    let isMounted = true;
    load().then((result) => {
      if (isMounted) {
        setContacts(result);
      }
    });
    return () => {
      isMounted = false;
    };
    // Empty deps: fetch once on mount. The original effect had no
    // dependency array, so it re-ran after every render (including the
    // render caused by its own setContacts call), creating an infinite
    // fetch loop that got worse the more contacts were loaded.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Stable function identity so FlatList doesn't think renderItem changed
  // on every parent render, which would defeat row memoization.
  const renderItem = useCallback(
    ({ item }: ListRenderItemInfo<Contact>) => <ContactRow contact={item} />,
    []
  );

  const keyExtractor = useCallback((item: Contact) => item.id, []);

  return (
    <FlatList
      data={contacts}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
    />
  );
}
```

### Giải thích từng chỗ sửa
1. **`ScrollView` + `.map()` → `FlatList`**: `FlatList` chỉ render các hàng đang nằm trong (hoặc gần) viewport (ảo hoá/windowing), thay vì mount toàn bộ 2000 `View`/`Text` cùng lúc như `ScrollView.map()`. Đây là nguyên nhân chính gây chậm.
2. **Thiếu key → `keyExtractor` ổn định**: Trước đây `<View>` trong `.map()` không có `key` nào (còn tệ hơn dùng index), nên React cảnh báo và phải diff lại toàn bộ cây mỗi lần data đổi. `keyExtractor={(item) => item.id}` dùng id thật của contact, ổn định giữa các lần render.
3. **Row component tách riêng + `React.memo`**: `ContactRow` chỉ nhận prop `contact`; nhờ `React.memo`, nếu object `contact` ở một index không đổi (cùng reference), hàng đó không re-render khi list re-render vì lý do khác.
4. **`useCallback` cho `renderItem` và `keyExtractor`**: giữ nguyên function identity qua các lần render của `ContactList`, tránh việc `FlatList` coi đây là prop mới và làm mất tác dụng memoization của `ContactRow`.
5. **Không định nghĩa hàm/object inline trong renderItem theo cách phá memoization**: `renderItem` chỉ tạo JSX truyền thẳng `item` xuống `ContactRow` đã memo — không tạo object style/callback mới mỗi item.
6. **Sửa bug vòng lặp vô hạn trong `useEffect`**: thêm `[]` làm dependency array để chỉ fetch một lần khi mount, và thêm cờ `isMounted` để tránh gọi `setState` sau khi component unmount (cảnh báo phổ biến khi điều hướng nhanh trong Expo Router). Đây là thay đổi ngoài 2 vấn đề được liệt kê ban đầu, nhưng cần thiết để bản "fixed" thực sự chạy đúng — nếu muốn tôi revert lại đúng behavior gốc (chạy lại mỗi render) thì báo tôi biết.
7. Props/interface (`{ load: () => Promise<Contact[]> }`), type `Contact`, và nội dung hiển thị mỗi hàng (`name`/`phone`, không style) được giữ nguyên y hệt bản gốc.

### Kiểm tra đã chạy (kết quả thật)
Repo này không có `package.json`/`tsconfig.json`/`node_modules` nên không thể chạy `npx tsc`, `npx eslint`, `npx jest` trực tiếp trong repo (không có project config, không có RN/React cài đặt). Để vẫn xác minh type một cách thực chất, tôi:
- Copy file vào thư mục scratchpad tạm, cài `react@18`, `react-native@0.74`, `@types/react@18` (`npm install`, 600 packages, thành công).
- Chạy: `npx tsc --noEmit --jsx react-native --target es2019 --module esnext --moduleResolution bundler --strict --esModuleInterop --skipLibCheck ContactList.fixed.tsx`
  → **Kết quả: không có lỗi nào** (strict mode, clean).
- Trước đó, chạy cùng lệnh ngay trong repo gốc (không có `react`/`react-native` cài) chỉ báo `TS2307: Cannot find module 'react'` / `'react-native'` — đúng như kỳ vọng vì thiếu node_modules, không phải lỗi logic trong code.
- Đã xoá thư mục scratchpad tạm sau khi kiểm tra xong; repo gốc chỉ còn đúng 2 file: `ContactList.tsx` (không đổi) và `ContactList.fixed.tsx` (mới tạo).

Không chạy được `eslint`/`jest` vì repo không có cấu hình/test runner nào để chạy. Nếu bạn có eslint config và jest setup ở một chỗ khác trong monorepo thật, cho tôi biết đường dẫn để tôi chạy lại cho chuẩn.

### Cách thử trên iPhone (Expo Go)
Trong app Expo thật, đổi import ở nơi dùng `ContactList` sang file `ContactList.fixed.tsx`, chạy `npx expo start`, quét QR bằng Expo Go, cuộn nhanh qua danh sách ~2000 contact — sẽ thấy cuộn mượt hơn nhiều so với bản `ScrollView`, và không còn warning "Each child in a list should have a unique key" trong Metro log/LogBox.

### Góc nhìn Angular
- `FlatList` ở đây giống `*ngFor` với `trackBy` trong một `cdk-virtual-scroll-viewport`: `keyExtractor` ≈ hàm `trackBy`, còn việc "chỉ render item trong viewport" chính là CDK Virtual Scrolling.
- `React.memo(ContactRow)` ≈ `ChangeDetectionStrategy.OnPush` trên component con: chỉ re-render khi input (`@Input() contact`) đổi reference.
- `useCallback`/`useEffect([])` ≈ đảm bảo một "effect" (giống `ngOnInit`) chỉ chạy một lần thay vì mỗi chu kỳ change detection — vấn đề gốc giống như quên `takeUntil`/để một subscription tự gọi lại chính nó trong `ngDoCheck`.
