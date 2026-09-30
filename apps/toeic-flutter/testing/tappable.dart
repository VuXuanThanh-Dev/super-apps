import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_flutter/domain/lookup/tokenizer.dart';

/// Mọi chữ trong cây widget đang được gắn "recognizer" (chạm được) — đọc từ các RichText.
Set<String> tappableWords(WidgetTester tester) {
  final out = <String>{};
  for (final rt in tester.widgetList<RichText>(find.byType(RichText))) {
    rt.text.visitChildren((span) {
      if (span is TextSpan && span.recognizer != null && span.text != null) out.add(span.text!);
      return true;
    });
  }
  return out;
}

/// Kiểm tra: MỌI từ (theo tokenizer) của [text] đều chạm được trên màn hình.
void expectAllWordsTappable(WidgetTester tester, String text) {
  final tappable = tappableWords(tester);
  for (final t in tokenize(text).where((t) => t.isWord)) {
    expect(tappable, contains(t.text), reason: '"${t.text}" in "$text" is not tappable');
  }
}
