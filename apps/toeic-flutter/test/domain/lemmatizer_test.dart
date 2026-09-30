// Port 1:1 từ Task 5: apps/toeic/src/features/lookup/__tests__/lemmatize.test.ts
// (cùng test case, để app Flutter và app React Native tra từ giống nhau).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_flutter/domain/lookup/lemmatizer.dart';

void main() {
  final irr = (jsonDecode(File('assets/content/irregular.json').readAsStringSync()) as Map<String, Object?>)
      .cast<String, String>();

  group('normalizeToken', () {
    for (final (raw, base) in [
      ('Company', 'company'),
      ('COMPANY', 'company'),
      ("company's", 'company'),
      ('company’s', 'company'),
      ("companies'", 'companies'),
      ('"meeting,"', 'meeting'),
      ('(delay)', 'delay'),
      ('report.', 'report'),
    ]) {
      test('$raw -> $base', () => expect(normalizeToken(raw).base, base));
    }

    for (final (raw, base, note) in [
      ("don't", 'do', "don't = do not"),
      ("Don't", 'do', "don't = do not"),
      ("can't", 'can', "can't = cannot"),
      ("won't", 'will', "won't = will not"),
      ("isn't", 'is', "isn't = is not"),
      ("we're", 'we', "we're = we are"),
      ("I'll", 'i', "i'll = i will"),
      ("they've", 'they', "they've = they have"),
      ("it's", 'it', "it's = it is / it has"),
    ]) {
      test('contraction $raw -> $base', () {
        final n = normalizeToken(raw);
        expect(n.base, base);
        expect(n.contraction, note);
      });
    }
  });

  group('lemmaCandidates', () {
    for (final (form, lemma) in [
      ('ran', 'run'),
      ('went', 'go'),
      ('bought', 'buy'),
      ('children', 'child'),
      ('taken', 'take'),
      ('met', 'meet'),
      ('better', 'good'),
    ]) {
      test('irregular $form -> $lemma', () => expect(lemmaCandidates(form, irr), contains(lemma)));
    }

    for (final (form, lemma) in [
      ('companies', 'company'),
      ('applied', 'apply'),
      ('boxes', 'box'),
      ('reports', 'report'),
      ('delivered', 'deliver'),
      ('approved', 'approve'),
      ('planned', 'plan'),
      ('negotiating', 'negotiate'),
      ('meeting', 'meet'),
      ('shipping', 'ship'),
      ('cheaper', 'cheap'),
      ('safest', 'safe'),
    ]) {
      test('regular $form -> $lemma', () => expect(lemmaCandidates(form, irr), contains(lemma)));
    }

    test('always tries the exact form first', () {
      expect(lemmaCandidates('meeting', irr).first, 'meeting');
      expect(lemmaCandidates('news', irr).first, 'news');
    });
  });
}
