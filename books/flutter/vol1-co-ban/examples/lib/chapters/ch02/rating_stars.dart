import 'package:flutter/material.dart';

/// `@Input() value` + `@Output() valueChange` trong Angular
/// = tham số constructor [value] + callback [onChanged] trong Flutter.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.value, required this.onChanged, this.max = 5});

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var n = 1; n <= max; n++)
          IconButton(
            tooltip: '$n sao',
            isSelected: n <= value,
            icon: const Icon(Icons.star_border),
            selectedIcon: const Icon(Icons.star, color: Colors.amber),
            onPressed: () => onChanged(n),
          ),
      ],
    );
  }
}
