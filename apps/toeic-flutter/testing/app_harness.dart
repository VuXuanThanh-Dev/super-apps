import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:toeic_flutter/app.dart';
import 'package:toeic_flutter/config/dependencies.dart';
import 'package:toeic_flutter/data/repositories/dataset_repository.dart';
import 'package:toeic_flutter/data/repositories/settings_repository.dart';
import 'package:toeic_flutter/data/services/key_value_store.dart';
import 'package:toeic_flutter/ui/core/themes/theme.dart';

import 'fakes/fakes.dart';

/// Ngày cố định cho test: 2026-09-28 10:00 (giờ địa phương).
DateTime fixedNow() => DateTime(2026, 9, 28, 10);

AppDependencies fakeDependencies(
  DatasetRepository dataset, {
  FakeUserRepository? user,
  FakeTts? tts,
  FakeReminderService? reminders,
}) => AppDependencies(
  dataset: dataset,
  user: user ?? FakeUserRepository(),
  settings: SettingsRepository(MemoryStore()),
  tts: tts ?? FakeTts(),
  reminders: reminders ?? FakeReminderService(),
  clock: fixedNow,
);

/// Bơm cả app (router thật, repository giả).
Future<void> pumpToeicApp(WidgetTester tester, AppDependencies deps, {String? initialLocation}) async {
  await tester.binding.setSurfaceSize(const Size(420, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    // UniqueKey: mỗi lần bơm là một app mới (router mới), kể cả khi test bơm nhiều lần.
    initialLocation == null
        ? ToeicApp(key: UniqueKey(), dependencies: deps)
        : ToeicApp(key: UniqueKey(), dependencies: deps, initialLocation: initialLocation),
  );
  await tester.pumpAndSettle();
}

/// Bơm một widget với đủ provider (không có router).
Future<void> pumpWithProviders(WidgetTester tester, AppDependencies deps, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(420, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MultiProvider(
      providers: deps.providers,
      child: MaterialApp(theme: AppTheme.light, home: child),
    ),
  );
  await tester.pumpAndSettle();
}
