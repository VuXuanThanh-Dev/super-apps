import 'package:flutter/foundation.dart';

import '../../../core/command.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/result.dart';
import '../data/note_repository.dart';
import '../domain/note.dart';

class NotesViewModel extends ChangeNotifier {
  NotesViewModel({required this._repository, required this._logger}) {
    load = Command0(_load)..execute();
    delete = Command1(_delete);
  }

  final NoteRepository _repository;
  final AppLogger _logger;

  late final Command0<void> load;
  late final Command1<void, String> delete;

  List<Note> _notes = const [];
  List<Note> get notes => _notes;

  Future<Result<void>> _load() async {
    try {
      _notes = await _repository.list();
      return const Result.ok(null);
    } on Exception catch (e, st) {
      _logger.error('Không đọc được ghi chú', e, st);
      return Result.error(e);
    } finally {
      notifyListeners();
    }
  }

  Future<Result<void>> _delete(String id) async {
    try {
      await _repository.delete(id);
      _notes = _notes.where((n) => n.id != id).toList();
      return const Result.ok(null);
    } on Exception catch (e, st) {
      _logger.error('Không xóa được ghi chú', e, st);
      return Result.error(e);
    } finally {
      notifyListeners();
    }
  }
}

class NoteEditorViewModel extends ChangeNotifier {
  NoteEditorViewModel({
    required this._repository,
    required this.noteId,
    DateTime Function()? clock,
    String Function()? newId,
  }) : _clock = clock ?? DateTime.now,
       _newId = newId ?? (() => DateTime.now().microsecondsSinceEpoch.toRadixString(36)) {
    load = Command0(_load)..execute();
    save = Command1(_save);
  }

  final NoteRepository _repository;
  final String? noteId; // null = ghi chú mới
  final DateTime Function() _clock;
  final String Function() _newId;

  late final Command0<Note?> load;
  late final Command1<Note, (String, String)> save;

  Note? _note;
  Note? get note => _note;

  Future<Result<Note?>> _load() async {
    final id = noteId;
    if (id == null) return const Result.ok(null);
    _note = await _repository.get(id);
    notifyListeners();
    return Result.ok(_note);
  }

  Future<Result<Note>> _save((String, String) input) async {
    final (title, body) = input;
    if (title.trim().isEmpty && body.trim().isEmpty) {
      return Result.error(const FormatException('Ghi chú trống'));
    }
    final now = _clock();
    final note =
        _note?.copyWith(title: title.trim(), body: body, updatedAt: now) ??
        Note(id: _newId(), title: title.trim(), body: body, updatedAt: now);
    await _repository.save(note);
    _note = note;
    notifyListeners();
    return Result.ok(note);
  }
}
