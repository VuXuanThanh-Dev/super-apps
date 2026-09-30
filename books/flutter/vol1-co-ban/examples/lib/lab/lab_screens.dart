import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../chapters/ch01/exercise_solution.dart';
import '../chapters/ch01/hello_counter.dart';
import '../chapters/ch02/cart_badge.dart';
import '../chapters/ch02/debounce.dart';
import '../chapters/ch02/greeting_service.dart';
import '../chapters/ch02/rating_stars.dart';
import '../chapters/ch03/dart_basics.dart';
import '../chapters/ch04/clock.dart';
import '../chapters/ch04/exercise_solution.dart';
import '../chapters/ch04/profile_card.dart';
import '../chapters/ch05/layout_demo.dart';
import '../chapters/ch06/exercise_solution.dart';
import '../chapters/ch06/lists_demo.dart';
import '../chapters/ch07/sign_up_form.dart';
import '../chapters/ch08/navigator_basics.dart';
import '../chapters/ch08/word_router_demo.dart';

/// Một mục trong tab Lab: mở ví dụ của một chương.
class LabChapter {
  const LabChapter(this.id, this.title, this.builder);
  final String id;
  final String title;
  final WidgetBuilder builder;
}

final List<LabChapter> labChapters = [
  LabChapter(
    'ch01',
    'Ch.1 — App đầu tiên',
    (_) => const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [HelloCounter(), SizedBox(height: 32), CounterWithReset()],
    ),
  ),
  LabChapter('ch02', 'Ch.2 — Angular/RN → Flutter', (_) => const _Ch02Demo()),
  LabChapter(
    'ch03',
    'Ch.3 — Dart',
    (_) => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(greet(null)),
        Text(describeScore(820)),
        Text(renderState(const Success(['negotiate', 'deadline']))),
        Text('Đàm phán'.withoutAccents),
        Text(const WordPair('invoice', 'hóa đơn').display),
      ],
    ),
  ),
  LabChapter(
    'ch04',
    'Ch.4 — Widget',
    (_) => const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [ProfileDemo(), SizedBox(height: 16), Clock(), LikeButton(initialLikes: 12)],
    ),
  ),
  LabChapter('ch05', 'Ch.5 — Layout & Theme', (_) => const LayoutDemo()),
  LabChapter(
    'ch06',
    'Ch.6 — Danh sách',
    (_) => SectionedWordList(
      groups: groupByInitial(const ['deadline', 'invoice', 'agenda', 'negotiate', 'budget', 'approve', 'delay']),
    ),
  ),
  LabChapter(
    'ch07',
    'Ch.7 — Form',
    (context) => SignUpForm(
      onSubmit: (data) =>
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chào ${data.name} (${data.email})'))),
    ),
  ),
  LabChapter(
    'ch08',
    'Ch.8 — Điều hướng',
    (context) => Column(
      children: [
        const Expanded(child: ColorPickerHome()),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Demo go_router')),
                  body: const WordRouterDemo(),
                ),
              ),
            ),
            child: const Text('Mở demo go_router (guard đăng nhập)'),
          ),
        ),
      ],
    ),
  ),
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

class _Ch02Demo extends StatefulWidget {
  const _Ch02Demo();

  @override
  State<_Ch02Demo> createState() => _Ch02DemoState();
}

class _Ch02DemoState extends State<_Ch02Demo> {
  int _rating = 3;
  String _lastSearch = '';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RatingStars(value: _rating, onChanged: (v) => setState(() => _rating = v)),
        Text('Đánh giá: $_rating sao'),
        const Divider(height: 32),
        const CartBadgeDemo(),
        const Divider(height: 32),
        const GreetingText(name: 'Nobin'),
        const GreetingScope(
          service: FormalGreeting(),
          child: GreetingText(name: 'Nobin'),
        ),
        const Divider(height: 32),
        SearchBox(onSearch: (s) => setState(() => _lastSearch = s)),
        Text('Tìm (sau 300ms): $_lastSearch'),
      ],
    );
  }
}
