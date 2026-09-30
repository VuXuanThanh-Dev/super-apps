import 'package:flutter_test/flutter_test.dart';
import 'package:tap3_so_ghi_chu/core/logging/app_logger.dart';
import 'package:tap3_so_ghi_chu/core/result.dart';
import 'package:tap3_so_ghi_chu/core/security/secure_store.dart';
import 'package:tap3_so_ghi_chu/features/notes/data/note_repository.dart';
import 'package:tap3_so_ghi_chu/features/notes/domain/note.dart';
import 'package:tap3_so_ghi_chu/features/notes/ui/notes_viewmodel.dart';

void main() {
  final t0 = DateTime(2026, 9, 30, 8);

  test('SecureNoteRepository: lưu JSON trong SecureStore, sắp xếp mới nhất trước', () async {
    final store = MemorySecureStore();
    final repo = SecureNoteRepository(store);
    await repo.save(Note(id: 'a', title: 'Mật khẩu wifi', body: 'x', updatedAt: t0));
    await repo.save(Note(id: 'b', title: 'Họp', body: 'y', updatedAt: t0.add(const Duration(hours: 1))));
    await repo.save(
      Note(id: 'a', title: 'Mật khẩu wifi (mới)', body: 'z', updatedAt: t0.add(const Duration(hours: 2))),
    );
    expect((await repo.list()).map((n) => n.title), ['Mật khẩu wifi (mới)', 'Họp']);
    expect(store.data.keys, ['notes_v1']);
    await repo.delete('b');
    expect((await repo.list()).single.id, 'a');
    expect(await repo.get('khong-co'), isNull);
  });

  test('NoteEditorViewModel: từ chối ghi chú trống, lưu mới rồi sửa', () async {
    final repo = SecureNoteRepository(MemorySecureStore());
    final editor = NoteEditorViewModel(repository: repo, noteId: null, clock: () => t0, newId: () => 'n1');
    await editor.save.execute(('  ', ''));
    expect(editor.save.result, isA<Error<Note>>());
    await editor.save.execute(('Ý tưởng', 'Học Flutter mỗi ngày'));
    expect((await repo.get('n1'))!.body, 'Học Flutter mỗi ngày');

    final again = NoteEditorViewModel(repository: repo, noteId: 'n1', clock: () => t0.add(const Duration(days: 1)));
    await pumpEventQueue();
    expect(again.note!.title, 'Ý tưởng');
    await again.save.execute(('Ý tưởng 2', 'sửa'));
    expect((await repo.list()).single.title, 'Ý tưởng 2');
  });

  test('NotesViewModel: tải và xóa', () async {
    final repo = SecureNoteRepository(MemorySecureStore());
    await repo.save(Note(id: 'a', title: 'A', body: '', updatedAt: t0));
    final vm = NotesViewModel(repository: repo, logger: AppLogger());
    await pumpEventQueue();
    expect(vm.notes, hasLength(1));
    await vm.delete.execute('a');
    expect(vm.notes, isEmpty);
    expect(await repo.list(), isEmpty);
  });
}
