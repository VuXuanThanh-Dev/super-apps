import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../lookup/widgets/tappable_text.dart';
import '../view_models/passage_view_model.dart';

class PassageScreen extends StatelessWidget {
  const PassageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PassageViewModel>();
    final p = vm.passage;
    final theme = Theme.of(context);
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(p.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (vm.topic != null) Text('${vm.topic!.code} · ${vm.topic!.en}', style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text('Tap any word to see its meaning · Chạm vào từ để xem nghĩa', style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          TappableText(p.text, key: const Key('passage-text'), highlight: vm.unitWords),
          const SizedBox(height: 24),
          for (var qi = 0; qi < p.questions.length; qi++) ...[
            TappableText('${qi + 1}. ${p.questions[qi].question}', style: theme.textTheme.titleSmall),
            Text('Tap A–D to answer · Chạm A–D để trả lời', style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            for (var oi = 0; oi < p.questions[qi].options.length; oi++)
              _OptionRow(
                key: Key('q$qi-option-$oi'),
                letter: String.fromCharCode(65 + oi),
                text: p.questions[qi].options[oi],
                state: vm.answers[qi] == null
                    ? null
                    : oi == p.questions[qi].answer
                    ? true
                    : oi == vm.answers[qi]
                    ? false
                    : null,
                onAnswer: vm.answers[qi] == null ? () => vm.answer(qi, oi) : null,
              ),
            const SizedBox(height: 12),
          ],
          if (vm.answers.every((a) => a != null))
            Text(
              'Score: ${vm.correctCount} / ${p.questions.length}',
              key: const Key('passage-score'),
              style: theme.textTheme.titleMedium,
            ),
        ],
      ),
    );
  }
}

/// Một đáp án: nút chữ cái (A/B/C/D) để trả lời + nội dung là [TappableText] (chạm từ để tra nghĩa).
class _OptionRow extends StatelessWidget {
  const _OptionRow({super.key, required this.letter, required this.text, required this.state, required this.onAnswer});

  final String letter;
  final String text;

  /// true = đáp án đúng, false = chọn sai, null = chưa chấm / không liên quan.
  final bool? state;
  final VoidCallback? onAnswer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (state) {
      true => Colors.green.withValues(alpha: 0.25),
      false => scheme.errorContainer,
      null => null,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton.outlined(
            tooltip: 'Answer $letter',
            onPressed: onAnswer,
            icon: Text(letter, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Expanded(child: TappableText(text)),
        ],
      ),
    );
  }
}
