import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'config/router.dart';
import 'ui/core/theme.dart';
import 'ui/settings/settings_viewmodel.dart';

/// Gốc app: MultiProvider (DI) bọc MaterialApp.router.
class VocabApp extends StatelessWidget {
  const VocabApp({super.key, required this.dependencies, this.initialLocation = '/words'});

  final AppDependencies dependencies;
  final String initialLocation;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: dependencies.providers,
      child: _AppView(initialLocation: initialLocation),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView({required this.initialLocation});
  final String initialLocation;

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  // Tạo router MỘT lần (không tạo trong build).
  late final GoRouter _router = buildRouter(initialLocation: widget.initialLocation);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // select: chỉ build lại khi themeMode đổi (không phải mọi thay đổi của SettingsViewModel).
    final themeMode = context.select<SettingsViewModel, ThemeMode>((vm) => vm.themeMode);
    return MaterialApp.router(
      title: 'Sổ Từ Vựng',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
