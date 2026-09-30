// SM-2 (SuperMemo 2, P. Wozniak 1987) — port 1:1 từ Task 5 (flashcards/sm2.ts).
// Chất lượng 0–5; app có 4 nút: Again = 1, Hard = 3, Good = 4, Easy = 5.
import 'dart:math' as math;

import '../models/user_data.dart';

enum Grade {
  again(1, 'Again'),
  hard(3, 'Hard'),
  good(4, 'Good'),
  easy(5, 'Easy');

  const Grade(this.quality, this.label);
  final int quality;
  final String label;
}

Card newCard(String word, int today) => Card(word: word.toLowerCase(), due: today);

Card review(Card card, Grade grade, int today) {
  final q = grade.quality;
  var ease = card.ease;
  var interval = card.interval;
  var repetitions = card.repetitions;
  var lapses = card.lapses;
  if (q < 3) {
    repetitions = 0;
    interval = 1;
    lapses += card.repetitions > 0 ? 1 : 0;
  } else {
    if (repetitions == 0) {
      interval = 1;
    } else if (repetitions == 1) {
      interval = 6;
    } else {
      interval = (interval * ease).round();
    }
    repetitions += 1;
  }
  // SM-2 gốc: thẻ trả lời sai (q < 3) học lại từ đầu nhưng KHÔNG đổi E-Factor.
  if (q >= 3) {
    ease = math.max(1.3, ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)));
    ease = (ease * 100).round() / 100;
  }
  return card.copyWith(
    ease: ease,
    interval: interval,
    repetitions: repetitions,
    lapses: lapses,
    due: today + interval,
    lastReview: today,
  );
}

/// Khoảng ngày tiếp theo để hiện trên nút, ví dụ "Good · 6d".
int previewInterval(Card card, Grade grade, int today) => review(card, grade, today).interval;

/// Một thẻ được tính là "đã thuộc" sau 2 lần nhớ đúng liên tiếp.
bool isLearned(Card card) => card.repetitions >= 2;
