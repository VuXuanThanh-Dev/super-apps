import 'package:flutter/material.dart';

import 'validators.dart';

/// Bài 1: validator "nhập lại mật khẩu" — so sánh với giá trị của ô khác.
/// Nhận một hàm đọc giá trị (không nhận String cố định) vì mật khẩu thay đổi theo thời gian.
Validator matchesField(String Function() other, [String message = 'Mật khẩu không khớp']) =>
    (value) => value == other() ? null : message;

/// Bài 2: form đổi mật khẩu dùng validator trên.
class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
          const SizedBox(height: 12),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu'),
            validator: matchesField(() => _password.text),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) widget.onDone();
            },
            child: const Text('Đổi mật khẩu'),
          ),
        ],
      ),
    );
  }
}
