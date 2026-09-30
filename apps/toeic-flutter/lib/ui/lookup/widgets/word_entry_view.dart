import 'package:flutter/material.dart';

import '../../../domain/lookup/dictionary.dart';
import '../../../domain/models/dataset.dart';
import '../../../domain/vocabulary/search.dart';
import 'tappable_text.dart';

/// Nội dung một kết quả tra từ: từ, IPA, nút đọc, nghĩa Việt, định nghĩa, ví dụ, họ từ, collocation.
/// Dùng chung cho popup và màn hình chi tiết từ. Mọi đoạn chữ đều là [TappableText].
class WordEntryView extends StatelessWidget {
  const WordEntryView({
    super.key,
    required this.result,
    required this.onSpeak,
    required this.onOpenWord,
    this.topic,
    this.saveButton,
  });

  final LookupResult result;
  final void Function(String text) onSpeak;
  final void Function(String word) onOpenWord;
  final Topic? topic;
  final Widget? saveButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final viStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.tertiary,
      fontWeight: FontWeight.w700,
    );
    final section = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      letterSpacing: 1,
      fontWeight: FontWeight.w700,
    );
    final r = result;
    final title = switch (r) {
      EntryResult(:final word) => word.word,
      FunctionWordResult(:final lemma) => lemma,
      GlossResult(:final lemma) => lemma,
      NotFoundResult(:final query) => query,
    };
    final (via, contraction) = switch (r) {
      EntryResult(:final via, :final contraction) => (via, contraction),
      FunctionWordResult(:final via, :final contraction) => (via, contraction),
      GlossResult(:final via, :final contraction) => (via, contraction),
      NotFoundResult() => (null, null),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(title, key: const Key('popup-word'), style: theme.textTheme.headlineMedium),
            ),
            if (r is! NotFoundResult)
              IconButton(
                key: const Key('popup-speak'),
                tooltip: 'Speak $title',
                icon: const Icon(Icons.volume_up),
                color: theme.colorScheme.primary,
                onPressed: () => onSpeak(title),
              ),
          ],
        ),
        if (via != null) Text(via, style: muted),
        if (contraction != null) Text(contraction, style: muted),
        ...switch (r) {
          EntryResult() => _entry(context, r, muted, viStyle, section),
          FunctionWordResult(:final info) => [
            Text('${info.pos} · common word', style: muted),
            Text(info.vi, style: viStyle),
            TappableText(info.definition),
          ],
          GlossResult(:final gloss) => [
            Text('${gloss.pos} · WordNet 3.0', style: muted),
            TappableText(gloss.definition),
            Text('Chưa có nghĩa tiếng Việt cho từ này.', style: muted),
          ],
          NotFoundResult() => [
            Text(
              'Not found in the offline dictionary. (Không tìm thấy từ này.)',
              key: const Key('popup-notfound'),
              style: muted,
            ),
          ],
        },
        ?saveButton,
      ],
    );
  }

  List<Widget> _entry(BuildContext context, EntryResult r, TextStyle? muted, TextStyle? viStyle, TextStyle? section) {
    final w = r.word;
    final theme = Theme.of(context);
    return [
      Text([w.pos, ?w.ipa].join('  '), style: muted),
      if (w.vi != null) Text(w.vi!, key: const Key('popup-vi'), style: viStyle),
      if (w.definition != null) TappableText(w.definition!),
      if (w.example != null)
        Container(
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: theme.colorScheme.outlineVariant, width: 3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TappableText(
                  w.example!,
                  style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
              IconButton(
                tooltip: 'Speak example',
                icon: const Icon(Icons.play_circle_outline),
                onPressed: () => onSpeak(w.example!),
              ),
            ],
          ),
        ),
      if (r.family.length > 1) ...[
        const SizedBox(height: 6),
        Text('WORD FAMILY · HỌ TỪ', style: section),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final m in r.family)
              ChoiceChip(
                label: Text('${m.word} (${m.pos})'),
                selected: m.id == w.id,
                onSelected: (_) => onOpenWord(m.word),
              ),
          ],
        ),
      ],
      if (r.collocations.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text('COLLOCATIONS', style: section),
        for (final c in r.collocations)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.phrase, style: theme.textTheme.titleSmall),
                Text(c.vi, style: TextStyle(color: theme.colorScheme.tertiary)),
                TappableText(c.example, style: muted),
              ],
            ),
          ),
      ],
      if (topic != null) Text('${bookLabel(topic!.book)} · ${topic!.code} ${topic!.en}', style: muted),
    ];
  }
}
