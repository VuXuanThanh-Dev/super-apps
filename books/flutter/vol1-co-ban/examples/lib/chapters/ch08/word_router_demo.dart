import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'word_router.dart';

/// Chạy router của Chương 8 bên trong app (một MaterialApp.router lồng) để xem trong tab Lab.
class WordRouterDemo extends StatefulWidget {
  const WordRouterDemo({super.key});

  @override
  State<WordRouterDemo> createState() => _WordRouterDemoState();
}

class _WordRouterDemoState extends State<WordRouterDemo> {
  final ValueNotifier<bool> _loggedIn = ValueNotifier(false);
  late final GoRouter _router = buildWordRouter(loggedIn: _loggedIn);

  @override
  void dispose() {
    _router.dispose();
    _loggedIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(debugShowCheckedModeBanner: false, theme: Theme.of(context), routerConfig: _router);
  }
}
