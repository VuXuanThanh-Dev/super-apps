import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Thẻ lật (animation tường minh — explicit animation — với AnimationController).
/// [flipped] đổi → thẻ quay 180° quanh trục dọc, nửa đường thì đổi mặt.
class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.flipped,
    this.duration = const Duration(milliseconds: 400),
  });

  final Widget front;
  final Widget back;
  final bool flipped;
  final Duration duration;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  // SingleTickerProviderStateMixin cung cấp "vsync": animation chỉ chạy khi màn hình đang vẽ.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.flipped ? 1 : 0,
  );
  late final Animation<double> _angle = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flipped != widget.flipped) {
      widget.flipped ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _angle,
      builder: (context, _) {
        final angle = _angle.value * math.pi;
        final showBack = angle > math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // phối cảnh (perspective)
            ..rotateY(angle),
          child: showBack
              ? Transform(alignment: Alignment.center, transform: Matrix4.rotationY(math.pi), child: widget.back)
              : widget.front,
        );
      },
    );
  }
}
