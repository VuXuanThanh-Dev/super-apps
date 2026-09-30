import 'package:flutter/material.dart';

import '../ch05/layout_demo.dart';

/// Bài 1: nhóm từ theo chữ cái đầu (viết hoa), mỗi nhóm sắp xếp A→Z, các nhóm cũng A→Z.
Map<String, List<String>> groupByInitial(Iterable<String> words) {
  final groups = <String, List<String>>{};
  for (final w in words.map((w) => w.trim()).where((w) => w.isNotEmpty)) {
    final key = w.characters.first.toUpperCase();
    groups.putIfAbsent(key, () => []).add(w);
  }
  final keys = groups.keys.toList()..sort();
  return {for (final k in keys) k: (groups[k]!..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())))};
}

/// Bài 2: lưới 20 ô màu, số cột theo bề rộng (dùng lại columnsForWidth của Chương 5).
class ColorGrid extends StatelessWidget {
  const ColorGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnsForWidth(constraints.maxWidth) + 1,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 20,
        itemBuilder: (context, i) => Container(
          color: Colors.primaries[i % Colors.primaries.length],
          alignment: Alignment.center,
          child: Text('Ô ${i + 1}', style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
