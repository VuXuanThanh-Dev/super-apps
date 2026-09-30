import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/tts_service.dart';
import '../core/flip_card.dart';
import 'review_viewmodel.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();
    final stats = vm.stats;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ôn tập')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (stats != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat(label: 'Tổng từ', value: stats.totalWords),
                    _Stat(label: 'Yêu thích', value: stats.favorites),
                    _Stat(label: 'Ôn hôm nay', value: stats.reviewedToday),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (vm.start.running && vm.total == 0) const Center(child: CircularProgressIndicator()),
          if (vm.finished) ...[
            Text('Bạn nhớ ${vm.correct}/${vm.total} từ', style: text.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: vm.start.execute, child: const Text('Ôn lượt mới')),
          ] else if (vm.current case final word?) ...[
            Text('Thẻ ${vm.position + 1}/${vm.total}', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: vm.reveal,
              child: SizedBox(
                height: 220,
                child: FlipCard(
                  flipped: vm.revealed,
                  front: _CardFace(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(word.text, style: text.displaySmall),
                        const SizedBox(height: 8),
                        const Text('Chạm để xem nghĩa'),
                      ],
                    ),
                  ),
                  back: _CardFace(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('(${word.partOfSpeech}) ${word.meaning}', style: text.titleLarge),
                        const SizedBox(height: 8),
                        Text(word.example, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Phát âm',
                  icon: const Icon(Icons.volume_up),
                  onPressed: () => context.read<TtsService>().speak(word.text),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: vm.revealed && !vm.answer.running ? () => vm.answer.execute(false) : null,
                  child: const Text('Chưa nhớ'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: vm.revealed && !vm.answer.running ? () => vm.answer.execute(true) : null,
                  child: const Text('Đã nhớ'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('$value', style: Theme.of(context).textTheme.headlineSmall),
      Text(label),
    ],
  );
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Center(child: child),
    ),
  );
}
