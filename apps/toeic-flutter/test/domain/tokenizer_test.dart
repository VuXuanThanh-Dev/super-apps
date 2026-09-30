// Port 1:1 từ Task 5: apps/toeic/src/features/lookup/__tests__/tokenize.test.ts
import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_flutter/domain/lookup/tokenizer.dart';

List<String> words(String text) => [
  for (final t in tokenize(text))
    if (t.isWord) t.text,
];

void main() {
  group('tokenize', () {
    test('keeps every character (round trip)', () {
      const text = "Hello, Ms. Tran! The company's long-term plan—don't worry (2026).";
      expect(tokenize(text).map((t) => t.text).join(), text);
    });

    test('marks words and keeps apostrophes and hyphens inside words', () {
      expect(words("The company's long-term plan: don't stop."), [
        'The',
        "company's",
        'long-term',
        'plan',
        "don't",
        'stop',
      ]);
    });

    test('does not treat numbers and punctuation as words', () {
      expect(words('Call 0903-555, now!'), ['Call', 'now']);
    });

    test('handles curly apostrophes', () {
      expect(words('It’s the manager’s desk.'), ['It’s', 'the', 'manager’s', 'desk']);
    });

    test('returns nothing for empty text', () {
      expect(tokenize(''), isEmpty);
    });
  });
}
