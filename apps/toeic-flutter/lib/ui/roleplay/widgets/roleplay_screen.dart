import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../lookup/widgets/tappable_text.dart';
import '../view_models/roleplay_view_model.dart';

class RoleplayScreen extends StatelessWidget {
  const RoleplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RoleplayViewModel>();
    final d = vm.roleplay;
    final theme = Theme.of(context);
    if (d == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(d.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TappableText(d.setting, style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          Text('Practice as · Tôi đóng vai:', style: theme.textTheme.labelLarge),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                key: const Key('role-none'),
                label: const Text('Just read'),
                selected: vm.myRole == null,
                onSelected: (_) => vm.setMyRole(null),
              ),
              for (final s in d.speakers)
                ChoiceChip(
                  key: Key('role-$s'),
                  label: Text(s),
                  selected: vm.myRole == s,
                  onSelected: (_) => vm.setMyRole(s),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < d.lines.length; i++)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: d.lines[i].speaker == vm.myRole ? theme.colorScheme.primaryContainer : null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.lines[i].speaker, style: theme.textTheme.labelLarge),
                          if (vm.isHidden(i))
                            TextButton(
                              key: Key('reveal-$i'),
                              onPressed: () => vm.reveal(i),
                              child: const Text('Your line — say it, then tap to check · Nói rồi chạm để xem'),
                            )
                          else
                            TappableText(d.lines[i].text, key: Key('line-$i')),
                        ],
                      ),
                    ),
                    if (!vm.isHidden(i))
                      IconButton(
                        tooltip: 'Speak line',
                        icon: const Icon(Icons.volume_up_outlined),
                        onPressed: () => vm.speak(d.lines[i].text),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
