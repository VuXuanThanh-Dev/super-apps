import 'package:flutter/foundation.dart';

import '../../chapters/ch03/dart_basics.dart' show VietnameseText;

/// Mức ưu tiên của một việc.
enum Priority {
  low('Thấp'),
  normal('Bình thường'),
  high('Cao');

  const Priority(this.label);
  final String label;
}

/// Bộ lọc danh sách.
enum TaskFilter {
  all('Tất cả'),
  active('Chưa xong'),
  done('Đã xong');

  const TaskFilter(this.label);
  final String label;
}

/// Model bất biến (immutable): muốn đổi thì tạo bản mới bằng [copyWith].
@immutable
class Task {
  const Task({
    required this.id,
    required this.title,
    this.note = '',
    this.priority = Priority.normal,
    this.done = false,
  });

  final String id;
  final String title;
  final String note;
  final Priority priority;
  final bool done;

  Task copyWith({String? title, String? note, Priority? priority, bool? done}) {
    return Task(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      priority: priority ?? this.priority,
      done: done ?? this.done,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Task &&
      other.id == id &&
      other.title == title &&
      other.note == note &&
      other.priority == priority &&
      other.done == done;

  @override
  int get hashCode => Object.hash(id, title, note, priority, done);

  @override
  String toString() => 'Task($id, $title, ${priority.name}, done: $done)';
}

/// Sắp xếp: việc chưa xong trước; cùng trạng thái thì ưu tiên cao trước; rồi theo tên.
List<Task> sortTasks(Iterable<Task> tasks) {
  final list = tasks.toList();
  list.sort((a, b) {
    if (a.done != b.done) return a.done ? 1 : -1;
    final byPriority = b.priority.index.compareTo(a.priority.index);
    if (byPriority != 0) return byPriority;
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  });
  return list;
}

/// Lọc theo [filter] (hàm thuần — dễ test, giống một `pipe` thuần trong Angular).
List<Task> filterTasks(Iterable<Task> tasks, TaskFilter filter) => switch (filter) {
  TaskFilter.all => tasks.toList(),
  TaskFilter.active => tasks.where((t) => !t.done).toList(),
  TaskFilter.done => tasks.where((t) => t.done).toList(),
};

/// Validator cho tiêu đề. Trả về `null` nghĩa là hợp lệ (quy ước của Flutter Form).
String? validateTaskTitle(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Hãy nhập tên việc';
  if (text.length > 80) return 'Tối đa 80 ký tự';
  return null;
}

/// Bài tập 2 (Chương 9): tìm theo tên hoặc ghi chú, không phân biệt hoa thường và có/không dấu.
List<Task> searchTasks(Iterable<Task> tasks, String query) {
  final q = query.trim().withoutAccents;
  if (q.isEmpty) return tasks.toList();
  return tasks.where((t) => t.title.withoutAccents.contains(q) || t.note.withoutAccents.contains(q)).toList();
}
