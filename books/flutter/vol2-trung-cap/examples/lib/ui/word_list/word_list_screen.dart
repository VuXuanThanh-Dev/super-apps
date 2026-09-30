import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/services/tts_service.dart';
import '../core/debouncer.dart';
import '../core/error_view.dart';
import 'word_list_viewmodel.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final _debouncer = Debouncer(const Duration(milliseconds: 300));

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // watch: build lại khi ViewModel gọi notifyListeners(). read: chỉ lấy, không lắng nghe.
    final vm = context.watch<WordListViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Sổ Từ Vựng')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Tìm từ hoặc nghĩa (có/không dấu)',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (text) => _debouncer(() => context.read<WordListViewModel>().search(text)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                FilterChip(label: const Text('Yêu thích'), selected: vm.favoritesOnly, onSelected: vm.setFavoritesOnly),
                const Spacer(),
                Text('${vm.words.length} từ'),
              ],
            ),
          ),
          if (vm.loading) const LinearProgressIndicator(),
          Expanded(child: _buildList(context, vm)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, WordListViewModel vm) {
    if (vm.error != null) return ErrorView(message: 'Không đọc được dữ liệu', onRetry: vm.refresh);
    if (vm.words.isEmpty && !vm.loading) return const Center(child: Text('Không có từ nào'));
    return ListView.builder(
      itemCount: vm.words.length,
      itemBuilder: (context, i) {
        final word = vm.words[i];
        return ListTile(
          title: Hero(
            tag: 'word-${word.id}', // cùng tag với màn hình chi tiết → chữ "bay" sang (Hero animation)
            child: Material(type: MaterialType.transparency, child: Text(word.text)),
          ),
          subtitle: Text('(${word.partOfSpeech}) ${word.meaning}'),
          onTap: () => context.go('/words/${word.id}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Phát âm ${word.text}',
                icon: const Icon(Icons.volume_up_outlined),
                onPressed: () => context.read<TtsService>().speak(word.text),
              ),
              IconButton(
                tooltip: word.favorite ? 'Bỏ yêu thích ${word.text}' : 'Yêu thích ${word.text}',
                icon: Icon(word.favorite ? Icons.star : Icons.star_border),
                onPressed: () => vm.toggleFavorite(word.id),
              ),
            ],
          ),
        );
      },
    );
  }
}
