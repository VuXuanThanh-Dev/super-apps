import 'package:flutter/material.dart';

import 'rebuild_demo.dart';

/// Bài 1: animation xoay mà phần con nặng KHÔNG build lại mỗi frame — truyền nó qua tham số `child`.
class SpinningLogo extends StatefulWidget {
  const SpinningLogo({super.key});

  @override
  State<SpinningLogo> createState() => _SpinningLogoState();
}

class _SpinningLogoState extends State<SpinningLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
    ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      // child được build MỘT lần, rồi truyền lại vào builder ở mọi frame.
      child: const BuildCounter(label: 'logo'),
      builder: (context, child) => Transform.rotate(angle: _controller.value * 6.283, child: child),
    );
  }
}
