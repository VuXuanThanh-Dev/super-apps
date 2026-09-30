import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const demoWords = {'1': 'negotiate', '2': 'deadline', '3': 'invoice'};

/// go_router (declarative): URL → màn hình. Có path parameter, query parameter và redirect (guard).
GoRouter buildWordRouter({required ValueNotifier<bool> loggedIn, String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: loggedIn, // loggedIn đổi → chạy lại redirect
    redirect: (context, state) {
      final goingToWords = state.matchedLocation.startsWith('/words');
      if (goingToWords && !loggedIn.value) {
        // giống CanActivateFn trả về UrlTree('/login')
        return Uri(path: '/login', queryParameters: {'from': state.uri.toString()}).toString();
      }
      return null; // null = cho đi tiếp
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WordHome()),
      GoRoute(
        path: '/words/:id',
        builder: (context, state) =>
            WordDetail(id: state.pathParameters['id']!, tab: state.uri.queryParameters['tab'] ?? 'meaning'),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(loggedIn: loggedIn, from: state.uri.queryParameters['from']),
      ),
    ],
  );
}

class WordHome extends StatelessWidget {
  const WordHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Từ vựng')),
      body: ListView(
        children: [
          for (final e in demoWords.entries)
            ListTile(
              title: Text(e.value),
              onTap: () => context.push('/words/${e.key}'),
              trailing: TextButton(
                onPressed: () => context.push('/words/${e.key}?tab=examples'),
                child: const Text('Ví dụ'),
              ),
            ),
        ],
      ),
    );
  }
}

class WordDetail extends StatelessWidget {
  const WordDetail({super.key, required this.id, required this.tab});

  final String id;
  final String tab;

  @override
  Widget build(BuildContext context) {
    final word = demoWords[id];
    return Scaffold(
      appBar: AppBar(title: Text(word ?? 'Không có từ này')),
      body: Center(child: Text(word == null ? 'id = $id không tồn tại' : 'Từ: $word · tab: $tab')),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.loggedIn, this.from});

  final ValueNotifier<bool> loggedIn;
  final String? from;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            loggedIn.value = true;
            context.go(from ?? '/');
          },
          child: const Text('Đăng nhập (giả)'),
        ),
      ),
    );
  }
}
