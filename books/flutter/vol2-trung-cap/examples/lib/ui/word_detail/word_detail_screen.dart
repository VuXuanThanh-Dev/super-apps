import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/result.dart';
import 'word_detail_viewmodel.dart';

class WordDetailScreen extends StatelessWidget {
  const WordDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WordDetailViewModel>();
    final word = vm.word;
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết từ')),
      body: ListenableBuilder(
        // Lắng nghe cả các Command để hiện trạng thái đang chạy / lỗi.
        listenable: Listenable.merge([vm.load, vm.lookup, vm.toggleFavorite]),
        builder: (context, _) {
          if (vm.load.running && word == null) return const Center(child: CircularProgressIndicator());
          if (vm.load.error || word == null) return const Center(child: Text('Không tìm thấy từ này'));
          final text = Theme.of(context).textTheme;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Hero(
                tag: 'word-${word.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(word.text, style: text.displaySmall),
                ),
              ),
              Text('(${word.partOfSpeech}) ${word.meaning}', style: text.titleMedium),
              if (word.example.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('“${word.example}”', style: text.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
              ],
              const SizedBox(height: 8),
              Text('Đã ôn ${word.reviewCount} lần, nhớ đúng ${word.correctCount} lần'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: vm.speak.execute,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Phát âm'),
                  ),
                  OutlinedButton.icon(
                    onPressed: vm.toggleFavorite.running ? null : vm.toggleFavorite.execute,
                    icon: Icon(word.favorite ? Icons.star : Icons.star_border),
                    label: Text(word.favorite ? 'Bỏ yêu thích' : 'Yêu thích'),
                  ),
                  OutlinedButton.icon(
                    onPressed: vm.lookup.running ? null : vm.lookup.execute,
                    icon: const Icon(Icons.travel_explore),
                    label: const Text('Tra từ điển online'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (vm.lookup.running) const LinearProgressIndicator(),
              switch (vm.lookup.result) {
                null => const SizedBox.shrink(),
                Ok(:final value) when value.isEmpty => const Text('Từ điển không có định nghĩa.'),
                Ok(:final value) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final d in value.take(3))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${d.partOfSpeech}: ${d.definition}'),
                        subtitle: d.example == null ? null : Text(d.example!),
                      ),
                  ],
                ),
                Error(:final error) => Text(
                  'Không tra được: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              },
            ],
          );
        },
      ),
    );
  }
}
