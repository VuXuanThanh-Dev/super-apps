import 'package:flutter_test/flutter_test.dart';
import 'package:tap2_so_tu_vung/domain/models/word.dart';
import 'package:tap2_so_tu_vung/domain/word_of_the_day.dart';

void main() {
  const words = [
    Word(id: 3, text: 'c', partOfSpeech: 'n', meaning: 'c'),
    Word(id: 1, text: 'a', partOfSpeech: 'n', meaning: 'a'),
    Word(id: 2, text: 'b', partOfSpeech: 'n', meaning: 'b'),
  ];

  test('Word: accuracy, copyWith, ==', () {
    const w = Word(id: 1, text: 'a', partOfSpeech: 'n', meaning: 'a', reviewCount: 4, correctCount: 3);
    expect(w.accuracy, 0.75);
    expect(w.copyWith(favorite: true), isNot(w));
    expect(w.copyWith(), w);
  });

  test('Bài 2 (Ch.8): wordOfTheDay ổn định trong ngày, đổi theo ngày', () {
    final morning = wordOfTheDay(words, DateTime(2026, 9, 30, 7));
    final evening = wordOfTheDay(words, DateTime(2026, 9, 30, 22));
    final tomorrow = wordOfTheDay(words, DateTime(2026, 10, 1, 7));
    expect(morning, evening);
    expect(tomorrow, isNot(morning));
    expect(wordOfTheDay(const [], DateTime(2026)), isNull);
    // Không phụ thuộc thứ tự đầu vào
    expect(wordOfTheDay(words.reversed.toList(), DateTime(2026, 9, 30)), morning);
  });
}
