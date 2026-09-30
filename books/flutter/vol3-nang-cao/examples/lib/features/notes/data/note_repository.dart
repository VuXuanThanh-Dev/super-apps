import 'dart:convert';

import '../../../core/security/secure_store.dart';
import '../domain/note.dart';

abstract interface class NoteRepository {
  Future<List<Note>> list();
  Future<Note?> get(String id);

  /// Thêm mới (id chưa có) hoặc cập nhật.
  Future<void> save(Note note);
  Future<void> delete(String id);
}

/// Lưu ghi chú (dạng JSON) trong SecureStore → được mã hóa bởi Keychain/Keystore.
/// Phù hợp với ÍT dữ liệu (vài chục ghi chú). Dữ liệu lớn: SQLite mã hóa (SQLCipher) — xem "Ideas for later".
class SecureNoteRepository implements NoteRepository {
  SecureNoteRepository(this._store);

  final SecureStore _store;
  static const _key = 'notes_v1';

  Future<List<Note>> _readAll() async {
    final raw = await _store.read(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<Object?>;
    return decoded.whereType<Map<String, Object?>>().map(Note.fromJson).toList();
  }

  Future<void> _writeAll(List<Note> notes) => _store.write(_key, jsonEncode([for (final n in notes) n.toJson()]));

  @override
  Future<List<Note>> list() async => (await _readAll())..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  @override
  Future<Note?> get(String id) async => (await _readAll()).where((n) => n.id == id).firstOrNull;

  @override
  Future<void> save(Note note) async {
    final all = await _readAll();
    final i = all.indexWhere((n) => n.id == note.id);
    i == -1 ? all.add(note) : all[i] = note;
    await _writeAll(all);
  }

  @override
  Future<void> delete(String id) async {
    final all = await _readAll()
      ..removeWhere((n) => n.id == id);
    await _writeAll(all);
  }
}
