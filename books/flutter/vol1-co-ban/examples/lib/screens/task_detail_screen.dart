import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/tasks/task_store.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.store, required this.id});

  final TaskStore store;
  final String id;

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa việc này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      store.remove(id);
      context.go('/tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final task = store.byId(id);
        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết')),
            body: const Center(child: Text('Không tìm thấy việc này')),
          );
        }
        final text = Theme.of(context).textTheme;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết'),
            actions: [
              IconButton(
                tooltip: 'Sửa',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.go('/tasks/$id/edit'),
              ),
              IconButton(
                tooltip: 'Xóa',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(task.title, style: text.headlineSmall),
              const SizedBox(height: 8),
              Text('Ưu tiên: ${task.priority.label}'),
              Text(task.done ? 'Trạng thái: Đã xong' : 'Trạng thái: Chưa xong'),
              if (task.note.isNotEmpty) ...[const Divider(height: 32), Text(task.note, style: text.bodyLarge)],
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: () => store.toggle(id),
                icon: Icon(task.done ? Icons.undo : Icons.check),
                label: Text(task.done ? 'Đánh dấu chưa xong' : 'Đánh dấu đã xong'),
              ),
            ],
          ),
        );
      },
    );
  }
}
