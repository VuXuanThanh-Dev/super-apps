import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/tasks/task.dart';
import '../features/tasks/task_store.dart';

/// Danh sách việc: lọc, đánh dấu xong, vuốt để xóa (có Hoàn tác), nút thêm.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, required this.store});

  final TaskStore store;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // State cục bộ (ephemeral state): chỉ màn hình này cần → setState là đủ.
  TaskFilter _filter = TaskFilter.all;

  void _delete(Task task) {
    final removed = widget.store.remove(task.id);
    if (removed == null) return;
    final (index, oldTask) = removed;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Đã xóa "${oldTask.title}"'),
          action: SnackBarAction(label: 'Hoàn tác', onPressed: () => widget.store.insertAt(index, oldTask)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Việc cần làm'),
        actions: [
          IconButton(
            tooltip: 'Xóa việc đã xong',
            icon: const Icon(Icons.cleaning_services_outlined),
            onPressed: () {
              final n = widget.store.clearDone();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Đã xóa $n việc đã xong')));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/tasks/new'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm việc'),
      ),
      // ListenableBuilder: build lại phần này mỗi khi store gọi notifyListeners().
      body: ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) {
          final visible = sortTasks(filterTasks(widget.store.tasks, _filter));
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SegmentedButton<TaskFilter>(
                  segments: [for (final f in TaskFilter.values) ButtonSegment(value: f, label: Text(f.label))],
                  selected: {_filter},
                  onSelectionChanged: (s) => setState(() => _filter = s.first),
                ),
              ),
              Text('Còn ${widget.store.remaining} việc chưa xong'),
              const SizedBox(height: 8),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('Chưa có việc nào'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: visible.length,
                        itemBuilder: (context, i) {
                          final task = visible[i];
                          return Dismissible(
                            key: ValueKey(task.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Theme.of(context).colorScheme.errorContainer,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: const Icon(Icons.delete_outline),
                            ),
                            onDismissed: (_) => _delete(task),
                            child: TaskTile(
                              task: task,
                              onToggle: () => widget.store.toggle(task.id),
                              onOpen: () => context.go('/tasks/${task.id}'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Một dòng trong danh sách. Widget "ngốc": chỉ nhận dữ liệu + callback.
class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onToggle, required this.onOpen});

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Checkbox(
        value: task.done,
        onChanged: (_) => onToggle(),
        semanticLabel: task.done ? 'Bỏ đánh dấu ${task.title}' : 'Đánh dấu xong ${task.title}',
      ),
      title: Text(
        task.title,
        style: task.done ? TextStyle(decoration: TextDecoration.lineThrough, color: scheme.outline) : null,
      ),
      subtitle: Text('Ưu tiên: ${task.priority.label}'),
      trailing: task.priority == Priority.high ? Icon(Icons.flag, color: scheme.error) : null,
      onTap: onOpen,
    );
  }
}
