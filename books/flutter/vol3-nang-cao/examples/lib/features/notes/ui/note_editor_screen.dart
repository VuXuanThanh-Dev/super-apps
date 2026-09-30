import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/result.dart';
import 'notes_viewmodel.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save(NoteEditorViewModel vm) async {
    await vm.save.execute((_title.text, _body.text));
    if (!mounted) return;
    switch (vm.save.result) {
      case Ok():
        context.pop();
      case Error(:final error):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không lưu được: $error')));
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NoteEditorViewModel>();
    final note = vm.note;
    if (!_filled && note != null) {
      _title.text = note.title;
      _body.text = note.body;
      _filled = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(vm.noteId == null ? 'Ghi chú mới' : 'Sửa ghi chú'),
        actions: [
          IconButton(
            tooltip: 'Lưu',
            icon: const Icon(Icons.check),
            onPressed: vm.save.running ? null : () => _save(vm),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _body,
                decoration: const InputDecoration(labelText: 'Nội dung', alignLabelWithHint: true),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
