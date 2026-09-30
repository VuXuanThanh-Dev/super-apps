import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/tts_service.dart';

/// Nút phát âm dùng TtsService lấy từ provider — widget không biết đó là flutter_tts thật hay bản giả.
class SpeakButton extends StatefulWidget {
  const SpeakButton({super.key, required this.text});

  final String text;

  @override
  State<SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends State<SpeakButton> {
  bool _speaking = false;

  Future<void> _speak() async {
    setState(() => _speaking = true);
    try {
      await context.read<TtsService>().speak(widget.text);
    } finally {
      if (mounted) setState(() => _speaking = false);
    }
  }

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: _speaking ? null : _speak,
    icon: Icon(_speaking ? Icons.graphic_eq : Icons.volume_up),
    label: Text(_speaking ? 'Đang đọc…' : 'Đọc "${widget.text}"'),
  );
}
