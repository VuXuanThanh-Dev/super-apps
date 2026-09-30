import 'package:flutter/material.dart';

import 'validators.dart';

class SignUpData {
  const SignUpData({required this.name, required this.email});
  final String name;
  final String email;
}

/// Form + TextFormField + `GlobalKey<FormState>` ≈ FormGroup của Angular.
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key, required this.onSubmit});

  final ValueChanged<SignUpData> onSubmit;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

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
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            validator: compose([requiredField(), email()]),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 20),
          FilledButton(onPressed: _submit, child: const Text('Đăng ký')),
        ],
      ),
    );
  }
}
