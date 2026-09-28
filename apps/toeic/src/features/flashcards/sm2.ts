import type { Card } from '@/storage/types';

/** SM-2 spaced repetition (SuperMemo 2, P. Wozniak 1987), as used by Anki's
 * early versions. Quality 0-5; the app uses 4 buttons:
 *   Again = 1, Hard = 3, Good = 4, Easy = 5. */
export type Grade = 'again' | 'hard' | 'good' | 'easy';
export const GRADE_QUALITY: Record<Grade, number> = { again: 1, hard: 3, good: 4, easy: 5 };

export function newCard(word: string, today: number): Card {
  return { word: word.toLowerCase(), ease: 2.5, interval: 0, repetitions: 0, due: today, lastReview: null, lapses: 0 };
}

export function review(card: Card, grade: Grade, today: number): Card {
  const q = GRADE_QUALITY[grade];
  let { ease, interval, repetitions, lapses } = card;
  if (q < 3) {
    repetitions = 0;
    interval = 1;
    lapses += card.repetitions > 0 ? 1 : 0;
  } else {
    if (repetitions === 0) interval = 1;
    else if (repetitions === 1) interval = 6;
    else interval = Math.round(interval * ease);
    repetitions += 1;
  }
  // Original SM-2: a failed card (q < 3) starts again WITHOUT changing the E-Factor.
  if (q >= 3) {
    ease = Math.max(1.3, ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)));
    ease = Math.round(ease * 100) / 100;
  }
  return { ...card, ease, interval, repetitions, lapses, due: today + interval, lastReview: today };
}

/** Next interval preview for a button label, e.g. "Good · 6d". */
export function previewInterval(card: Card, grade: Grade, today: number): number {
  return review(card, grade, today).interval;
}

/** A card counts as "learned" after 2 successful reviews in a row. */
export function isLearned(card: Card): boolean {
  return card.repetitions >= 2;
}
