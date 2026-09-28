# Chương 6 — Form và nhập liệu

## Mục tiêu

- Dùng `TextInput`, `Switch` theo kiểu **controlled** (giá trị nằm trong state).
- Validate bằng **hàm thuần**, hiển thị lỗi đúng lúc (touched / submitted).
- Xử lý bàn phím iPhone: loại bàn phím, nút "Next", `KeyboardAvoidingView`.
- Test form bằng `userEvent.type` và `userEvent.press`.

## Giải thích đơn giản

Trong Angular, bạn có `FormGroup` giữ giá trị, trạng thái và lỗi. React Native không có sẵn thứ
đó. Ta tự ghép 3 mảnh nhỏ:

1. **State giá trị**: `const [values, setValues] = useState(EMPTY)`.
2. **Hàm validate thuần**: `validateSignUp(values) → { email?: string, ... }`
   (giống `Validators`, nhưng chỉ là một hàm — test cực dễ).
3. **Khi nào hiện lỗi**: sau khi rời ô (`onBlur` → touched) hoặc sau khi bấm Gửi (submitted).

## Ví dụ

### Hàm validate

`examples/src/chapters/ch06/validation.ts`:

```ts
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function validateSignUp(v: SignUpValues): SignUpErrors {
  const e: SignUpErrors = {};
  if (!v.email.trim()) e.email = 'Vui lòng nhập email';
  else if (!EMAIL_RE.test(v.email.trim())) e.email = 'Email không hợp lệ';
  if (v.password.length < 8) e.password = 'Mật khẩu cần ít nhất 8 ký tự';
  else if (!/\d/.test(v.password)) e.password = 'Mật khẩu cần ít nhất 1 chữ số';
  if (v.confirm !== v.password) e.confirm = 'Mật khẩu nhập lại không khớp';
  if (!v.acceptTerms) e.acceptTerms = 'Bạn cần đồng ý điều khoản';
  return e;
}

export const isValid = (e: SignUpErrors) => Object.keys(e).length === 0;
```

### Form đăng ký

Trích `examples/src/chapters/ch06/SignUpForm.tsx`:

```tsx
const errors: SignUpErrors = validateSignUp(values); // tính lại mỗi lần render: đơn giản, đủ nhanh
const show = (k: keyof SignUpValues) => (submitted || touched[k]) && errors[k];

<TextInput
  accessibilityLabel="Email"
  placeholder="email@vidu.com"
  value={values.email}
  onChangeText={(t) => set('email', t)}
  onBlur={blur('email')}
  autoCapitalize="none"
  autoComplete="email"
  keyboardType="email-address"
  returnKeyType="next"
  onSubmitEditing={() => passwordRef.current?.focus()}
  style={styles.input}
/>
{show('email') ? <Text style={styles.error}>{errors.email}</Text> : null}

<TextInput
  ref={passwordRef}
  accessibilityLabel="Mật khẩu"
  secureTextEntry
  textContentType="newPassword"
  returnKeyType="next"
  onSubmitEditing={() => confirmRef.current?.focus()}
  /* ... */
/>
```

- `keyboardType="email-address"`: iPhone hiện bàn phím có `@`.
- `autoCapitalize="none"`: không tự viết hoa chữ đầu email.
- `secureTextEntry`: ẩn mật khẩu. `textContentType="newPassword"`: iOS gợi ý mật khẩu mạnh.
- `returnKeyType="next"` + `onSubmitEditing` + `ref.focus()`: bấm "Next" nhảy sang ô tiếp theo.

Toàn bộ form nằm trong:

```tsx
<KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
  <ScrollView contentContainerStyle={styles.form} keyboardShouldPersistTaps="handled">
    {/* ... */}
  </ScrollView>
</KeyboardAvoidingView>
```

để bàn phím không che ô nhập, và bấm nút khi bàn phím đang mở vẫn ăn ngay lần đầu.

### Test

