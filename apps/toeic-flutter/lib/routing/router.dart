import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../domain/quiz/quiz_generator.dart';
import '../domain/vocabulary/search.dart';
import '../ui/core/ui/home_shell.dart';
import '../ui/flashcards/view_models/flashcards_view_model.dart';
import '../ui/flashcards/widgets/flashcards_screen.dart';
import '../ui/home/view_models/home_view_model.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/practice/widgets/practice_screen.dart';
import '../ui/quiz/view_models/quiz_view_model.dart';
import '../ui/quiz/widgets/quiz_screen.dart';
import '../ui/reading/view_models/passage_view_model.dart';
import '../ui/reading/widgets/passage_screen.dart';
import '../ui/reading/widgets/read_screen.dart';
import '../ui/roleplay/view_models/roleplay_view_model.dart';
import '../ui/roleplay/widgets/roleplay_screen.dart';
import '../ui/saved/view_models/saved_view_model.dart';
import '../ui/saved/widgets/saved_screen.dart';
import '../ui/settings/widgets/settings_screen.dart';
import '../ui/vocabulary/view_models/vocabulary_view_model.dart';
import '../ui/vocabulary/widgets/topic_screen.dart';
import '../ui/vocabulary/widgets/vocabulary_screen.dart';
import '../ui/vocabulary/widgets/word_screen.dart';

/// Đường dẫn của app (một chỗ duy nhất, giống `routes.dart` trong ví dụ Compass của docs).
abstract final class Routes {
  static const home = '/home';
  static const settings = '/home/settings';
  static const words = '/words';
  static String topic(String code) => '/words/topic/$code';
  static String word(String id) => '/words/word/$id';
  static const practice = '/practice';
  static String flashcards(String scope) => '/practice/flashcards?scope=$scope';
  static String quiz(QuizType type, String scope) => '/practice/quiz?type=${type.name}&scope=$scope';
  static const read = '/read';
  static String passage(String id) => '/read/passage/$id';
  static String roleplay(String id) => '/read/dialog/$id';
  static const saved = '/saved';
}

/// go_router: docs chính thức gọi đây là cách nên dùng cho "90% app Flutter" (ui/navigation).
/// ViewModel của mỗi màn hình tạo bằng ChangeNotifierProvider → tự `dispose` khi rời màn hình.
GoRouter buildRouter({String initialLocation = Routes.home}) {
  StudyScope scopeOf(GoRouterState s) => StudyScope.parse(s.uri.queryParameters['scope'] ?? 'all');
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => ChangeNotifierProvider(
                  create: (context) =>
                      HomeViewModel(dataset: context.read(), user: context.read(), clock: context.read()),
                  child: const HomeScreen(),
                ),
                routes: [GoRoute(path: 'settings', builder: (context, state) => const SettingsScreen())],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.words,
                builder: (context, state) => ChangeNotifierProvider(
                  create: (context) => VocabularyViewModel(dataset: context.read()),
                  child: const VocabularyScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'topic/:code',
                    builder: (context, state) => TopicScreen(code: state.pathParameters['code']!),
                  ),
                  GoRoute(
                    path: 'word/:id',
                    builder: (context, state) => WordScreen(wordId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.practice,
                builder: (context, state) => const PracticeScreen(),
                routes: [
                  GoRoute(
                    path: 'flashcards',
                    builder: (context, state) => ChangeNotifierProvider(
                      key: ValueKey(state.uri.toString()),
                      create: (context) => FlashcardsViewModel(
                        scope: scopeOf(state),
                        dataset: context.read(),
                        user: context.read(),
                        tts: context.read(),
                        clock: context.read(),
                      ),
                      child: const FlashcardsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'quiz',
                    builder: (context, state) => ChangeNotifierProvider(
                      key: ValueKey(state.uri.toString()),
                      create: (context) => QuizViewModel(
                        type: QuizType.values.asNameMap()[state.uri.queryParameters['type']] ?? QuizType.meaning,
                        scope: scopeOf(state),
                        dataset: context.read(),
                        user: context.read(),
                        tts: context.read(),
                        clock: context.read(),
                      ),
                      child: const QuizScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.read,
                builder: (context, state) => const ReadScreen(),
                routes: [
                  GoRoute(
                    path: 'passage/:id',
                    builder: (context, state) => ChangeNotifierProvider(
                      key: ValueKey(state.pathParameters['id']),
                      create: (context) => PassageViewModel(
                        passageId: state.pathParameters['id']!,
                        dataset: context.read(),
                        user: context.read(),
                        clock: context.read(),
                      ),
                      child: const PassageScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'dialog/:id',
                    builder: (context, state) => ChangeNotifierProvider(
                      key: ValueKey(state.pathParameters['id']),
                      create: (context) => RoleplayViewModel(
                        roleplayId: state.pathParameters['id']!,
                        dataset: context.read(),
                        tts: context.read(),
                      ),
                      child: const RoleplayScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.saved,
                builder: (context, state) => ChangeNotifierProvider(
                  create: (context) => SavedViewModel(dataset: context.read(), user: context.read()),
                  child: const SavedScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
