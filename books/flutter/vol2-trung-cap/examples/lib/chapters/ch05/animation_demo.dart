import 'package:flutter/material.dart';

import '../../ui/core/flip_card.dart';

/// Animation ngầm (implicit): chỉ đổi giá trị đích, widget tự chạy animation từ giá trị cũ tới mới.
class AnimatedProgress extends StatelessWidget {
  const AnimatedProgress({super.key, required this.value});

  final double value; // 0..1

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, v, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: v, minHeight: 10, color: scheme.primary),
          Text('${(v * 100).round()}%'),
        ],
      ),
    );
  }
}

class AnimationDemo extends StatefulWidget {
  const AnimationDemo({super.key});

  @override
  State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo> {
  double _progress = 0.2;
  bool _big = false;
  bool _flipped = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AnimatedProgress(value: _progress),
        TextButton(
          onPressed: () => setState(() => _progress = _progress >= 1 ? 0.2 : _progress + 0.2),
          child: const Text('Tiến độ +20%'),
        ),
        const Divider(),
        // AnimatedContainer: đổi kích thước / màu / bo góc → tự animate.
        GestureDetector(
          onTap: () => setState(() => _big = !_big),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _big ? 140 : 70,
            decoration: BoxDecoration(
              color: _big ? scheme.tertiaryContainer : scheme.primaryContainer,
              borderRadius: BorderRadius.circular(_big ? 32 : 8),
            ),
            alignment: Alignment.center,
            child: const Text('Chạm để đổi'),
          ),
        ),
        const Divider(),
        // Animation tường minh (explicit): FlipCard dùng AnimationController.
        GestureDetector(
          onTap: () => setState(() => _flipped = !_flipped),
          child: SizedBox(
            height: 140,
            child: FlipCard(
              flipped: _flipped,
              front: const Card(child: Center(child: Text('negotiate'))),
              back: const Card(child: Center(child: Text('đàm phán'))),
            ),
          ),
        ),
      ],
    );
  }
}
