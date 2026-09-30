import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/settings_repository.dart';
import '../../../routing/router.dart';
import '../../lookup/widgets/word_popup.dart';
import '../../settings/view_models/settings_view_model.dart';
import '../view_models/saved_view_model.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavedViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Saved · Từ đã lưu')),
      body: ListView(
        children: [
          const _ReminderTile(),
          const Divider(),
          if (vm.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FilledButton.icon(
                key: const Key('review-saved'),
                onPressed: () => context.go(Routes.flashcards('saved')),
                icon: const Icon(Icons.style),
                label: Text('Review ${vm.items.length} saved words'),
              ),
            ),
          if (vm.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No saved words yet. Tap any word, then "Save to my list". · '
                'Chưa có từ nào. Chạm vào một từ rồi bấm "Save to my list".',
                key: Key('saved-empty'),
              ),
            ),
          for (final item in vm.items)
            ListTile(
              key: Key('saved-${item.key}'),
              title: Text(item.word == null ? item.key : '${item.word!.word}  (${item.word!.pos})'),
              subtitle: Text(item.word?.vi ?? ''),
              onTap: () => showWordPopup(context, item.key),
              trailing: IconButton(
                tooltip: 'Remove ${item.key}',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => vm.remove.execute(item.key),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bật/tắt nhắc ôn hằng ngày (thông báo cục bộ) + chọn giờ.
class _ReminderTile extends StatelessWidget {
  const _ReminderTile();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final time = vm.reminder;
    final message = vm.message;
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        vm.consumeMessage();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      });
    }
    return SwitchListTile(
      key: const Key('reminder-switch'),
      secondary: const Icon(Icons.notifications_outlined),
      title: const Text('Daily reminder · Nhắc ôn hằng ngày'),
      subtitle: Text(
        !vm.remindersSupported
            ? 'Not available on web · Bản web không hỗ trợ'
            : time == null
            ? 'Off'
            : 'Every day at ${SettingsRepository.formatTime(time)}',
      ),
      value: time != null,
      onChanged: (on) async {
        if (!on) return vm.setReminder(null);
        final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 20, minute: 0));
        if (picked != null) await vm.setReminder(picked);
      },
    );
  }
}
