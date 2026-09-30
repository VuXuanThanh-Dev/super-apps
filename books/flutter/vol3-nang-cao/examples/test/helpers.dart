import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap3_so_ghi_chu/app.dart';
import 'package:tap3_so_ghi_chu/core/logging/app_logger.dart';
import 'package:tap3_so_ghi_chu/core/platform/battery_channel.dart';
import 'package:tap3_so_ghi_chu/core/security/secure_store.dart';
import 'package:tap3_so_ghi_chu/features/auth/data/pin_repository.dart';
import 'package:tap3_so_ghi_chu/features/notes/data/note_repository.dart';

Future<void> pumpApp(WidgetTester tester, Widget child) => tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

/// Bộ phụ thuộc cho test: SecureStore trong bộ nhớ, băm PIN ít vòng cho nhanh.
({AppDependencies deps, MemorySecureStore store, AppLogger logger}) testDependencies({DateTime Function()? clock}) {
  final store = MemorySecureStore();
  final logger = AppLogger();
  return (
    deps: AppDependencies(
      pins: PinRepository(store, iterations: 10, clock: clock),
      notes: SecureNoteRepository(store),
      logger: logger,
      battery: const BatteryChannel(),
    ),
    store: store,
    logger: logger,
  );
}
