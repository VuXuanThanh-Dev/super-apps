import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/dataset_repository.dart';
import '../../../domain/quiz/quiz_generator.dart';
import '../../../routing/router.dart';

/// Tab Practice: chọn phạm vi (tất cả / đã lưu / từ yếu / một unit) rồi học flashcard hoặc làm quiz.
/// Phạm vi đang chọn là trạng thái tạm thời (ephemeral state) của màn hình → giữ trong State.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  String _scope = 'all';

  @override
  Widget build(BuildContext context) {
    final topics = context.read<DatasetRepository>().index.topics;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Practice · Luyện tập')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            key: const Key('practice-scope'),
            initialValue: _scope,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Words to study · Phạm vi'),
            items: [
              const DropdownMenuItem(value: 'all', child: Text('All words · Tất cả')),
              const DropdownMenuItem(value: 'saved', child: Text('Saved words · Từ đã lưu')),
              const DropdownMenuItem(value: 'weak', child: Text('Weak words · Từ hay sai')),
              for (final t in topics)
                DropdownMenuItem(
                  value: t.code,
                  child: Text('${t.code} · ${t.en}', overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _scope = v ?? 'all'),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              key: const Key('start-flashcards'),
              leading: const Icon(Icons.style),
              title: const Text('Flashcards (SM-2)'),
              subtitle: const Text('Spaced repetition · Lặp lại ngắt quãng'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(Routes.flashcards(_scope)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Quizzes', style: theme.textTheme.titleMedium),
          for (final t in QuizType.values)
            ListTile(
              key: Key('quiz-${t.name}'),
              leading: Icon(switch (t) {
                QuizType.meaning => Icons.translate,
                QuizType.blank => Icons.edit_note,
                QuizType.family => Icons.account_tree_outlined,
                QuizType.collocation => Icons.link,
                QuizType.listening => Icons.headphones,
              }),
              title: Text(t.title),
              subtitle: Text(t.vi),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(Routes.quiz(t, _scope)),
            ),
        ],
      ),
    );
  }
}
