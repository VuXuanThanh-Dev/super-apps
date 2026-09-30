import 'package:flutter/material.dart';

/// Bài 1: chấm "đang nghe" nhấp nháy lặp lại — AnimationController.repeat + FadeTransition.
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key, this.active = true});

  final bool active;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    lowerBound: 0.3,
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      widget.active ? _controller.repeat(reverse: true) : _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // quên dòng này → "AnimationController.dispose() called?" / Ticker rò rỉ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _controller,
    child: Icon(Icons.circle, color: Theme.of(context).colorScheme.error, size: 16),
  );
}

/// Bài 2: điểm số đổi thì chữ cũ mờ đi, chữ mới hiện lên — AnimatedSwitcher + ValueKey.
class AnimatedScore extends StatelessWidget {
  const AnimatedScore({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 250),
    // Key khác nhau → AnimatedSwitcher biết đây là widget MỚI và chạy animation chuyển.
    child: Text('$score điểm', key: ValueKey(score), style: Theme.of(context).textTheme.headlineMedium),
  );
}
