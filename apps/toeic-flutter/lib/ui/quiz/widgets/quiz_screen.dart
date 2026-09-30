import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/quiz/quiz_generator.dart';
import '../../../routing/router.dart';
import '../../lookup/widgets/tappable_text.dart';
import '../view_models/quiz_view_model.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuizViewModel>();
    final theme = Theme.of(context);
    final Widget body;
    if (vm.load.running) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.empty) {
      body = const Center(child: Text('Not enough words for this quiz · Không đủ từ để tạo quiz'));
    } else if (vm.done) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Text(
              'Score: ${vm.score} / ${vm.questions.length}',
              key: const Key('quiz-score'),
              style: theme.textTheme.headlineSmall,
            ),
            FilledButton(onPressed: () => context.go(Routes.practice), child: const Text('Back to Practice')),
          ],
        ),
      );
    } else {
      final q = vm.current!;
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Question ${vm.index + 1} / ${vm.questions.length} · Score ${vm.score}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          switch (q) {
            ChoiceQuestion() => _ChoiceView(q: q, vm: vm),
            MatchQuestion() => _MatchView(q: q, vm: vm),
          },
          const SizedBox(height: 16),
          if (vm.checked)
            FilledButton(key: const Key('quiz-next'), onPressed: vm.next, child: const Text('Next · Tiếp')),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(vm.title)),
      body: body,
    );
  }
}

class _ChoiceView extends StatelessWidget {
  const _ChoiceView({required this.q, required this.vm});

  final ChoiceQuestion q;
  final QuizViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSentence = q.type == QuizType.blank || q.type == QuizType.family;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(q.type.vi, style: theme.textTheme.labelLarge),
        if (q.type == QuizType.listening)
          Row(
            children: [
              IconButton.filled(
                key: const Key('quiz-play'),
                tooltip: 'Play again',
                iconSize: 32,
                icon: const Icon(Icons.volume_up),
                onPressed: vm.speakCurrent,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(q.prompt)),
            ],
          )
        else if (isSentence)
          TappableText(q.prompt, key: const Key('quiz-prompt'), style: theme.textTheme.titleMedium)
        else
          Text(q.prompt, key: const Key('quiz-prompt'), style: theme.textTheme.headlineSmall),
        if (q.hint != null && q.hint!.isNotEmpty) Text(q.hint!, style: theme.textTheme.bodyMedium),
        for (var i = 0; i < q.options.length; i++)
          OutlinedButton(
            key: Key('quiz-option-$i'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(14),
              alignment: Alignment.centerLeft,
              backgroundColor: !vm.checked
                  ? null
                  : i == q.answer
                  ? Colors.green.withValues(alpha: 0.25)
                  : i == vm.chosen
                  ? theme.colorScheme.errorContainer
                  : null,
            ),
            onPressed: vm.checked ? null : () => vm.choose(i),
            child: Text(q.options[i], style: theme.textTheme.bodyLarge),
          ),
        if (vm.checked)
          Text(
            vm.chosen == q.answer ? 'Correct! · Đúng rồi' : 'Answer: ${q.options[q.answer]}',
            key: const Key('quiz-feedback'),
            style: theme.textTheme.titleSmall,
          ),
      ],
    );
  }
}

class _MatchView extends StatelessWidget {
  const _MatchView({required this.q, required this.vm});

  final MatchQuestion q;
  final QuizViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text('Tap a phrase, then its meaning · Chạm cụm từ rồi chạm nghĩa', style: theme.textTheme.labelLarge),
        for (var i = 0; i < q.left.length; i++)
          ListTile(
            key: Key('match-left-$i'),
            selected: vm.selectedLeft == i,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text(q.left[i]),
            subtitle: Text(
              vm.matches[i] == null ? '—' : q.right[vm.matches[i]!],
              style: TextStyle(
                color: !vm.checked
                    ? null
                    : vm.matches[i] == q.answer[i]
                    ? Colors.green
                    : theme.colorScheme.error,
              ),
            ),
            onTap: () => vm.selectLeft(i),
          ),
        const Divider(),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var j = 0; j < q.right.length; j++)
              ActionChip(key: Key('match-right-$j'), label: Text(q.right[j]), onPressed: () => vm.selectRight(j)),
          ],
        ),
        if (!vm.checked)
          FilledButton(
            key: const Key('match-check'),
            onPressed: vm.canCheckMatch ? vm.checkMatch : null,
            child: const Text('Check · Kiểm tra'),
          )
        else
          Text(
            q.isCorrect(vm.matches) ? 'All correct! · Đúng hết' : 'Some are wrong (red) · Có cặp sai (màu đỏ)',
            key: const Key('quiz-feedback'),
          ),
      ],
    );
  }
}
