import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap1_viec_can_lam/app.dart';
import 'package:tap1_viec_can_lam/features/tasks/task_store.dart';

/// Test tích hợp toàn app (widget test): router + màn hình + store thật.
void main() {
  Future<TaskStore> pumpTodo(WidgetTester tester, {String location = '/tasks'}) async {
    final store = TaskStore.seeded();
    addTearDown(store.dispose);
    // UniqueKey: mỗi lần pump là một app mới (không dùng lại State cũ).
    await tester.pumpWidget(TodoApp(key: UniqueKey(), store: store, initialLocation: location));
    await tester.pumpAndSettle();
    return store;
  }

  testWidgets('mở app thấy danh sách + 3 tab', (tester) async {
    await pumpTodo(tester);
    expect(find.text('Đọc bảng Angular → Flutter'), findsOneWidget);
    expect(find.text('Còn 3 việc chưa xong'), findsOneWidget);
    expect(find.text('Lab'), findsOneWidget);
  });

  testWidgets('thêm việc: validate rồi lưu, quay về danh sách', (tester) async {
    final store = await pumpTodo(tester);
    await tester.tap(find.text('Thêm việc'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Hãy nhập tên việc'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Tên việc'), 'Mua sách TOEIC');
    await tester.tap(find.text('Cao'));
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Mua sách TOEIC'), findsOneWidget);
    expect(store.tasks.last.title, 'Mua sách TOEIC');
  });

  testWidgets('đánh dấu xong, lọc "Đã xong"', (tester) async {
    await pumpTodo(tester);
    await tester.tap(find.bySemanticsLabel('Đánh dấu xong Viết widget đầu tiên'));
    await tester.pump();
    expect(find.text('Còn 2 việc chưa xong'), findsOneWidget);
    await tester.tap(find.text('Đã xong'));
    await tester.pumpAndSettle();
    expect(find.text('Viết widget đầu tiên'), findsOneWidget);
    expect(find.text('Thử dark mode'), findsNothing);
  });

  testWidgets('chi tiết → sửa → lưu; xóa có hộp thoại xác nhận', (tester) async {
    final store = await pumpTodo(tester);
    await tester.tap(find.text('Thử dark mode'));
    await tester.pumpAndSettle();
    expect(find.text('Ưu tiên: Thấp'), findsOneWidget);
    await tester.tap(find.byTooltip('Sửa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Tên việc'), 'Thử dark mode trên iPhone');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Thử dark mode trên iPhone'), findsOneWidget); // quay lại trang chi tiết
    await tester.tap(find.byTooltip('Xóa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await tester.pumpAndSettle();
    expect(store.byId('t4'), isNull);
    expect(find.text('Còn 2 việc chưa xong'), findsOneWidget);
  });

  testWidgets('nút "Xóa việc đã xong" trên AppBar', (tester) async {
    final store = await pumpTodo(tester);
    await tester.tap(find.byTooltip('Xóa việc đã xong'));
    await tester.pump();
    expect(find.text('Đã xóa 1 việc đã xong'), findsOneWidget);
    expect(store.tasks.length, 3);
  });

  testWidgets('vuốt để xóa rồi Hoàn tác', (tester) async {
    final store = await pumpTodo(tester);
    await tester.drag(find.text('Thử dark mode'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(store.byId('t4'), isNull);
    await tester.tap(find.text('Hoàn tác'));
    await tester.pumpAndSettle();
    expect(store.byId('t4'), isNotNull);
  });

  testWidgets('deep link /tasks/t2 và /tasks/khong-co; route lạ → trang 404', (tester) async {
    await pumpTodo(tester, location: '/tasks/t2');
    expect(find.text('Chi tiết'), findsOneWidget);
    expect(find.text('Đọc bảng Angular → Flutter'), findsOneWidget);

    await pumpTodo(tester, location: '/tasks/khong-co');
    expect(find.text('Không tìm thấy việc này'), findsOneWidget);

    await pumpTodo(tester, location: '/abc');
    expect(find.text('Không có trang: /abc'), findsOneWidget);
    await tester.tap(find.text('Về trang chính'));
    await tester.pumpAndSettle();
    expect(find.text('Việc cần làm'), findsWidgets);
  });

  testWidgets('Cài đặt: chuyển sang giao diện Tối', (tester) async {
    await pumpTodo(tester);
    await tester.tap(find.text('Cài đặt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tối'));
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    // Tab giữ trạng thái: quay lại tab Việc cần làm vẫn thấy danh sách
    await tester.tap(find.text('Việc cần làm').last);
    await tester.pumpAndSettle();
    expect(find.text('Còn 3 việc chưa xong'), findsOneWidget);
  });

  testWidgets('Lab mở được mọi chương', (tester) async {
    await pumpTodo(tester, location: '/lab');
    for (final id in ['ch01', 'ch02', 'ch03', 'ch04', 'ch05', 'ch06', 'ch07', 'ch08']) {
      await pumpTodo(tester, location: '/lab/$id');
      expect(tester.takeException(), isNull, reason: id);
      expect(find.textContaining('Ch.${id.substring(3)}'), findsWidgets, reason: id);
    }
  });
}
