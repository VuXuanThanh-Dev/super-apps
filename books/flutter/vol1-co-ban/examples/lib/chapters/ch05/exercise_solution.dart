import 'package:flutter/material.dart';

import '../../features/tasks/task.dart';

/// Bài 1: màu theo mức ưu tiên, lấy từ ColorScheme (đúng cả sáng lẫn tối).
Color colorForPriority(ColorScheme scheme, Priority p) => switch (p) {
  Priority.high => scheme.error,
  Priority.normal => scheme.primary,
  Priority.low => scheme.outline,
};

/// Bài 2: dòng có chữ rất dài KHÔNG bị tràn (overflow): bọc Text trong Expanded.
class LongTitleRow extends StatelessWidget {
  const LongTitleRow({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.label_outline),
        const SizedBox(width: 8),
        Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
        const Icon(Icons.chevron_right),
      ],
    );
  }
}
