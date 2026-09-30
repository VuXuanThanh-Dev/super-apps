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
            const SizedBox(height: 6),
            for (var oi = 0; oi < p.questions[qi].options.length; oi++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: OutlinedButton(
                  key: Key('q$qi-option-$oi'),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    backgroundColor: vm.answers[qi] == null
                        ? null
                        : oi == p.questions[qi].answer
                        ? Colors.green.withValues(alpha: 0.25)
                        : oi == vm.answers[qi]
                        ? theme.colorScheme.errorContainer
                        : null,
                  ),
                  onPressed: vm.answers[qi] == null ? () => vm.answer(qi, oi) : null,
                  child: Text(p.questions[qi].options[oi]),
                ),
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
