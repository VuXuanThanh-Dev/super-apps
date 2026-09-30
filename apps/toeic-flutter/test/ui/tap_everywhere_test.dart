// M2 — "Mọi từ trên mọi màn hình chữ đều chạm được" (port của Task 5: features/__tests__/tapEverywhere.test.tsx).
// Bơm cả app (router thật + repository giả), mở từng màn hình chữ và kiểm tra từng từ.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_flutter/data/repositories/dataset_repository.dart';
import 'package:toeic_flutter/routing/router.dart';

import '../../testing/app_harness.dart';
import '../../testing/sample_data.dart';
import '../../testing/tappable.dart';

void main() {
  late DatasetRepository repo;
  setUpAll(() async => repo = await loadSampleRepository());

  testWidgets('reading passages: every word in text, questions and options', (tester) async {
    for (final p in repo.index.passages) {
      await pumpToeicApp(tester, fakeDependencies(repo), initialLocation: Routes.passage(p.id));
      expect(find.byKey(const Key('passage-text')), findsOneWidget);
      expectAllWordsTappable(tester, p.text);
      // Chạm một từ trong bài → popup
      final word = RegExp(r'[A-Za-z]{6,}').firstMatch(p.text)!.group(0)!;
      await tester.tapOnText(find.textRange.ofSubstring(word).first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('popup-word')), findsOneWidget, reason: 'tap "$word" in ${p.id}');
      await tester.tap(find.byKey(const Key('popup-close')));
      await tester.pumpAndSettle();
      for (final q in p.questions) {
        await tester.scrollUntilVisible(
          find.textContaining(q.question),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expectAllWordsTappable(tester, q.question);
        for (final o in q.options) {
          expectAllWordsTappable(tester, o);
        }
      }
    }
  });

  testWidgets('roleplay dialogs: every word of the setting and every line', (tester) async {
    for (final d in repo.roleplays) {
      await pumpToeicApp(tester, fakeDependencies(repo), initialLocation: Routes.roleplay(d.id));
      expectAllWordsTappable(tester, d.setting);
      for (var i = 0; i < d.lines.length; i++) {
        await tester.scrollUntilVisible(find.byKey(Key('line-$i')), 200, scrollable: find.byType(Scrollable).first);
        expectAllWordsTappable(tester, d.lines[i].text);
      }
    }
  });

  testWidgets('word detail screen: definition, example, collocation examples and tip', (tester) async {
    final w = repo.index.wordByKey('company')!;
    await pumpToeicApp(tester, fakeDependencies(repo), initialLocation: Routes.word(w.id));
    expectAllWordsTappable(tester, w.definition!);
    expectAllWordsTappable(tester, w.example!);
    for (final c in repo.index.collocationsForWord(w)) {
      expectAllWordsTappable(tester, c.example);
    }
    final tip = repo.index.familiesById[w.family]!.tip!;
    expectAllWordsTappable(tester, tip);
  });

  testWidgets('unit screen: family tips are tappable', (tester) async {
    await pumpToeicApp(tester, fakeDependencies(repo), initialLocation: Routes.topic('S1'));
    for (final f in repo.index.familiesInTopic('S1').where((f) => f.tip != null).take(2)) {
      await tester.scrollUntilVisible(find.textContaining(f.tip!), 200, scrollable: find.byType(Scrollable).first);
      expectAllWordsTappable(tester, f.tip!);
    }
  });

  testWidgets('flashcard back side: definition and example are tappable', (tester) async {
    await pumpToeicApp(tester, fakeDependencies(repo), initialLocation: Routes.flashcards('all'));
    final front = tester.widget<Text>(find.byKey(const Key('flash-front'))).data!;
    await tester.tap(find.byKey(const Key('flash-show')));
    await tester.pumpAndSettle();
    final w = repo.index.wordByKey(front)!;
    expectAllWordsTappable(tester, w.definition!);
    expectAllWordsTappable(tester, w.example!);
  });
}
