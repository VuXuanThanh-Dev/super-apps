import 'package:flutter/foundation.dart';

import 'task.dart';

/// Nơi giữ danh sách việc (trong bộ nhớ). Giống một service có state trong Angular.
///
/// [ChangeNotifier] có sẵn trong Flutter: gọi [notifyListeners] thì mọi widget đang
/// lắng nghe (ví dụ `ListenableBuilder`) sẽ build lại. Tập 2 nói kỹ hơn.
class TaskStore extends ChangeNotifier {
  TaskStore([Iterable<Task> initial = const []]) : _tasks = [...initial] {
    _nextId = _tasks.length + 1;
  }

  /// Dữ liệu mẫu để app không trống khi mở lần đầu.
  factory TaskStore.seeded() => TaskStore(const [
    Task(id: 't1', title: 'Học chương 1: cài Flutter', priority: Priority.high, done: true),
    Task(id: 't2', title: 'Đọc bảng Angular → Flutter', priority: Priority.high),
    Task(id: 't3', title: 'Viết widget đầu tiên', note: 'StatelessWidget + StatefulWidget'),
    Task(id: 't4', title: 'Thử dark mode', priority: Priority.low),
  ]);

  final List<Task> _tasks;
  late int _nextId;

  /// Bản chỉ-đọc: bên ngoài không sửa trực tiếp được.
  List<Task> get tasks => List.unmodifiable(_tasks);

  int get remaining => _tasks.where((t) => !t.done).length;

  Task? byId(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  Task add({required String title, String note = '', Priority priority = Priority.normal}) {
    final task = Task(id: 't${_nextId++}', title: title.trim(), note: note.trim(), priority: priority);
    _tasks.add(task);
    notifyListeners();
    return task;
  }

  void update(Task task) {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i == -1) return;
    _tasks[i] = task;
    notifyListeners();
  }

  void toggle(String id) {
    final task = byId(id);
    if (task != null) update(task.copyWith(done: !task.done));
  }

  /// Xóa và trả về (vị trí, việc) để có thể "Hoàn tác".
  (int, Task)? remove(String id) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return null;
    final removed = _tasks.removeAt(i);
    notifyListeners();
    return (i, removed);
  }

  /// Bài tập 1 (Chương 9): xóa mọi việc đã xong, trả về số việc đã xóa.
  int clearDone() {
    final before = _tasks.length;
    _tasks.removeWhere((t) => t.done);
    final removed = before - _tasks.length;
    if (removed > 0) notifyListeners();
    return removed;
  }

  void insertAt(int index, Task task) {
    _tasks.insert(index.clamp(0, _tasks.length), task);
    notifyListeners();
  }
}
