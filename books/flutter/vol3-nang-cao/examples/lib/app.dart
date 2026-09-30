import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/logging/app_logger.dart';
import 'core/platform/battery_channel.dart';
import 'core/ui/theme.dart';
import 'features/auth/data/pin_repository.dart';
import 'features/auth/ui/auth_controller.dart';
import 'features/notes/data/note_repository.dart';
import 'router.dart';

/// Phụ thuộc của app (bản thật trong main.dart, bản giả trong test).
class AppDependencies {
  const AppDependencies({required this.pins, required this.notes, required this.logger, required this.battery});
  final PinRepository pins;
  final NoteRepository notes;
  final AppLogger logger;
  final BatteryChannel battery;
}

class SecureNotesApp extends StatelessWidget {
  const SecureNotesApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NoteRepository>.value(value: dependencies.notes),
        Provider<BatteryChannel>.value(value: dependencies.battery),
        ChangeNotifierProvider<AppLogger>.value(value: dependencies.logger),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(pins: dependencies.pins, logger: dependencies.logger)..init(),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final AuthController _auth = context.read<AuthController>();
  late final GoRouter _router = buildRouter(_auth);
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Theo dõi app vào nền / quay lại để tự khóa (Chương 4 — bảo mật).
    _lifecycle = AppLifecycleListener(onHide: _auth.onBackground, onShow: _auth.onResume);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sổ Ghi Chú Bảo Mật',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
