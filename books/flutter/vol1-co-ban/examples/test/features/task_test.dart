import 'package:flutter_test/flutter_test.dart';
import 'package:tap1_viec_can_lam/features/tasks/task.dart';
import 'package:tap1_viec_can_lam/features/tasks/task_store.dart';

void main() {
  group('Task (model thuần)', () {
    const a = Task(id: '1', title: 'b việc', priority: Priority.low);
    const b = Task(id: '2', title: 'a việc', priority: Priority.high);
    const c = Task(id: '3', title: 'c việc', priority: Priority.high, done: true);

    test('copyWith tạo bản mới, bản cũ giữ nguyên', () {
      final done = a.copyWith(done: true);
      expect(done.done, isTrue);
      expect(a.done, isFalse);
      expect(done, isNot(a));
      expect(a.copyWith(), a); // == so sánh theo giá trị
    });

    test('sortTasks: chưa xong trước, ưu tiên cao trước', () {
      expect(sortTasks([c, a, b]).map((t) => t.id), ['2', '1', '3']);
    });

    test('filterTasks', () {
      expect(filterTasks([a, b, c], TaskFilter.done), [c]);
      expect(filterTasks([a, b, c], TaskFilter.active), [a, b]);
    });

    test('validateTaskTitle', () {
      expect(validateTaskTitle('   '), 'Hãy nhập tên việc');
      expect(validateTaskTitle('x' * 81), 'Tối đa 80 ký tự');
      expect(validateTaskTitle('Học Flutter'), isNull);
    });
  });

  test('Bài 2: searchTasks không phân biệt dấu', () {
    const t1 = Task(id: '1', title: 'Học từ vựng', note: 'Đàm phán hợp đồng');
    const t2 = Task(id: '2', title: 'Viết email');
    expect(searchTasks([t1, t2], 'hoc'), [t1]);
    expect(searchTasks([t1, t2], 'DAM PHAN'), [t1]);
    expect(searchTasks([t1, t2], '  '), [t1, t2]);
  });

  group('TaskStore (ChangeNotifier)', () {
    test('add / toggle / update / remove + insertAt báo cho listener', () {
      final store = TaskStore();
      var notified = 0;
      store.addListener(() => notified++);
      final t = store.add(title: '  Học Dart  ', priority: Priority.high);
      expect(t.title, 'Học Dart');
      expect(store.remaining, 1);
      store.toggle(t.id);
      expect(store.byId(t.id)!.done, isTrue);
      store.update(store.byId(t.id)!.copyWith(title: 'Học Dart 3'));
      final removed = store.remove(t.id);
      expect(store.tasks, isEmpty);
      store.insertAt(removed!.$1, removed.$2);
      expect(store.tasks.single.title, 'Học Dart 3');
      expect(notified, 5);
      expect(store.remove('không-có'), isNull);
    });

    test('Bài 1: clearDone xóa việc đã xong và báo listener một lần', () {
      final store = TaskStore.seeded();
      var notified = 0;
      store.addListener(() => notified++);
      expect(store.clearDone(), 1);
      expect(store.tasks.any((t) => t.done), isFalse);
      expect(store.clearDone(), 0);
      expect(notified, 1);
    });

    test('tasks là danh sách chỉ-đọc', () {
      final store = TaskStore.seeded();
      expect(() => store.tasks.add(const Task(id: 'x', title: 'x')), throwsUnsupportedError);
    });
  });
}