```tsx
it('gửi form hợp lệ', async () => {
  const onSubmit = jest.fn();
  const user = userEvent.setup();
  await render(<SignUpForm onSubmit={onSubmit} />);
  await user.type(screen.getByLabelText('Email'), 'nobin@vidu.vn');
  await user.type(screen.getByLabelText('Mật khẩu'), 'matkhau1');
  await user.type(screen.getByLabelText('Nhập lại mật khẩu'), 'matkhau1');
  await fireEvent(screen.getByLabelText('Đồng ý điều khoản'), 'valueChange', true);
  await user.press(screen.getByRole('button', { name: 'Đăng ký' }));
  expect(onSubmit).toHaveBeenCalledWith({ email: 'nobin@vidu.vn', password: 'matkhau1', confirm: 'matkhau1', acceptTerms: true });
});
```

`userEvent.type` gõ từng ký tự (focus → keyPress → changeText → blur) như người thật.
`userEvent` v14 chưa có hàm riêng cho `Switch` (chỉ có press, longPress, type, clear, paste, scrollTo...), nên dùng `fireEvent(el, 'valueChange', true)`.

Kết quả (2026-09-28):

```text
PASS src/chapters/ch06/forms.test.tsx
  Chương 6 — form
    ✓ validateSignUp trả lỗi đúng từng trường
    ✓ không hiện lỗi trước khi người dùng chạm vào form
    ✓ gửi form hợp lệ
    ✓ bấm Đăng ký khi trống thì hiện tất cả lỗi
PASS src/chapters/ch06/exercise.solution.test.ts
  ✓ validatePhone("0901 234 567") → undefined
  ✓ validatePhone("+84 901 234 567") → undefined
  ✓ validatePhone("090.123.4567") → undefined
  ✓ validatePhone("12345") → "Số điện thoại cần 10 chữ số và bắt đầu bằng 0"
  ✓ validatePhone("") → "Vui lòng nhập số điện thoại"
  ✓ normalizePhone đổi +84 thành 0
Test Suites: 2 passed, 2 total
Tests:       10 passed, 10 total
```

Form thứ hai trong sách: `src/features/tasks/TaskForm.tsx` (app mẫu, Chương 8) dùng cùng mẫu,
thêm nhóm radio chọn mức ưu tiên với `accessibilityRole="radio"`.

## Đi sâu

### So sánh với Reactive Forms

| Reactive Forms | Mẫu trong sách |
|---|---|
| `new FormGroup({ email: new FormControl('') })` | `useState<SignUpValues>(EMPTY)` |
| `Validators.required, Validators.email` | `validateSignUp()` thuần |
| `control.touched` | `touched[k]` cập nhật ở `onBlur` |
| `form.invalid` | `!isValid(errors)` |
| `form.patchValue(x)` | `setValues((prev) => ({ ...prev, ...x }))` |
| `valueChanges` | chính là render lại; dùng `useEffect` nếu cần side effect |

Khi form lớn (nhiều bước, mảng động), cân nhắc thư viện `react-hook-form` (hiệu năng tốt vì
dùng uncontrolled input) kết hợp `zod` cho schema. Sách không dùng để giữ ít phụ thuộc.

### Tính lỗi mỗi lần render có chậm không?

Không đáng kể với form nhỏ: vài phép so sánh chuỗi. Lợi ích: lỗi **luôn khớp** với giá trị, không
có state lỗi riêng để quên cập nhật. Nếu validate nặng (ví dụ gọi server), dùng debounce
(`useDebouncedValue` ở Chương 2) và làm trong `useEffect`.

### Bàn phím

- `keyboardType`: `default`, `number-pad`, `decimal-pad`, `email-address`, `phone-pad`...
- `KeyboardAvoidingView` trên iOS thường dùng `behavior="padding"`.
- `Keyboard.dismiss()` để ẩn bàn phím chủ động.
- `keyboardShouldPersistTaps="handled"` trên `ScrollView` để bấm nút không bị "nuốt" lần chạm đầu.

## Lỗi và bẫy thường gặp

