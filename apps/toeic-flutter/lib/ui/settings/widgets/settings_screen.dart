import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/dataset_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../view_models/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final data = context.read<DatasetRepository>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings · Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Theme · Giao diện', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto),
                tooltip: 'theme-system',
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
                tooltip: 'theme-light',
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
                tooltip: 'theme-dark',
              ),
            ],
            selected: {vm.themeMode},
            onSelectionChanged: (s) => vm.setThemeMode(s.first),
          ),
          const SizedBox(height: 4),
          Text('Current: ${vm.themeMode.name}', key: const Key('theme-current')),
          const SizedBox(height: 24),
          Text('Speech rate · Tốc độ đọc', style: theme.textTheme.titleMedium),
          Slider(
            key: const Key('speech-rate'),
            value: vm.speechRate,
            min: 0.2,
            max: 1.0,
            divisions: 8,
            label: vm.speechRate.toStringAsFixed(1),
            onChanged: vm.setSpeechRate,
          ),
          const SizedBox(height: 24),
          Text('Data · Dữ liệu', style: theme.textTheme.titleMedium),
          Text(
            data.isSample
                ? 'Sample dataset (public). Build the full dataset with tools/build_data.sh.'
                : 'Full private dataset (from the books, private-data/).',
            key: const Key('data-source'),
          ),
          Text(
            '${data.index.words.length} words · ${data.index.dataset.families.length} families · '
            '${data.index.dataset.collocations.length} collocations · ${data.index.passages.length} passages · '
            '${data.roleplays.length} dialogs',
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            key: const Key('reset-progress'),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset progress · Xoá tiến độ'),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Reset progress?'),
                  content: const Text('Saved words, cards and stats will be deleted. · Xoá hết tiến độ?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reset')),
                  ],
                ),
              );
              if (ok == true && context.mounted) await context.read<UserRepository>().reset();
            },
          ),
          const SizedBox(height: 24),
          Text('Credits', style: theme.textTheme.titleMedium),
          const Text(
            'Definitions, examples, passages and dialogs: written for the React Native app (apps/toeic). '
            'Fallback glosses and irregular forms: WordNet 3.0. IPA: book + CMUdict. Font: Noto Sans (SIL OFL 1.1).',
          ),
        ],
      ),
    );
  }
}
