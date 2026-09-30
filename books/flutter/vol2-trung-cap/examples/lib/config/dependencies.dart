import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/settings_repository.dart';
import '../data/repositories/word_repository.dart';
import '../data/services/dictionary_client.dart';
import '../data/services/reminder_service.dart';
import '../data/services/tts_service.dart';
import '../ui/settings/settings_viewmodel.dart';

/// Mọi phụ thuộc của app ở một chỗ (giống `providers` trong `app.config.ts` của Angular).
/// main.dart tạo bản thật; test tạo bản giả (fake) — UI không biết khác nhau.
class AppDependencies {
  const AppDependencies({
    required this.words,
    required this.settings,
    required this.tts,
    required this.reminders,
    required this.dictionary,
  });

  final WordRepository words;
  final SettingsRepository settings;
  final TtsService tts;
  final ReminderService reminders;
  final DictionaryClient dictionary;

  /// Danh sách provider cho MultiProvider. Docs chính thức: "Use dependency injection" (package provider).
  List<SingleChildWidget> get providers => [
    Provider<WordRepository>.value(value: words),
    Provider<SettingsRepository>.value(value: settings),
    Provider<TtsService>.value(value: tts),
    Provider<ReminderService>.value(value: reminders),
    Provider<DictionaryClient>.value(value: dictionary),
    ChangeNotifierProvider<SettingsViewModel>(
      create: (_) => SettingsViewModel(settings: settings, reminders: reminders, tts: tts)..load(),
    ),
  ];
}
