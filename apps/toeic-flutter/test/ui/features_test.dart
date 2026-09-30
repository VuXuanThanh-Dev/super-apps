// M3 — Widget test tính năng 1–8 trên cả app (router thật, repository giả, bộ dữ liệu mẫu).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_flutter/data/repositories/dataset_repository.dart';
import 'package:toeic_flutter/domain/models/user_data.dart' show ActivityKind;
import 'package:toeic_flutter/routing/router.dart';

import '../../testing/app_harness.dart';
import '../../testing/fakes/fakes.dart';
import '../../testing/sample_data.dart';

void main() {
  late DatasetRepository repo;
  setUpAll(() async => repo = await loadSampleRepository());

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('app starts on Home with 5 tabs and a sample-data banner', (tester) async {
    await pumpToeicApp(tester, fakeDependencies(repo));
    for (final tab in ['Home', 'Words', 'Practice', 'Read', 'Saved']) {
      expect(find.text(tab), findsWidgets);
    }
    expect(find.byKey(const Key('sample-banner')), findsOneWidget);
    expect(find.text('16 words · 2 units · 0 saved'), findsOneWidget);
  });

  testWidgets('1 · Words: units, search (no accents), word detail', (tester) async {
    await pumpToeicApp(tester, fakeDependencies(repo), initialLocation: Routes.words);
    expect(find.byKey(const Key('topic-S1')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('vocab-search')), 'cong ty');
    await tester.pumpAndSettle();
    final company = repo.index.wordByKey('company')!;
    await tapKey(tester, 'word-${company.id}');
    expect(find.text('công ty'), findsOneWidget);
    await tapKey(tester, 'word-save');
    expect(find.text('Saved (tap to remove)'), findsOneWidget);
  });

  testWidgets('1 · Words: open a unit, start its flashcards', (tester) async {
    await pumpToeicApp(tester, fakeDependencies(repo), initialLocation: Routes.words);
    await tapKey(tester, 'topic-S2');
    expect(find.textContaining('S2 · Travel Basics'), findsOneWidget);
    await tapKey(tester, 'topic-flashcards');
    expect(find.byKey(const Key('flash-front')), findsOneWidget);
  });

  testWidgets('2 · Flashcards: show answer, grade, next card; Home counts the review', (tester) async {
    final user = FakeUserRepository();
    await pumpToeicApp(tester, fakeDependencies(repo, user: user), initialLocation: Routes.practice);
    await tapKey(tester, 'start-flashcards');
    final front = tester.widget<Text>(find.byKey(const Key('flash-front'))).data!;
    await tapKey(tester, 'flash-show');
    expect(find.byKey(const Key('flash-back')), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    await tapKey(tester, 'grade-good');
    final next = tester.widget<Text>(find.byKey(const Key('flash-front'))).data!;
    expect(next, isNot(front));
    expect(user.cardMap.keys, [front.toLowerCase()]);
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('1 reviews · 0 quiz answers'), findsOneWidget);
  });

  testWidgets('3 · Quiz: answer, feedback, next, score', (tester) async {
    await pumpToeicApp(tester, fakeDependencies(repo), initialLocation: Routes.practice);
    await tapKey(tester, 'quiz-meaning');
    await tapKey(tester, 'quiz-option-0');
    expect(find.byKey(const Key('quiz-feedback')), findsOneWidget);
    await tapKey(tester, 'quiz-next');
    expect(find.textContaining('Question 2 /'), findsOneWidget);
  });

  testWidgets('3 · Quiz: collocation matching UI', (tester) async {
    await pumpToeicApp(tester, fakeDependencies(repo), initialLocation: Routes.practice);
    await tapKey(tester, 'quiz-collocation');
    expect(find.byKey(const Key('match-left-0')), findsOneWidget);
    // ghép lần lượt trái i với phải i (có thể sai) rồi kiểm tra
    var i = 0;
    while (find.byKey(Key('match-left-$i')).evaluate().isNotEmpty) {
      await tapKey(tester, 'match-left-$i');
      await tapKey(tester, 'match-right-$i');
      i++;
    }
    await tapKey(tester, 'match-check');
    expect(find.byKey(const Key('quiz-feedback')), findsOneWidget);
  });

  testWidgets('4 · Read: list passages, answer a question with A–D', (tester) async {
    await pumpToeicApp(tester, fakeDependencies(repo), initialLocation: Routes.read);
    final p = repo.index.passages.first;
    await tapKey(tester, 'passage-${p.id}');
    await tester.scrollUntilVisible(
      find.byKey(const Key('q0-option-0')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.descendant(of: find.byKey(const Key('q0-option-0')), matching: find.byType(IconButton)));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<IconButton>(
            find.descendant(of: find.byKey(const Key('q0-option-1')), matching: find.byType(IconButton)),
          )
          .onPressed,
      isNull,
    ); // đã trả lời → khoá
  });

  testWidgets('5 · Roleplay: hide my lines, reveal one', (tester) async {
    final d = repo.roleplays.first;
    await pumpToeicApp(tester, fakeDependencies(repo), initialLocation: Routes.read);
    await tapKey(tester, 'dialog-${d.id}');
    await tapKey(tester, 'role-${d.lines.first.speaker}');
    expect(find.byKey(const Key('reveal-0')), findsOneWidget);
    await tapKey(tester, 'reveal-0');
    expect(find.byKey(const Key('line-0')), findsOneWidget);
  });

  testWidgets('6 · Saved: list, remove, daily reminder with time picker', (tester) async {
    final user = FakeUserRepository();
    await user.setSaved('ticket', saved: true);
    final reminders = FakeReminderService();
    await pumpToeicApp(
      tester,
      fakeDependencies(repo, user: user, reminders: reminders),
      initialLocation: Routes.saved,
    );
    expect(find.byKey(const Key('saved-ticket')), findsOneWidget);
    expect(find.byKey(const Key('review-saved')), findsOneWidget);
    // Hộp chọn giờ cần chỗ rộng hơn với font của test → phóng to màn hình ảo.
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    await tester.pumpAndSettle();
    await tapKey(tester, 'reminder-switch');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(reminders.scheduled, const TimeOfDay(hour: 20, minute: 0));
    expect(find.textContaining('Every day at 20:00'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove ticket'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('saved-empty')), findsOneWidget);
  });

  testWidgets('7 · Home stats: streak, weak words open the popup', (tester) async {
    final user = FakeUserRepository();
    await user.recordActivity('2026-09-27', ActivityKind.review);
    await user.recordActivity('2026-09-28', ActivityKind.quiz);
    await user.recordAnswer('delay', correct: false, day: 1);
    await pumpToeicApp(tester, fakeDependencies(repo, user: user));
    expect(find.text('2'), findsWidgets); // streak = 2
    await tester.scrollUntilVisible(find.text('delay'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('delay'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('popup-word')), findsOneWidget);
  });

  testWidgets('8 · Dark mode: Settings → Dark changes the whole app theme', (tester) async {
    await pumpToeicApp(tester, fakeDependencies(repo));
    await tapKey(tester, 'open-settings');
    BuildContext ctx() => tester.element(find.byKey(const Key('theme-current')));
    expect(Theme.of(ctx()).brightness, Brightness.light);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(find.text('Current: dark'), findsOneWidget);
    expect(Theme.of(ctx()).brightness, Brightness.dark);
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(Theme.of(ctx()).brightness, Brightness.light);
  });
}
