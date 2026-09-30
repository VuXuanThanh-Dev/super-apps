import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../routing/router.dart';
import '../../../utils/dates.dart';
import '../../core/ui/sample_banner.dart';
import '../../lookup/widgets/word_popup.dart';
import '../view_models/home_view_model.dart';

/// Màn hình Home = tính năng 7 (thống kê tiến độ).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final s = vm.summary;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TOEIC 900'),
        actions: [
          IconButton(
            key: const Key('open-settings'),
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(Routes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (vm.isSample) const SampleDataBanner(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${vm.totalWords} words · ${vm.totalTopics} units · ${vm.savedCount} saved',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              children: [
                _StatTile(label: 'Learned', vi: 'Đã thuộc', value: s.learned, icon: Icons.check_circle_outline),
                _StatTile(label: 'Due today', vi: 'Cần ôn', value: s.due, icon: Icons.schedule),
                _StatTile(label: 'Streak', vi: 'Chuỗi ngày', value: s.streak, icon: Icons.local_fire_department),
                _StatTile(label: 'Studied', vi: 'Đã học', value: s.studied, icon: Icons.style_outlined),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              '${s.totalReviews} reviews · ${s.totalQuizzes} quiz answers',
              key: const Key('home-totals'),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          _WeekChart(week: vm.week),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('Weak words · Từ hay sai', style: theme.textTheme.titleMedium),
          ),
          if (vm.weak.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('No weak words yet. Do a quiz! · Chưa có từ yếu.'),
            )
          else
            for (final w in vm.weak)
              ListTile(
                dense: true,
                title: Text(w.word),
                subtitle: Text('${w.wrong} wrong · ${(w.accuracy * 100).round()}% correct'),
                trailing: const Icon(Icons.search),
                onTap: () => showWordPopup(context, w.word),
              ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              key: const Key('home-start'),
              onPressed: () => context.go(Routes.flashcards('all')),
              icon: const Icon(Icons.play_arrow),
              label: Text(s.due > 0 ? 'Review ${s.due} due cards' : 'Start studying'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.vi, required this.value, required this.icon});

  final String label;
  final String vi;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$value', style: theme.textTheme.titleLarge),
                  Text('$label · $vi', style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Biểu đồ cột đơn giản cho 7 ngày gần nhất (không cần thư viện chart).
class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.week});

  final List<({int day, int count})> week;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = week.fold(1, (m, d) => d.count > m ? d.count : m);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 7 days · 7 ngày qua', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final d in week)
                  Expanded(
                    child: Semantics(
                      label: '${dayStringFromNumber(d.day)}: ${d.count}',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${d.count}', style: theme.textTheme.labelSmall),
                          Container(
                            height: 70 * d.count / max + 2,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(dayStringFromNumber(d.day).substring(8), style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
