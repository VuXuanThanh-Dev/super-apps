import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Không tìm thấy trang')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Không có trang: $location'),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => context.go('/tasks'), child: const Text('Về trang chính')),
          ],
        ),
      ),
    );
  }
}
