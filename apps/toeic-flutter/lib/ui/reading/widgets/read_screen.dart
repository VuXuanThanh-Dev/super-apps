import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/dataset_repository.dart';
import '../../../routing/router.dart';

/// Tab Read: bài đọc (tính năng 4) và hội thoại nhập vai (tính năng 5).
class ReadScreen extends StatelessWidget {
  const ReadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.read<DatasetRepository>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Read · Đọc')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Reading passages · Bài đọc', style: theme.textTheme.titleMedium),
          ),
          for (final p in data.index.passages)
            ListTile(
              key: Key('passage-${p.id}'),
              leading: const Icon(Icons.article_outlined),
              title: Text(p.title),
              subtitle: Text(
                '${p.topic} · ${data.index.topicsByCode[p.topic]?.en ?? ''} · ${p.questions.length} questions',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(Routes.passage(p.id)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Roleplay dialogs · Hội thoại nhập vai', style: theme.textTheme.titleMedium),
          ),
          for (final d in data.roleplays)
            ListTile(
              key: Key('dialog-${d.id}'),
              leading: Icon(switch (d.category) {
                'meeting' => Icons.groups_outlined,
                'email' => Icons.email_outlined,
                'phone' => Icons.phone_outlined,
                _ => Icons.business_center_outlined,
              }),
              title: Text(d.title),
              subtitle: Text('${d.category} · ${d.lines.length} lines'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(Routes.roleplay(d.id)),
            ),
        ],
      ),
    );
  }
}
