import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../chapters/ch02/exercise_solution.dart';
import '../chapters/ch02/rebuild_demo.dart';
import '../chapters/ch04/security_utils.dart';
import '../core/platform/battery_channel.dart';

class LabChapter {
  const LabChapter(this.id, this.title, this.builder);
  final String id;
  final String title;
  final WidgetBuilder builder;
}

final List<LabChapter> labChapters = [
  LabChapter(
    'ch02',
    'Ch.2 — Performance: const và child',
    (_) => const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [RebuildDemo(), SizedBox(height: 24), SpinningLogo()]),
    ),
  ),
  LabChapter('ch03', 'Ch.3 — Platform channel (pin)', (_) => const _BatteryDemo()),
  LabChapter('ch04', 'Ch.4 — Kiểm tra deep link', (_) => const _DeepLinkDemo()),
];

class LabScreen extends StatelessWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab — ví dụ từng chương')),
      body: ListView(
        children: [
          for (final c in labChapters)
            ListTile(
              title: Text(c.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/lab/${c.id}'),
            ),
        ],
      ),
    );
  }
}

class LabDemoScreen extends StatelessWidget {
  const LabDemoScreen({super.key, required this.chapterId});

  final String chapterId;

  @override
  Widget build(BuildContext context) {
    final chapter = labChapters.where((c) => c.id == chapterId).firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(chapter?.title ?? 'Không có ví dụ')),
      body: chapter == null ? Center(child: Text('Không có chương "$chapterId"')) : chapter.builder(context),
    );
  }
}

class _BatteryDemo extends StatefulWidget {
  const _BatteryDemo();

  @override
  State<_BatteryDemo> createState() => _BatteryDemoState();
}

class _BatteryDemoState extends State<_BatteryDemo> {
  String _text = 'Bấm để đọc';

  Future<void> _read() async {
    final channel = context.read<BatteryChannel>();
    final level = await channel.batteryLevel();
    final low = await channel.lowPowerMode();
    if (!mounted) return;
    setState(() => _text = 'Pin: ${level == null ? 'không hỗ trợ' : '$level%'} · Tiết kiệm pin: ${low ?? 'không rõ'}');
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_text),
        const SizedBox(height: 12),
        FilledButton(onPressed: _read, child: const Text('Đọc qua MethodChannel')),
      ],
    ),
  );
}

class _DeepLinkDemo extends StatefulWidget {
  const _DeepLinkDemo();

  @override
  State<_DeepLinkDemo> createState() => _DeepLinkDemoState();
}

class _DeepLinkDemoState extends State<_DeepLinkDemo> {
  String _result = '';

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Deep link, ví dụ sochichu://notes/abc-1'),
          onChanged: (s) {
            final uri = Uri.tryParse(s);
            setState(() => _result = uri == null ? 'URL hỏng' : 'id = ${parseNoteDeepLink(uri) ?? '(từ chối)'}');
          },
        ),
        const SizedBox(height: 12),
        Text(_result),
      ],
    ),
  );
}
