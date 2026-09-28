import { newCard } from '@/features/flashcards/sm2';
import type { ActivityDay, Card } from '@/storage/types';
import { dayNumberFromString, dayStringFromNumber } from '@/storage/dates';
import { computeStreak, lastDays, summarize, weakWords, wordsLearned } from '../stats';

const day = (s: string, reviews = 1): ActivityDay => ({ day: s, reviews, quizzes: 0, reads: 0 });
const today = dayNumberFromString('2026-09-28');

describe('streak', () => {
  it('counts consecutive days ending today', () => {
    expect(computeStreak([day('2026-09-26'), day('2026-09-27'), day('2026-09-28')], today)).toBe(3);
  });
  it('still counts if today is not done yet (ends yesterday)', () => {
    expect(computeStreak([day('2026-09-26'), day('2026-09-27')], today)).toBe(2);
  });
  it('breaks on a missing day and ignores empty days', () => {
    expect(computeStreak([day('2026-09-25'), day('2026-09-27', 0), day('2026-09-28')], today)).toBe(1);
    expect(computeStreak([], today)).toBe(0);
  });
});

describe('words learned, weak words, summary', () => {
  const cards: Card[] = [
    { ...newCard('run', 0), repetitions: 2 },
    { ...newCard('book', 0), repetitions: 1, due: today - 1 },
    { ...newCard('delay', 0), repetitions: 0, lapses: 2, due: today + 3 },
  ];
  it('counts cards with 2+ successful reviews as learned', () => {
    expect(wordsLearned(cards)).toBe(1);
  });
  it('orders weak words by accuracy then wrong count, adding flashcard lapses', () => {
    const w = weakWords(
      [
        { word: 'run', correct: 5, wrong: 1, lastSeen: 1 },
        { word: 'delay', correct: 1, wrong: 1, lastSeen: 1 },
        { word: 'ticket', correct: 0, wrong: 2, lastSeen: 1 },
        { word: 'book', correct: 3, wrong: 0, lastSeen: 1 },
      ],
      cards,
    );
    expect(w.map((x) => x.word)).toEqual(['ticket', 'delay', 'run']);
    expect(w[1]).toMatchObject({ word: 'delay', wrong: 3, correct: 1, accuracy: 0.25 });
  });
  it('summarizes progress', () => {
    const s = summarize(cards, [day('2026-09-28', 4)], today);
    expect(s).toMatchObject({ learned: 1, studied: 3, due: 2, streak: 1, totalReviews: 4 });
  });
  it('builds the last 7 days chart data', () => {
    const d = lastDays([day('2026-09-28', 3), day('2026-09-22', 2)], today);
    expect(d).toHaveLength(7);
    expect(dayStringFromNumber(d[0]?.day ?? 0)).toBe('2026-09-22');
    expect(d.map((x) => x.count)).toEqual([2, 0, 0, 0, 0, 0, 3]);
  });
});
