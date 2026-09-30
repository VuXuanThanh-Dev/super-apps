// M2 — Chạm vào bất kỳ từ nào để xem nghĩa (widget test, offline, bộ dữ liệu mẫu).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_flutter/data/repositories/dataset_repository.dart';
import 'package:toeic_flutter/ui/lookup/widgets/tappable_text.dart';

import '../../testing/app_harness.dart';
import '../../testing/fakes/fakes.dart';
import '../../testing/sample_data.dart';
import '../../testing/tappable.dart';

void main() {
  late DatasetRepository repo;
  setUpAll(() async => repo = await loadSampleRepository());

  Future<void> pumpText(WidgetTester tester, String text, {FakeUserRepository? user, FakeTts? tts}) =>
      pumpWithProviders(
        tester,
        fakeDependencies(repo, user: user, tts: tts),
        Scaffold(
          body: Padding(padding: const EdgeInsets.all(16), child: TappableText(text)),
        ),
      );

  Future<void> tapWord(WidgetTester tester, String word) async {
    await tester.tapOnText(find.textRange.ofSubstring(word).first);
    await tester.pumpAndSettle();
  }

  String popupWord(WidgetTester tester) => tester.widget<Text>(find.byKey(const Key('popup-word'))).data!;

  testWidgets('every word of a text is tappable (numbers and punctuation are not)', (tester) async {
    const text = "Two employees ran out of time, so the company's meeting was delayed — don't wait until 9:00!";
    await pumpText(tester, text);
    expectAllWordsTappable(tester, text);
    expect(tappableWords(tester), isNot(contains('9')));
  });

  testWidgets('tap a word → popup with definition, Vietnamese, IPA, family, collocations, example', (tester) async {
    await pumpText(tester, 'Our team manages the budget.');
    await tapWord(tester, 'manages');
    expect(popupWord(tester), 'manage');
    expect(find.text('manages → manage'), findsOneWidget); // dạng từ → lemma
    expect(find.text('quản lý'), findsOneWidget);
    final w = repo.index.wordByKey('manage')!;
    expect(find.textContaining(w.ipa!), findsOneWidget);
    expect(find.text('WORD FAMILY · HỌ TỪ'), findsOneWidget);
    expect(find.text('manager (n)'), findsOneWidget);
    expect(find.text('COLLOCATIONS'), findsOneWidget);
    expect(find.byKey(const Key('popup-save')), findsOneWidget);
    // định nghĩa, ví dụ, ví dụ collocation trong popup cũng chạm được
    expectAllWordsTappable(tester, w.definition!);
    expectAllWordsTappable(tester, w.example!);
    for (final c in repo.index.collocationsForWord(w)) {
      expectAllWordsTappable(tester, c.example);
    }
  });

  testWidgets('irregular forms, capitals, punctuation and possessives map to the lemma', (tester) async {
    await pumpText(tester, 'Ms. Lan RAN to the Company\'s office, "meetings," and met everyone.');
    for (final (tap, lemma) in [('RAN', 'run'), ("Company's", 'company'), ('meetings', 'meeting'), ('met', 'meet')]) {
      await tapWord(tester, tap);
      expect(popupWord(tester), lemma, reason: tap);
      await tester.tap(find.byKey(const Key('popup-close')));
      await tester.pumpAndSettle();
    }
  });

  testWidgets("contractions: don't → do (common word)", (tester) async {
    await pumpText(tester, "Please don't be late.");
    await tapWord(tester, "don't");
    expect(popupWord(tester), 'do');
    expect(find.text("don't = do not"), findsOneWidget);
    expect(find.textContaining('common word'), findsOneWidget);
  });

  testWidgets('unknown word → "not found", no Save button', (tester) async {
    await pumpText(tester, 'This is blorptastic.');
    await tapWord(tester, 'blorptastic');
    expect(find.byKey(const Key('popup-notfound')), findsOneWidget);
    expect(find.byKey(const Key('popup-save')), findsNothing);
  });

  testWidgets('Save to my list stores the lemma; speaker button uses text-to-speech', (tester) async {
    final user = FakeUserRepository();
    final tts = FakeTts();
    await pumpText(tester, 'Two tickets, please.', user: user, tts: tts);
    await tapWord(tester, 'tickets');
    await tester.ensureVisible(find.byKey(const Key('popup-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('popup-save')));
    await tester.pumpAndSettle();
    expect(user.saved.keys, ['ticket']);
    expect(find.text('Saved (tap to remove)'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('popup-speak')));
    await tester.tap(find.byKey(const Key('popup-speak')));
    expect(tts.spoken, ['ticket']);
    await tester.ensureVisible(find.byKey(const Key('popup-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('popup-save')));
    await tester.pumpAndSettle();
    expect(user.saved, isEmpty);
  });

  testWidgets('tap a word inside the popup → opens in the same popup, Back returns', (tester) async {
    await pumpText(tester, 'book');
    await tapWord(tester, 'book');
    expect(popupWord(tester), 'book');
    // chạm một từ trong định nghĩa của "book" (bên trong popup)
    final def = repo.index.wordByKey('book')!.definition!;
    final inner = def.split(' ').firstWhere((w) => w.length > 3 && RegExp(r'^[a-z]+$').hasMatch(w));
    await tester.tapOnText(find.textRange.ofSubstring(inner).last);
    await tester.pumpAndSettle();
    expect(popupWord(tester), isNot('book'));
    await tester.tap(find.byKey(const Key('popup-back')));
    await tester.pumpAndSettle();
    expect(popupWord(tester), 'book');
  });
}
