# Chương 7 — Form và nhập liệu

## Mục tiêu

- Dùng `TextField`, `TextFormField`, `TextEditingController`, `FocusNode`/`textInputAction`.
- Xây form có kiểm tra (validation) bằng `Form` + `GlobalKey<FormState>` + `validator`.
- Viết validator là **hàm thuần** để test dễ (giống `Validators` của Angular).
- Hiện/ẩn mật khẩu, bàn phím email, nút "Tiếp" trên bàn phím iPhone.

## Giải thích đơn giản

| Angular Reactive Forms | Flutter |
|---|---|
| `FormGroup` | `Form` + `GlobalKey<FormState>` |
| `FormControl` + `<input formControlName>` | `TextFormField` (+ `TextEditingController` để đọc/ghi giá trị) |
| `Validators.required` | `validator: (value) => value!.isEmpty ? 'Bắt buộc' : null` |
| `Validators.compose([...])` | hàm `compose` tự viết (bên dưới) |
| `form.markAllAsTouched(); if (form.valid)` | `if (formKey.currentState!.validate())` |
| `(input)` / `valueChanges` | `onChanged:` / `controller.addListener` |

Quy ước của Flutter: validator trả về **chuỗi lỗi** nếu sai, **`null`** nếu đúng. `Form` gom mọi
`TextFormField` bên dưới; `validate()` chạy hết validator và hiện lỗi ngay dưới từng ô.

## Ví dụ

### Validator là hàm thuần — `examples/lib/chapters/ch07/validators.dart`

```dart
typedef Validator = String? Function(String? value);

Validator requiredField([String message = 'Bắt buộc nhập']) =>
    (value) => (value == null || value.trim().isEmpty) ? message : null;

Validator minLength(int n) => (value) => (value ?? '').trim().length < n ? 'Tối thiểu $n ký tự' : null;

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

Validator email() =>
    (value) => (value == null || value.isEmpty || _emailRe.hasMatch(value.trim())) ? null : 'Email không hợp lệ';

/// Ghép nhiều validator: trả về lỗi đầu tiên (giống `Validators.compose`).
Validator compose(List<Validator> validators) => (value) {
  for (final v in validators) {
    final error = v(value);
    if (error != null) return error;
  }
  return null;
};
```

`typedef` đặt tên cho một kiểu hàm. `[String message = ...]` là **tham số vị trí tùy chọn** (khác `{}` là tham số có tên).

### Form đăng ký — `sign_up_form.dart` (rút gọn)

```dart
class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    // validate() chạy mọi validator và hiện lỗi dưới từng ô (giống markAllAsTouched()).
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(SignUpData(name: _name.text.trim(), email: _email.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Họ tên'),
            textInputAction: TextInputAction.next, // phím "Tiếp" trên bàn phím iPhone
            validator: compose([requiredField(), minLength(2)]),
          ),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            validator: compose([requiredField(), email()]),
          ),
          TextFormField(
            controller: _password,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: compose([requiredField(), minLength(8)]),
          ),
          FilledButton(onPressed: _submit, child: const Text('Đăng ký')),
        ],
      ),
    );
  }
}
```

(Bản đầy đủ có thêm các `SizedBox` khoảng cách.) `TextInputAction.next` làm bàn phím hiện nút "Tiếp" và tự chuyển
focus sang ô kế tiếp; `.done` hiện "Xong" và gọi `onFieldSubmitted`.

### Test form

```dart
testWidgets('SignUpForm hiện lỗi, rồi gửi dữ liệu khi hợp lệ', (tester) async {
  SignUpData? sent;
  await pumpApp(tester, SignUpForm(onSubmit: (d) => sent = d));
  await tester.tap(find.text('Đăng ký'));
  await tester.pump();
  expect(find.text('Bắt buộc nhập'), findsNWidgets(3));
  expect(sent, isNull);

  await tester.enterText(find.widgetWithText(TextFormField, 'Họ tên'), 'Nobin');
  await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'nobin@example.com');
  await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu'), 'matkhau123');
  await tester.tap(find.text('Đăng ký'));
  await tester.pump();
  expect(sent?.name, 'Nobin');
});
```

Kết quả thật (2026-09-30, `flutter test --reporter expanded test/chapters/ch07_test.dart`):

```text
00:00 +0: Chương 7 — form validators thuần: requiredField, email, minLength, compose
00:00 +1: Chương 7 — form SignUpForm hiện lỗi, rồi gửi dữ liệu khi hợp lệ
00:01 +2: Chương 7 — form nút mắt bật/tắt ẩn mật khẩu
00:01 +3: Chương 7 — form Bài 1: matchesField so sánh với giá trị hiện tại của ô khác
00:01 +4: Chương 7 — form Bài 2: ChangePasswordForm chỉ gọi onDone khi hai ô khớp
00:01 +5: All tests passed!
```

## Đi sâu

### `TextField` hay `TextFormField`?

- `TextField`: ô nhập đơn lẻ (tìm kiếm, chat). Đọc giá trị qua `onChanged` hoặc controller.
- `TextFormField`: `TextField` + tích hợp `Form` (validator, `onSaved`, reset). Dùng trong form.

