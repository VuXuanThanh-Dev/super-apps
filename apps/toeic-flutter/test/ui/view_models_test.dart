// M3 — Unit test cho ViewModel của tính năng 1–8. Docs chính thức (case-study/testing):
// test ViewModel bằng repository GIẢ (fake), không cần widget.
import 'package:flutter/material.dart' show ThemeMode, TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_flutter/data/repositories/dataset_repository.dart';
import 'package:toeic_flutter/data/repositories/settings_repository.dart';
import 'package:toeic_flutter/data/services/key_value_store.dart';
import 'package:toeic_flutter/domain/models/user_data.dart' show ActivityKind;
import 'package:toeic_flutter/domain/quiz/quiz_generator.dart';
import 'package:toeic_flutter/domain/srs/sm2.dart';
import 'package:toeic_flutter/domain/vocabulary/search.dart';
import 'package:toeic_flutter/ui/flashcards/view_models/flashcards_view_model.dart';
import 'package:toeic_flutter/ui/home/view_models/home_view_model.dart';
import 'package:toeic_flutter/ui/quiz/view_models/quiz_view_model.dart';
import 'package:toeic_flutter/ui/reading/view_models/passage_view_model.dart';
import 'package:toeic_flutter/ui/roleplay/view_models/roleplay_view_model.dart';
import 'package:toeic_flutter/ui/saved/view_models/saved_view_model.dart';
import 'package:toeic_flutter/ui/settings/view_models/settings_view_model.dart';
import 'package:toeic_flutter/ui/vocabulary/view_models/vocabulary_view_model.dart';
import 'package:toeic_flutter/utils/dates.dart';

import '../../testing/app_harness.dart';
import '../../testing/fakes/fakes.dart';
import '../../testing/sample_data.dart';

