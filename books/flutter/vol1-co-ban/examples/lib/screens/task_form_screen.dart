import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/tasks/task.dart';
import '../features/tasks/task_store.dart';

/// Form thêm / sửa việc. `editId == null` nghĩa là thêm mới.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, required this.store, this.editId});

  final TaskStore store;
  final String? editId;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Task? _editing = widget.editId == null ? null : widget.store.byId(widget.editId!);
  late final _title = TextEditingController(text: _editing?.title ?? '');
  late final _note = TextEditingController(text: _editing?.note ?? '');
  late Priority _priority = _editing?.priority ?? Priority.normal;

  @override
  void dispose() {
    // Controller giữ tài nguyên → phải dispose (giống unsubscribe trong ngOnDestroy).
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final editing = _editing;
    if (editing == null) {
      widget.store.add(title: _title.text, note: _note.text, priority: _priority);
    } else {
      widget.store.update(editing.copyWith(title: _title.text.trim(), note: _note.text.trim(), priority: _priority));
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editId != null;
    if (isEdit && _editing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sửa việc')),
        body: const Center(child: Text('Không tìm thấy việc này')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa việc' : 'Thêm việc')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              autofocus: !isEdit,
              decoration: const InputDecoration(labelText: 'Tên việc'),
              textInputAction: TextInputAction.next,
              validator: validateTaskTitle,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Ghi chú (không bắt buộc)'),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Text('Ưu tiên', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<Priority>(
              segments: [for (final p in Priority.values) ButtonSegment(value: p, label: Text(p.label))],
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Lưu')),
          ],
        ),
      ),
    );
  }
}
