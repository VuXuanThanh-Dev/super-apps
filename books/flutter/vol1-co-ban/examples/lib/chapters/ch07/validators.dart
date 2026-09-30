/// Validator = hàm `String? Function(String?)`. Trả về null khi hợp lệ.
/// Giống `Validators.required`, `Validators.email` của Angular Reactive Forms.
typedef Validator = String? Function(String? value);

Validator requiredField([String message = 'Bắt buộc nhập']) =>
    (value) => (value == null || value.trim().isEmpty) ? message : null;

Validator minLength(int n) =>
    (value) => (value ?? '').trim().length < n ? 'Tối thiểu $n ký tự' : null;

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
