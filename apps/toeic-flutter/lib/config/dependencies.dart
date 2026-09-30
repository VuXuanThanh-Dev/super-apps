import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/dataset_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/reminder_service.dart';
import '../data/services/tts_service.dart';
import '../ui/settings/view_models/settings_view_model.dart';
import '../utils/dates.dart';

/// Mọi phụ thuộc của app ở một chỗ. main.dart tạo bản thật; test tạo bản giả (fake).
/// Docs chính thức (app-architecture/case-study/dependency-injection): DI bằng package `provider`.
class AppDependencies {
  AppDependencies({
    required this.dataset,
    required this.user,
    required this.settings,
    required this.tts,
    required this.reminders,
    Clock? clock,
  }) : clock = clock ?? DateTime.now;

  final DatasetRepository dataset;
  final UserRepository user;
  final SettingsRepository settings;
  final TtsService tts;
  final ReminderService reminders;
  final Clock clock;

  List<SingleChildWidget> get providers => [
    Provider<DatasetRepository>.value(value: dataset),
    Provider<UserRepository>.value(value: user),
    Provider<SettingsRepository>.value(value: settings),
    Provider<TtsService>.value(value: tts),
    Provider<ReminderService>.value(value: reminders),
    Provider<Clock>.value(value: clock),
    ChangeNotifierProvider<SettingsViewModel>(
      create: (_) =>
          SettingsViewModel(settings: settings, reminders: reminders, tts: tts, user: user, clock: clock)..load(),
    ),
  ];
}
