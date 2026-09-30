import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'features/auth/ui/auth_controller.dart';
import 'features/auth/ui/lock_screen.dart';
import 'features/notes/ui/note_editor_screen.dart';
import 'features/notes/ui/notes_list_screen.dart';
import 'features/notes/ui/notes_viewmodel.dart';
import 'features/settings/ui/settings_screen.dart';
import 'lab/lab_screens.dart';

/// Router có "guard": chưa mở khóa → luôn về /lock. `refreshListenable: auth` → khóa/mở khóa thì redirect chạy lại.
GoRouter buildRouter(AuthController auth, {String initialLocation = '/notes'}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: auth,
    redirect: (context, state) {
      final atLock = state.matchedLocation == '/lock';
      final unlocked = auth.status == AuthStatus.unlocked;
      if (!unlocked) return atLock ? null : '/lock';
      if (atLock) return '/notes';
      return null;
    },
    routes: [
      GoRoute(path: '/lock', builder: (context, state) => const LockScreen()),
      GoRoute(
        path: '/notes',
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => NotesViewModel(repository: context.read(), logger: context.read()),
          child: const NotesListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => NoteEditorViewModel(repository: context.read(), noteId: null),
              child: const NoteEditorScreen(),
            ),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) => NoteEditorViewModel(repository: context.read(), noteId: state.pathParameters['id']),
              child: const NoteEditorScreen(),
            ),
          ),
        ],
      ),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
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
  );
}