### Khi nào hiện lỗi?

`autovalidateMode`:
- `disabled` (mặc định): chỉ khi gọi `validate()`.
- `onUserInteraction`: sau khi người dùng gõ vào ô đó (giống `touched && invalid`). App mẫu dùng mode này.
- `always`: luôn luôn (dễ làm người dùng khó chịu ngay khi mở màn hình).

### Controller và vòng đời

`TextEditingController` giữ văn bản + vị trí con trỏ và **phải `dispose()`**. Tạo nó trong `State` (không tạo
trong `build`, nếu không mỗi lần build sẽ mất chữ đang gõ). Đặt giá trị ban đầu: `TextEditingController(text: task.title)` —
app mẫu làm vậy ở màn hình "Sửa việc".

### Validator phụ thuộc ô khác

Validator nhận **hàm đọc** giá trị ô kia (`() => _password.text`), không nhận chuỗi cố định — vì validator được tạo
một lần khi build, còn giá trị thì thay đổi (Bài 1).

### Thư viện form

Docs cookbook dùng `Form` có sẵn. Form lớn có thể dùng package bên ngoài (ví dụ `flutter_form_builder`, `reactive_forms`
— package sau mô phỏng Reactive Forms của Angular). Sách **không** dùng để giữ ít phụ thuộc; chưa kiểm chứng phiên bản.

## Lỗi và bẫy thường gặp

- **Tạo controller trong `build`** → mất chữ khi rebuild, rò rỉ bộ nhớ.
- **Quên `dispose` controller**.
- **Validator trả về `''` (chuỗi rỗng)** thay vì `null` → Flutter coi là lỗi (hiện dòng trống đỏ).
- **Tên hàm trùng thư viện test**: sách đặt tên validator là `matches` và gặp lỗi thật khi chạy test:
  `'matches' is imported from both 'package:matcher/src/string_matchers.dart' and '.../exercise_solution.dart'`
  → đổi tên thành `matchesField` (hoặc dùng `import ... as`).
- **Bàn phím che ô nhập** khi không dùng `Scaffold`/`ListView` → bọc form trong `ListView` hoặc `SingleChildScrollView`.

## Tóm tắt

- `Form` + `GlobalKey<FormState>` + `TextFormField(validator:)` ≈ Reactive Forms.
- Validator = hàm thuần `String? Function(String?)`; ghép bằng `compose`; test không cần UI.
- Controller phải `dispose`. `textInputAction` + `keyboardType` cho trải nghiệm bàn phím tốt trên iPhone.

## Bài tập (có lời giải)

**Bài 1.** Viết validator `matchesField(other)` cho ô "Nhập lại mật khẩu": lỗi "Mật khẩu không khớp" khi khác giá trị ô mật khẩu.

<details>
<summary>Lời giải</summary>

`examples/lib/chapters/ch07/exercise_solution.dart`:

```dart
Validator matchesField(String Function() other, [String message = 'Mật khẩu không khớp']) =>
    (value) => value == other() ? null : message;
```

Test: `password = 'abc12345'` → hợp lệ; đổi `password = 'khac'` → cùng validator giờ báo lỗi. Điều này chứng
minh validator đọc giá trị **hiện tại** chứ không chụp giá trị cũ.
</details>

**Bài 2.** Làm form "Đổi mật khẩu" gồm hai ô dùng `matchesField`; chỉ gọi `onDone` khi hợp lệ.

<details>
<summary>Lời giải</summary>

```dart
Form(
  key: _formKey,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextFormField(
        controller: _password,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
        validator: compose([requiredField(), minLength(8)]),
      ),
      TextFormField(
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu'),
        validator: matchesField(() => _password.text),
      ),
      FilledButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) widget.onDone();
        },
        child: const Text('Đổi mật khẩu'),
      ),
    ],
  ),
)
```

Test nhập `matkhau123` / `matkhau999` → thấy "Mật khẩu không khớp", `onDone` chưa gọi; sửa ô 2 thành
`matkhau123` → `onDone` được gọi.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-30 (đọc file nguồn docs ở commit `ab59c61`):

- Tutorial: Handle user input — https://docs.flutter.dev/learn/pathway/tutorial/user-input —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/learn/pathway/tutorial/user-input.md
- Cookbook: Build a form with validation — https://docs.flutter.dev/cookbook/forms/validation —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/forms/validation.md
- Cookbook: Retrieve the value of a text field — https://docs.flutter.dev/cookbook/forms/retrieve-input —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/forms/retrieve-input.md
- Cookbook: Focus and text fields — https://docs.flutter.dev/cookbook/forms/focus —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/forms/focus.md
- Cookbook: Handle changes to a text field — https://docs.flutter.dev/cookbook/forms/text-field-changes —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/cookbook/forms/text-field-changes.md
- Flutter for React Native developers (Form input) — https://docs.flutter.dev/flutter-for/react-native-devs —
  https://github.com/flutter/website/blob/ab59c614e780e2d6d44f07ae4a96238028f581a5/sites/docs/src/content/flutter-for/react-native-devs.md
