import 'dart:async';

import 'package:flutter/material.dart';

String twoDigits(int n) => n.toString().padLeft(2, '0');

String formatTime(DateTime t) => '${twoDigits(t.hour)}:${twoDigits(t.minute)}:${twoDigits(t.second)}';

/// StatefulWidget có vòng đời:
///   initState      ~ ngOnInit
///   didUpdateWidget ~ ngOnChanges
///   dispose        ~ ngOnDestroy
class Clock extends StatefulWidget {
  const Clock({super.key, this.paused = false, this.now = DateTime.now});

  final bool paused;

  /// Hàm lấy giờ hiện tại — truyền vào để test dễ (giống inject một ClockService).
  final DateTime Function() now;

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late DateTime _time = widget.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.paused) _start();
  }

  @override
  void didUpdateWidget(Clock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paused != widget.paused) {
      widget.paused ? _stop() : _start();
    }
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _time = widget.now()));
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stop(); // quên dòng này → Timer vẫn chạy sau khi widget bị gỡ (rò rỉ bộ nhớ)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(formatTime(_time), style: Theme.of(context).textTheme.displaySmall);
}
