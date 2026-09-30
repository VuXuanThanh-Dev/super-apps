import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/srs/sm2.dart';
import '../../../routing/router.dart';
import '../../lookup/widgets/tappable_text.dart';
import '../view_models/flashcards_view_model.dart';

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FlashcardsViewModel>();
    // Lắng nghe cả Command `load` (spinner) — giống mẫu ListenableBuilder + Command của docs.
    return ListenableBuilder(listenable: vm.load, builder: (context, _) => _build(context, vm));
  }

  Widget _build(BuildContext context, FlashcardsViewModel vm) {
    final theme = Theme.of(context);
    Widget body;
    if (vm.load.running && vm.queue.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.done) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration_outlined, size: 48),
              const SizedBox(height: 12),
              Text(
                vm.queue.isEmpty ? 'Nothing to review now · Không có thẻ nào cần ôn' : 'Done! ${vm.reviewed} reviews',
                key: const Key('flash-done'),
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: () => context.go(Routes.practice), child: const Text('Back to Practice')),
            ],
          ),
        ),
      );
    } else {
      final w = vm.current!;
      body = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Card ${vm.position + 1} / ${vm.queue.length}', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(w.word, key: const Key('flash-front'), style: theme.textTheme.headlineMedium),
                      ),
                      IconButton(
                        tooltip: 'Speak ${w.word}',
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => vm.speak(w.word),
                      ),
                    ],
                  ),
                  Text([w.pos, ?w.ipa].join('  '), style: theme.textTheme.bodyMedium),
                  if (vm.showAnswer) ...[
                    const Divider(),
                    if (w.vi != null)
                      Text(
                        w.vi!,
                        key: const Key('flash-back'),
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.tertiary),
                      ),
                    if (w.definition != null) TappableText(w.definition!),
                    if (w.example != null)
                      TappableText(w.example!, style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (!vm.showAnswer)
            FilledButton(
              key: const Key('flash-show'),
              onPressed: vm.reveal,
              child: const Text('Show answer · Xem nghĩa'),
            )
          else
            Row(
              spacing: 6,
              children: [
                for (final g in Grade.values)
                  Expanded(
                    child: FilledButton.tonal(
                      key: Key('grade-${g.name}'),
                      onPressed: vm.grade.running ? null : () => vm.grade.execute(g),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: Column(
                        children: [
                          Text(g.label),
                          Text('${vm.preview(g)}d', style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Flashcards · ${vm.title}')),
      body: body,
    );
  }
}
