import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../lab/lab_screens.dart';
import '../ui/core/home_shell.dart';
import '../ui/review/review_screen.dart';
import '../ui/review/review_viewmodel.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/word_detail/word_detail_screen.dart';
import '../ui/word_detail/word_detail_viewmodel.dart';
import '../ui/word_list/word_list_screen.dart';
import '../ui/word_list/word_list_viewmodel.dart';

/// Router của app "Sổ Từ Vựng". Mỗi màn hình có ViewModel riêng, tạo bằng ChangeNotifierProvider:
/// `create` chạy MỘT lần cho mỗi màn hình và provider tự `dispose` ViewModel khi màn hình bị gỡ.
GoRouter buildRouter({String initialLocation = '/words'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/words',
                builder: (context, state) => ChangeNotifierProvider(
                  create: (context) => WordListViewModel(repository: context.read()),
                  child: const WordListScreen(),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
                      return ChangeNotifierProvider(
                        key: ValueKey(id),
                        create: (context) => WordDetailViewModel(
                          wordId: id,
                          repository: context.read(),
                          tts: context.read(),
                          dictionary: context.read(),
                        ),
                        child: const WordDetailScreen(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/review',
                builder: (context, state) => ChangeNotifierProvider(
                  create: (context) => ReviewViewModel(repository: context.read()),
                  child: const ReviewScreen(),
                ),
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
            routes: [GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen())],
          ),
        ],
      ),
    ],
  );
}
