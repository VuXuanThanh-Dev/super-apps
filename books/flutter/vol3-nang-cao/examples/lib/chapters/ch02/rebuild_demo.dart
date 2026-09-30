import 'package:flutter/material.dart';

/// Đếm số lần build để THẤY hiệu quả của `const` và của tham số `child`.
class BuildCounter extends StatelessWidget {
  const BuildCounter({super.key, required this.label});

  final String label;
  static final Map<String, int> counts = {};

  @override
  Widget build(BuildContext context) {
    counts.update(label, (n) => n + 1, ifAbsent: () => 1);
    return Text(label);
  }
}

class RebuildDemo extends StatefulWidget {
  const RebuildDemo({super.key});

  @override
  State<RebuildDemo> createState() => _RebuildDemoState();
}

class _RebuildDemoState extends State<RebuildDemo> {
  int _ticks = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Đã bấm $_ticks lần'),
        const BuildCounter(label: 'const'), // cùng một đối tượng mỗi lần → Flutter bỏ qua, không build lại
        // ignore: prefer_const_constructors
        BuildCounter(label: 'không const'), // đối tượng mới mỗi lần → build lại
        FilledButton(onPressed: () => setState(() => _ticks++), child: const Text('setState')),
      ],
    );
  }
}
