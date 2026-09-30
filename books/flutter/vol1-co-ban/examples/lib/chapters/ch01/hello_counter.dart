import 'package:flutter/material.dart';

/// Chương 1 — app đầu tiên: bộ đếm (phiên bản tiếng Việt của app mẫu `flutter create`).
class HelloCounter extends StatefulWidget {
  const HelloCounter({super.key, this.step = 1});

  final int step;

  @override
  State<HelloCounter> createState() => _HelloCounterState();
}

class _HelloCounterState extends State<HelloCounter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Xin chào Flutter!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text('Bạn đã bấm $_count lần'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => setState(() => _count += widget.step),
            icon: const Icon(Icons.add),
            label: const Text('Bấm tôi'),
          ),
        ],
      ),
    );
  }
}
