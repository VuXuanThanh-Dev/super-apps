import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/dataset_repository.dart';
import '../../../domain/lookup/dictionary.dart';
import '../view_models/word_popup_view_model.dart';
import 'tappable_text.dart';
import 'word_entry_view.dart';

/// Mở popup tra từ (bottom sheet) cho [word]. Gọi từ bất kỳ [TappableText] nào.
Future<void> showWordPopup(BuildContext context, String word) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) => ChangeNotifierProvider(
      create: (_) =>
          WordPopupViewModel(initialWord: word, dataset: context.read(), user: context.read(), tts: context.read()),
      child: const WordPopup(),
    ),
  );
}

class WordPopup extends StatelessWidget {
  const WordPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WordPopupViewModel>();
    final result = vm.current;
    final topic = result is EntryResult
        ? context.read<DatasetRepository>().index.topicsByCode[result.word.topic]
        : null;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      child: WordTapScope(
        onWordTap: vm.open, // chạm từ trong popup → mở trong popup (có Back)
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  if (vm.canGoBack)
                    IconButton(
                      key: const Key('popup-back'),
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back),
                      onPressed: vm.back,
                    ),
                  const Spacer(),
                  IconButton(
                    key: const Key('popup-close'),
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                key: const Key('word-popup'),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: WordEntryView(
                  result: result,
                  topic: topic,
                  onSpeak: vm.speak,
                  onOpenWord: vm.open,
                  saveButton: vm.headword == null
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ListenableBuilder(
                            listenable: vm.toggleSave,
                            builder: (context, _) => SizedBox(
                              width: double.infinity,
                              child: vm.saved
                                  ? OutlinedButton.icon(
                                      key: const Key('popup-save'),
                                      onPressed: vm.toggleSave.running ? null : vm.toggleSave.execute,
                                      icon: const Icon(Icons.star),
                                      label: const Text('Saved (tap to remove)'),
                                    )
                                  : FilledButton.icon(
                                      key: const Key('popup-save'),
                                      onPressed: vm.toggleSave.running ? null : vm.toggleSave.execute,
                                      icon: const Icon(Icons.star_border),
                                      label: const Text('Save to my list'),
                                    ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
