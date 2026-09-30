import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/quiz/quiz_generator.dart';
import '../../../routing/router.dart';
import '../../lookup/widgets/tappable_text.dart';
import '../view_models/vocabulary_view_model.dart';
import 'vocabulary_screen.dart';

class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final vm = TopicViewModel(code: code, dataset: context.read());
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(vm.topic == null ? code : '${vm.topic!.code} · ${vm.topic!.en}')),
      body: ListView(
        children: [
          if (vm.topic != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${vm.topic!.vi} · ${vm.families.length} families · ${vm.wordCount} words'),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const Key('topic-flashcards'),
                  onPressed: () => context.go(Routes.flashcards(code)),
                  icon: const Icon(Icons.style),
                  label: const Text('Flashcards'),
                ),
                OutlinedButton.icon(
                  key: const Key('topic-quiz'),
                  onPressed: () => context.go(Routes.quiz(QuizType.meaning, code)),
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('Quiz'),
                ),
              ],
            ),
          ),
          for (final f in vm.families) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                '${f.family.headword}${f.family.band850 ? '  ★ 850+' : ''}',
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (f.family.tip != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: TappableText(f.family.tip!, style: theme.textTheme.bodyMedium),
              ),
            for (final w in f.words) WordTile(word: w),
          ],
        ],
      ),
    );
  }
}
