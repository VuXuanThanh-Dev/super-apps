import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/ui/auth_controller.dart';
import 'notes_viewmodel.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotesViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú'),
        actions: [
          IconButton(tooltip: 'Lab', icon: const Icon(Icons.science_outlined), onPressed: () => context.push('/lab')),
          IconButton(
            tooltip: 'Cài đặt',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            tooltip: 'Khóa ngay',
            icon: const Icon(Icons.lock_outline),
            onPressed: context.read<AuthController>().lock,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/notes/new');
          await vm.load.execute(); // quay về thì tải lại
        },
        icon: const Icon(Icons.add),
        label: const Text('Ghi chú mới'),
      ),
      body: vm.notes.isEmpty
          ? Center(child: Text(vm.load.running ? 'Đang tải…' : 'Chưa có ghi chú nào'))
          : ListView.builder(
              itemCount: vm.notes.length,
              itemBuilder: (context, i) {
                final note = vm.notes[i];
                return Dismissible(
                  key: ValueKey(note.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => vm.delete.execute(note.id),
                  background: ColoredBox(color: Theme.of(context).colorScheme.errorContainer),
                  child: ListTile(
                    title: Text(note.title.isEmpty ? '(Không tiêu đề)' : note.title),
                    subtitle: Text(note.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () async {
                      await context.push('/notes/${note.id}');
                      await vm.load.execute();
                    },
                  ),
                );
              },
            ),
    );
  }
}
