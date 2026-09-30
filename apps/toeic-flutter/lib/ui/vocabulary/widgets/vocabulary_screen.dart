import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/dataset.dart';
import '../../../domain/vocabulary/search.dart';
import '../../../routing/router.dart';
import '../../core/ui/sample_banner.dart';
import '../view_models/vocabulary_view_model.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VocabularyViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Words · Từ vựng')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              key: const Key('vocab-search'),
              decoration: const InputDecoration(
                labelText: 'Search English or Vietnamese · Tìm (có/không dấu)',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: vm.search,
            ),
          ),
          Expanded(child: vm.searching ? _results(context, vm.results) : _topics(context, vm)),
        ],
      ),
    );
  }

  Widget _results(BuildContext context, List<Word> results) {
    if (results.isEmpty) return const Center(child: Text('No words found · Không tìm thấy'));
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) => WordTile(word: results[i]),
    );
  }

  Widget _topics(BuildContext context, VocabularyViewModel vm) {
    final topics = vm.topics;
    return ListView.builder(
      itemCount: topics.length + (vm.isSample ? 1 : 0),
      itemBuilder: (context, i) {
        if (vm.isSample && i == 0) return const SampleDataBanner();
        final t = topics[i - (vm.isSample ? 1 : 0)];
        return ListTile(
          key: Key('topic-${t.topic.code}'),
          leading: CircleAvatar(child: Text(t.topic.code, style: const TextStyle(fontSize: 12))),
          title: Text(t.topic.en),
          subtitle: Text('${t.topic.vi} · ${bookLabel(t.topic.book)} · ${t.families} families · ${t.words} words'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go(Routes.topic(t.topic.code)),
        );
      },
    );
  }
}

/// Một dòng từ: từ, loại từ, nghĩa Việt → mở trang chi tiết.
class WordTile extends StatelessWidget {
  const WordTile({super.key, required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('word-${word.id}'),
      title: Text('${word.word}  (${word.pos})'),
      subtitle: Text(word.vi ?? word.definition ?? ''),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(Routes.word(word.id)),
    );
  }
}
