import 'package:flutter/material.dart';

/// Lời giải Bài tập Chương 1: thêm nút "Đặt lại", bị vô hiệu khi bộ đếm = 0.
class CounterWithReset extends StatefulWidget {
  const CounterWithReset({super.key});

  @override
  State<CounterWithReset> createState() => _CounterWithResetState();
}

class _CounterWithResetState extends State<CounterWithReset> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Đếm: $_count'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(onPressed: () => setState(() => _count++), child: const Text('+1')),
            const SizedBox(width: 8),
            // onPressed = null → nút tự vô hiệu (disabled). Không cần thuộc tính [disabled] riêng.
            OutlinedButton(
              onPressed: _count == 0 ? null : () => setState(() => _count = 0),
              child: const Text('Đặt lại'),
            ),
          ],
        ),
      ],
    );
  }
}