- **Hiện lỗi ngay khi mở form** → khó chịu. Chỉ hiện sau blur hoặc submit.
- **Quên `autoCapitalize="none"`** cho email/username → iPhone viết hoa chữ đầu.
- **Bàn phím che nút Gửi**: thiếu `KeyboardAvoidingView` hoặc `ScrollView`.
- **Validate trên giá trị cũ**: đọc `values` ngay sau `setValues(...)` — state chỉ đổi ở lần render
  sau. Tính trên object `next` bạn vừa tạo (xem `TaskForm.setField`).
- **Test gõ vào ô không tìm thấy**: thêm `accessibilityLabel` cho `TextInput`.

## Tóm tắt

- Form = state giá trị + hàm validate thuần + quy tắc hiển thị lỗi.
- Cấu hình bàn phím đúng làm app "cảm giác native" hơn.
- Test bằng `userEvent.type/press`; `Switch` dùng `fireEvent(…, 'valueChange', …)`.

## Bài tập (có lời giải)

**Bài 1.** Viết `validatePhone(input)` cho số di động Việt Nam: 10 chữ số, bắt đầu bằng 0; chấp
nhận khoảng trắng, dấu chấm, gạch ngang, và tiền tố `+84`. Viết test dạng bảng (`test.each`).

<details>
<summary>Lời giải</summary>

`examples/src/chapters/ch06/exercise.solution.ts`:

```ts
export function normalizePhone(input: string): string {
  const digits = input.replace(/[\s.-]/g, '');
  return digits.startsWith('+84') ? `0${digits.slice(3)}` : digits;
}

export function validatePhone(input: string): string | undefined {
  if (!input.trim()) return 'Vui lòng nhập số điện thoại';
  const p = normalizePhone(input);
  if (!/^0\d{9}$/.test(p)) return 'Số điện thoại cần 10 chữ số và bắt đầu bằng 0';
  return undefined;
}
```

```ts
test.each([
  ['0901 234 567', undefined],
  ['+84 901 234 567', undefined],
  ['090.123.4567', undefined],
  ['12345', 'Số điện thoại cần 10 chữ số và bắt đầu bằng 0'],
  ['', 'Vui lòng nhập số điện thoại'],
])('validatePhone(%p) → %p', (input, expected) => {
  expect(validatePhone(input)).toBe(expected);
});
```

Đây là quy tắc **đơn giản hóa cho bài tập**, không phải quy định chính thức về đầu số của nhà mạng.
</details>

**Bài 2.** Gắn `validatePhone` vào `SignUpForm`: thêm ô "Số điện thoại" với `keyboardType="phone-pad"`.
Cần sửa những chỗ nào?

<details>
<summary>Lời giải</summary>

1. Thêm `phone: string` vào `SignUpValues` và `EMPTY`.
2. Trong `validateSignUp`: `const phoneError = validatePhone(v.phone); if (phoneError) e.phone = phoneError;`
3. Thêm `<TextInput accessibilityLabel="Số điện thoại" keyboardType="phone-pad" textContentType="telephoneNumber" …/>`
   và `{show('phone') ? <Text>{errors.phone}</Text> : null}`.
4. Cập nhật test "gửi form hợp lệ" để gõ số điện thoại.

TypeScript sẽ báo lỗi ở mọi chỗ còn thiếu `phone` (ví dụ `EMPTY`) — đó là lợi ích của việc khai
báo kiểu `SignUpValues` một lần.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- Handling Text Input: https://github.com/facebook/react-native-website/blob/main/docs/handling-text-input.md
- TextInput: https://github.com/facebook/react-native-website/blob/main/docs/textinput.md
- KeyboardAvoidingView: https://github.com/facebook/react-native-website/blob/main/docs/keyboardavoidingview.md
- Switch: https://github.com/facebook/react-native-website/blob/main/docs/switch.md
- RNTL user event API (tài liệu đi kèm gói npm v14): https://github.com/callstack/react-native-testing-library/blob/main/docs/api/user-event.md
