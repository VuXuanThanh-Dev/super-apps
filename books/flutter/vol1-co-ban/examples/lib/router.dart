import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/tasks/task_store.dart';
import 'lab/lab_screens.dart';
import 'screens/home_shell.dart';
import 'screens/not_found_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/task_form_screen.dart';
import 'screens/task_list_screen.dart';

/// Cấu hình go_router của app mẫu Tập 1.
///
/// - 3 tab (StatefulShellRoute.indexedStack): mỗi tab giữ lịch sử riêng.
/// - `/tasks/new` đứng TRƯỚC `/tasks/:id` để "new" không bị hiểu là một id.
GoRouter buildRouter({
  required TaskStore store,
  required ValueNotifier<ThemeMode> themeMode,
  String initialLocation = '/tasks',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    errorBuilder: (context, state) => NotFoundScreen(location: state.uri.toString()),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => TaskListScreen(store: store),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => TaskFormScreen(store: store),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => TaskDetailScreen(store: store, id: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => TaskFormScreen(store: store, editId: state.pathParameters['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lab',
                builder: (context, state) => const LabScreen(),
                routes: [
                  GoRoute(
                    path: ':chapter',
                    builder: (context, state) => LabDemoScreen(chapterId: state.pathParameters['chapter']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => SettingsScreen(themeMode: themeMode),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