void main() {
  late DatasetRepository repo;
  late FakeUserRepository user;
  late FakeTts tts;
  setUpAll(() async => repo = await loadSampleRepository());
  setUp(() {
    user = FakeUserRepository();
    tts = FakeTts();
  });
  final today = dayNumber(fixedNow());
  const todayStr = '2026-09-28';

  group('1 · Vocabulary', () {
    test('lists units and searches English / Vietnamese with or without accents', () {
      final vm = VocabularyViewModel(dataset: repo);
      expect(vm.topics.map((t) => t.topic.code), ['S1', 'S2']);
      expect(vm.searching, isFalse);
      vm.search('cong ty');
      expect(vm.results.first.word, 'company');
      vm.search('TICK');
      expect(vm.results.first.word, 'ticket');
    });

    test('unit and word view models', () {
      final t = TopicViewModel(code: 'S1', dataset: repo);
      expect((t.families.length, t.wordCount), (5, 9));
      final w = WordViewModel(wordId: repo.index.wordByKey('company')!.id, dataset: repo);
      expect(w.tip, isNotNull);
      expect(w.topic?.code, 'S1');
    });
  });

  group('2 · Flashcards (SM-2)', () {
    FlashcardsViewModel make(StudyScope scope) =>
        FlashcardsViewModel(scope: scope, dataset: repo, user: user, tts: tts, clock: fixedNow);

    test('queue = new words up to the limit; grading saves the SM-2 card and counts a review', () async {
      final vm = make(const AllWords());
      await pumpEventQueue();
      expect(vm.queue, hasLength(10));
      final first = vm.current!;
      expect(vm.showAnswer, isFalse);
      vm.reveal();
      expect(vm.showAnswer, isTrue);
      expect(vm.preview(Grade.good), 1);
      await vm.grade.execute(Grade.good);
      final card = user.cardMap[first.key]!;
      expect((card.interval, card.repetitions, card.due), (1, 1, today + 1));
      expect(user.days[todayStr]!.reviews, 1);
      expect(vm.position, 1);
      expect(vm.showAnswer, isFalse);
    });

    test('"Again" puts the card back at the end of the session', () async {
      final vm = make(const TopicScope('S2'));
      await pumpEventQueue();
      final n = vm.queue.length;
      final first = vm.current!;
      await vm.grade.execute(Grade.again);
      expect(vm.queue, hasLength(n + 1));
      expect(vm.queue.last, first);
    });

    test('due cards come first; saved scope uses saved words only', () async {
      user.cardMap['ticket'] = newCard('ticket', 0).copyWith(due: today - 2, repetitions: 1, interval: 1);
      await user.setSaved('delay', saved: true);
      final all = make(const AllWords());
      await pumpEventQueue();
      expect(all.current!.word, 'ticket');
      final saved = make(const SavedWords());
      await pumpEventQueue();
      expect(saved.queue.map((w) => w.word), ['delay']);
    });

    test('done when the queue is empty', () async {
      final vm = make(const SavedWords());
      await pumpEventQueue();
      expect(vm.done, isTrue);
    });
  });

  group('3 · Quizzes', () {
    QuizViewModel make(QuizType type) => QuizViewModel(
      type: type,
      scope: const AllWords(),
      dataset: repo,
      user: user,
      tts: tts,
      clock: fixedNow,
      seed: 42,
      count: 5,
    );

    test('meaning quiz: correct answer scores, answers are recorded for stats', () async {
      final vm = make(QuizType.meaning);
      await pumpEventQueue();
      expect(vm.questions, hasLength(5));
      final q = vm.current! as ChoiceQuestion;
      await vm.choose(q.answer);
      expect(vm.score, 1);
      expect(user.stats[q.word]!.correct, 1);
      expect(user.days[todayStr]!.quizzes, 1);
      vm.next();
      final q2 = vm.current! as ChoiceQuestion;
      await vm.choose((q2.answer + 1) % q2.options.length);
      expect(vm.score, 1);
      expect(user.stats[q2.word]!.wrong, 1);
    });

    test('cannot go next before answering; done after the last question', () async {
      final vm = make(QuizType.blank);
      await pumpEventQueue();
      vm.next();
      expect(vm.index, 0);
      for (var i = 0; i < vm.questions.length; i++) {
        await vm.choose(0);
        vm.next();
      }
      expect(vm.done, isTrue);
    });

    test('listening quiz reads the word aloud', () async {
      final vm = make(QuizType.listening);
      await pumpEventQueue();
      final q = vm.current! as ChoiceQuestion;
      expect(tts.spoken, [q.speakText]);
      await vm.speakCurrent();
      expect(tts.spoken, hasLength(2));
    });

    test('collocation matching: pair every phrase, then check', () async {
      final vm = make(QuizType.collocation);
      await pumpEventQueue();
      final q = vm.current! as MatchQuestion;
      expect(vm.canCheckMatch, isFalse);
      for (var i = 0; i < q.left.length; i++) {
        vm.selectLeft(i);
        vm.selectRight(q.answer[i]);
      }
      expect(vm.canCheckMatch, isTrue);
      await vm.checkMatch();
      expect(vm.score, 1);
      expect(vm.checked, isTrue);
    });

    test('word family quiz works on the sample', () async {
      final vm = make(QuizType.family);
      await pumpEventQueue();
      expect(vm.questions, isNotEmpty);
    });
  });

  group('4 · Reading passages', () {
    test('opening a passage counts a "read"; answers are scored', () async {
      final p = repo.index.passages.first;
      final vm = PassageViewModel(passageId: p.id, dataset: repo, user: user, clock: fixedNow);
      await pumpEventQueue();
      expect(user.days[todayStr]!.reads, 1);
      expect(vm.unitWords, contains('company'));
      vm.answer(0, p.questions[0].answer);
      vm.answer(0, 3); // đã trả lời → không đổi
      expect(vm.answers[0], p.questions[0].answer);
      expect(vm.correctCount, 1);
    });
  });

  group('5 · Roleplay dialogs', () {
    test('choosing my role hides my lines until I reveal them', () {
      final d = repo.roleplays.first;
      final vm = RoleplayViewModel(roleplayId: d.id, dataset: repo, tts: tts);
      expect(vm.isHidden(0), isFalse);
      final me = d.lines.first.speaker;
      vm.setMyRole(me);
      expect(vm.isHidden(0), isTrue);
      final other = d.lines.indexWhere((l) => l.speaker != me);
      expect(vm.isHidden(other), isFalse);
      vm.reveal(0);
      expect(vm.isHidden(0), isFalse);
    });
  });

  group('6 · Saved words + daily reminder', () {
    test('saved list follows the repository', () async {
      final vm = SavedViewModel(dataset: repo, user: user);
      await pumpEventQueue();
      expect(vm.items, isEmpty);
      await user.setSaved('ticket', saved: true);
      await pumpEventQueue();
      expect(vm.items.single.word?.vi, isNotNull);
      await vm.remove.execute('ticket');
      await pumpEventQueue();
      expect(vm.items, isEmpty);
    });

    SettingsViewModel settings(FakeReminderService reminders) => SettingsViewModel(
      settings: SettingsRepository(MemoryStore()),
      reminders: reminders,
      tts: tts,
      user: user,
      clock: fixedNow,
    );

    test('turn on: asks permission, schedules daily with a helpful text, then off cancels', () async {
      final reminders = FakeReminderService();
      await user.setSaved('ticket', saved: true);
      final vm = settings(reminders);
      await vm.setReminder(const TimeOfDay(hour: 20, minute: 0));
      expect(reminders.scheduled, const TimeOfDay(hour: 20, minute: 0));
      expect(reminders.body, contains('1 saved'));
      expect(vm.reminder, isNotNull);
      await vm.setReminder(null);
      expect(reminders.cancelCalls, 1);
      expect(vm.reminder, isNull);
    });

    test('permission denied or web → stays off with a message', () async {
      final denied = settings(FakeReminderService(grant: false));
      await denied.setReminder(const TimeOfDay(hour: 7, minute: 30));
      expect(denied.reminder, isNull);
      expect(denied.message, contains('permission'));
      final web = settings(FakeReminderService(isSupported: false));
      await web.setReminder(const TimeOfDay(hour: 7, minute: 30));
      expect(web.reminder, isNull);
      expect(web.message, contains('web'));
    });
  });

  group('7 · Progress stats', () {
    test('home summary updates when the user studies', () async {
      final vm = HomeViewModel(dataset: repo, user: user, clock: fixedNow);
      await pumpEventQueue();
      expect(vm.summary.studied, 0);
      await user.saveCard(review(newCard('ticket', today), Grade.good, today));
      await user.recordActivity(todayStr, ActivityKind.review);
      await user.recordAnswer('delay', correct: false, day: today);
      await pumpEventQueue();
      expect((vm.summary.studied, vm.summary.streak, vm.summary.totalReviews), (1, 1, 1));
      expect(vm.week.last.count, 1);
      expect(vm.weak.single.word, 'delay');
      expect(vm.totalWords, 16);
      expect(vm.isSample, isTrue);
    });
  });

  group('8 · Dark mode', () {
    test('theme mode is saved and loaded again', () async {
      final store = SettingsRepository(MemoryStore());
      final vm = SettingsViewModel(
        settings: store,
        reminders: FakeReminderService(),
        tts: tts,
        user: user,
        clock: fixedNow,
      );
      await vm.load();
      expect(vm.themeMode, ThemeMode.system);
      await vm.setThemeMode(ThemeMode.dark);
      expect(await store.themeMode(), ThemeMode.dark);
      await vm.setSpeechRate(0.8);
      expect(tts.rate, 0.8);
    });
  });
}
