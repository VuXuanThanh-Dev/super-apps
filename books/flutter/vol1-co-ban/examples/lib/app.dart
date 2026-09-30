import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/tasks/task_store.dart';
import 'router.dart';
import 'theme.dart';

/// Widget gốc: tạo store, router, và theme (sáng / tối / theo hệ thống).
class TodoApp extends StatefulWidget {
  const TodoApp({super.key, this.store, this.initialLocation = '/tasks'});

  /// Cho phép test truyền store riêng (giống `TestBed.overrideProvider`).
  final TaskStore? store;
  final String initialLocation;

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  late final TaskStore _store = widget.store ?? TaskStore.seeded();
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.system);
  late final GoRouter _router = buildRouter(
    store: _store,
    themeMode: _themeMode,
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    _themeMode.dispose();
    if (widget.store == null) _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) => MaterialApp.router(
        title: 'Việc Cần Làm',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        routerConfig: _router,
      ),
    );
  }
}
