import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../domain/lookup/tokenizer.dart';
import 'word_popup.dart';

typedef WordTapCallback = void Function(String word);

/// Đặt trong cây widget để đổi việc "chạm vào từ" (ví dụ: bên trong popup, chạm từ khác thì
/// mở trong cùng popup và có nút Back, thay vì mở popup mới).
class WordTapScope extends InheritedWidget {
  const WordTapScope({super.key, required this.onWordTap, required super.child});

  final WordTapCallback onWordTap;

  static WordTapCallback? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WordTapScope>()?.onWordTap;

  @override
  bool updateShouldNotify(WordTapScope oldWidget) => oldWidget.onWordTap != onWordTap;
}

/// Đoạn chữ mà MỌI từ đều chạm được để xem nghĩa (tính năng lõi).
///
/// Dùng `Text.rich` + `TextSpan` có `TapGestureRecognizer` cho từng từ, nên chữ vẫn xuống dòng tự nhiên.
/// Theo tài liệu API của `TextSpan.recognizer`: widget sở hữu recognizer phải tự `dispose` nó —
/// vì vậy đây là StatefulWidget.
class TappableText extends StatefulWidget {
  const TappableText(this.text, {super.key, this.style, this.highlight = const {}, this.textAlign});

  final String text;
  final TextStyle? style;

  /// Các từ (chữ thường) cần in đậm, ví dụ từ của unit trong bài đọc.
  final Set<String> highlight;
  final TextAlign? textAlign;

  @override
  State<TappableText> createState() => _TappableTextState();
}

class _TappableTextState extends State<TappableText> {
  List<Token> _tokens = const [];
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _buildTokens();
  }

  @override
  void didUpdateWidget(TappableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _buildTokens();
  }

  void _buildTokens() {
    _disposeRecognizers();
    _tokens = tokenize(widget.text);
    for (final t in _tokens) {
      if (t.isWord) _recognizers.add(TapGestureRecognizer()..onTap = () => _onTap(t.text));
    }
  }

  void _onTap(String word) {
    final handler = WordTapScope.maybeOf(context);
    if (handler != null) {
      handler(word);
    } else {
      showWordPopup(context, word);
    }
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightStyle = TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary);
    var r = 0;
    return Text.rich(
      TextSpan(
        children: [
          for (final t in _tokens)
            if (t.isWord)
              TextSpan(
                text: t.text,
                recognizer: _recognizers[r++],
                mouseCursor: SystemMouseCursors.click,
                style: widget.highlight.contains(t.text.toLowerCase()) ? highlightStyle : null,
              )
            else
              TextSpan(text: t.text),
        ],
      ),
      style: widget.style ?? theme.textTheme.bodyLarge?.copyWith(height: 1.5),
      textAlign: widget.textAlign,
    );
  }
}
