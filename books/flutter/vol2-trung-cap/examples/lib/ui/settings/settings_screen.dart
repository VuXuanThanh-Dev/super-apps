import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/settings_repository.dart';
import 'settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _themeLabels = {ThemeMode.system: 'Theo hệ thống', ThemeMode.light: 'Sáng', ThemeMode.dark: 'Tối'};

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final message = vm.message;
    if (message != null) {
      // Hiện SnackBar SAU frame hiện tại (không gọi trong lúc build).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        vm.consumeMessage();
      });
    }
    final reminder = vm.reminder;
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Giao diện', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [for (final e in _themeLabels.entries) ButtonSegment(value: e.key, label: Text(e.value))],
            selected: {vm.themeMode},
            onSelectionChanged: (s) => vm.setThemeMode(s.first),
          ),
          const Divider(height: 32),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Nhắc ôn hằng ngày'),
            subtitle: Text(
              !vm.remindersSupported
                  ? 'Không hỗ trợ trên web'
                  : reminder == null
                  ? 'Đang tắt'
                  : 'Lúc ${SettingsRepository.formatTime(reminder)}',
            ),
            value: reminder != null,
            onChanged: (on) async {
              if (!on) return vm.setReminder(null);
              final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 20, minute: 0));
              if (picked != null) await vm.setReminder(picked);
            },
          ),
          const Divider(height: 32),
          Text('Tốc độ đọc: ${vm.speechRate.toStringAsFixed(2)}'),
          Slider(
            value: vm.speechRate,
            min: 0.2,
            max: 1.0,
            divisions: 8,
            label: vm.speechRate.toStringAsFixed(2),
            onChanged: vm.setSpeechRate,
          ),
          const SizedBox(height: 24),
          const Text('Sách Flutter — Tập 2. Flutter 3.47.5 · Dart 3.13.4'),
        ],
      ),
    );
  }
}
