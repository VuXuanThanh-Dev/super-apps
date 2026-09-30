import 'package:flutter/material.dart';

import 'app.dart';
import 'core/logging/app_logger.dart';
import 'core/logging/error_handlers.dart';
import 'core/platform/battery_channel.dart';
import 'core/security/secure_store.dart';
import 'features/auth/data/pin_repository.dart';
import 'features/notes/data/note_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // sink: nơi gửi lỗi ra ngoài. Muốn dùng Sentry: sink: (r) => Sentry.captureException(r.error, stackTrace: r.stackTrace)
  final logger = AppLogger();
  installErrorHandlers(logger);
  final store = FlutterSecureStore();
  runApp(
    SecureNotesApp(
      dependencies: AppDependencies(
        pins: PinRepository(store),
        notes: SecureNoteRepository(store),
        logger: logger,
        battery: const BatteryChannel(),
      ),
    ),
  );
}
