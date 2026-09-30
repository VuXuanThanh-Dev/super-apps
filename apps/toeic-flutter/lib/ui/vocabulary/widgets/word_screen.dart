import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../lookup/view_models/word_popup_view_model.dart';
import '../../lookup/widgets/tappable_text.dart';
import '../../lookup/widgets/word_entry_view.dart';
import '../../lookup/widgets/word_popup.dart';
import '../view_models/vocabulary_view_model.dart';

/// Chi tiết một từ (trang riêng). Dùng lại ViewModel của popup (nghĩa, lưu, đọc to).
/// Chạm vào từ khác trong trang → mở popup.
class WordScreen extends StatelessWidget {
  const WordScreen({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context) {
    final info = WordViewModel(wordId: wordId, dataset: context.read());
    final word = info.word;
    return Scaffold(
      appBar: AppBar(title: Text(word?.word ?? 'Word')),
      body: word == null
          ? const Center(child: Text('Not found · Không tìm thấy'))
          : ChangeNotifierProvider(
              create: (context) => WordPopupViewModel(
                initialWord: word.word,
                dataset: context.read(),
                user: context.read(),
                tts: context.read(),
              ),
              child: Builder(
                builder: (context) {
                  final vm = context.watch<WordPopupViewModel>();
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WordEntryView(
                          result: info.result,
                          topic: info.topic,
                          onSpeak: vm.speak,
                          onOpenWord: (w) => showWordPopup(context, w),
                          saveButton: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: vm.saved
                                ? OutlinedButton.icon(
                                    key: const Key('word-save'),
                                    onPressed: vm.toggleSave.execute,
                                    icon: const Icon(Icons.star),
                                    label: const Text('Saved (tap to remove)'),
                                  )
                                : FilledButton.icon(
                                    key: const Key('word-save'),
                                    onPressed: vm.toggleSave.execute,
                                    icon: const Icon(Icons.star_border),
                                    label: const Text('Save to my list'),
                                  ),
                          ),
                        ),
                        if (info.tip != null) ...[
                          const SizedBox(height: 16),
                          Text('TIP', style: Theme.of(context).textTheme.labelMedium),
                          TappableText(info.tip!),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
