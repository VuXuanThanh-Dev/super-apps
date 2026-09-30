import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../chapters/ch01/cart_model.dart';
import '../chapters/ch01/provider_demo.dart';
import '../chapters/ch02/async_demo.dart';
import '../chapters/ch05/animation_demo.dart';
import '../chapters/ch05/exercise_solution.dart';
import '../chapters/ch06/speak_button.dart';

class LabChapter {
  const LabChapter(this.id, this.title, this.builder);
  final String id;
  final String title;
  final WidgetBuilder builder;
}

final List<LabChapter> labChapters = [
  LabChapter('ch01', 'Ch.1 — State: ChangeNotifier + provider', (_) => const _Ch01Demo()),
  LabChapter('ch02', 'Ch.2 — Future, Stream', (_) => const Center(child: CountdownView(from: 10))),
  LabChapter('ch03', 'Ch.3 — HTTP + JSON (xem Chi tiết từ → Tra từ điển online)', (context) => const _GoToWord()),
  LabChapter('ch04', 'Ch.4 — SQLite (tab Từ vựng dùng SQLite thật)', (context) => const _GoToWord()),
  LabChapter('ch05', 'Ch.5 — Animation', (_) => const _Ch05Demo()),
  LabChapter('ch06', 'Ch.6 — Text-to-speech', (_) => const Center(child: SpeakButton(text: 'negotiate'))),
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
              onTap: () => context.go('/lab/${c.id}'),
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

class _Ch01Demo extends StatefulWidget {
  const _Ch01Demo();

  @override
  State<_Ch01Demo> createState() => _Ch01DemoState();
}

class _Ch01DemoState extends State<_Ch01Demo> {
  final _counter = CounterViewModel();

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      CounterView(viewModel: _counter),
      const Divider(),
      const ProviderCartDemo(),
    ],
  );
}

class _Ch05Demo extends StatefulWidget {
  const _Ch05Demo();

  @override
  State<_Ch05Demo> createState() => _Ch05DemoState();
}

class _Ch05DemoState extends State<_Ch05Demo> {
  int _score = 0;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Expanded(child: AnimationDemo()),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PulsingDot(),
          const SizedBox(width: 12),
          AnimatedScore(score: _score),
          IconButton(onPressed: () => setState(() => _score += 10), icon: const Icon(Icons.add)),
        ],
      ),
      const SizedBox(height: 24),
    ],
  );
}

class _GoToWord extends StatelessWidget {
  const _GoToWord();

  @override
  Widget build(BuildContext context) => Center(
    child: FilledButton(onPressed: () => context.go('/words/1'), child: const Text('Mở từ đầu tiên')),
  );
}
