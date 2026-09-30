import 'package:flutter/material.dart';

/// Cài đặt: chọn giao diện Sáng / Tối / Theo hệ thống.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.themeMode});

  final ValueNotifier<ThemeMode> themeMode;

  static const labels = {ThemeMode.system: 'Theo hệ thống', ThemeMode.light: 'Sáng', ThemeMode.dark: 'Tối'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Giao diện', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeMode,
            builder: (context, mode, _) => SegmentedButton<ThemeMode>(
              segments: [for (final e in labels.entries) ButtonSegment(value: e.key, label: Text(e.value))],
              selected: {mode},
              onSelectionChanged: (s) => themeMode.value = s.first,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Sách Flutter — Tập 1. Flutter 3.47.5 · Dart 3.13.4 · go_router 18.0.2'),
        ],
      ),
    );
  }
}
