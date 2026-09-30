import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_controller.dart';

/// Màn hình tạo PIN (lần đầu) hoặc mở khóa.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) => InputDecoration(labelText: label, counterText: '');

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final setup = auth.status == AuthStatus.needsSetup;
    return Scaffold(
      appBar: AppBar(title: const Text('Sổ Ghi Chú Bảo Mật')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(setup ? Icons.lock_open : Icons.lock, size: 64),
          const SizedBox(height: 16),
          Text(
            setup ? 'Tạo mã PIN' : 'Nhập mã PIN',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pin,
            decoration: _decoration(setup ? 'Mã PIN mới (4–8 số)' : 'Mã PIN'),
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 8,
            enableSuggestions: false,
            autocorrect: false,
          ),
          if (setup) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _confirm,
              decoration: _decoration('Nhập lại mã PIN'),
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 8,
            ),
          ],
          if (auth.message != null) ...[
            const SizedBox(height: 12),
            Text(auth.message!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: auth.busy
                ? null
                : () async {
                    final ctrl = context.read<AuthController>();
                    setup ? await ctrl.createPin(_pin.text, _confirm.text) : await ctrl.unlock(_pin.text);
                    _pin.clear();
                    _confirm.clear();
                  },
            child: Text(setup ? 'Lưu mã PIN' : 'Mở khóa'),
          ),
        ],
      ),
    );
  }
}
