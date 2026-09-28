import type { ActivityDay, Card, WordStat } from '@/storage/types';
import { dayNumberFromString } from '@/storage/dates';
import { isLearned } from '@/features/flashcards/sm2';

/** Number of days in a row (ending today, or yesterday if nothing yet today) with any activity. */
export function computeStreak(activity: ActivityDay[], today: number): number {
  const days = new Set(
    activity.filter((a) => a.reviews + a.quizzes + a.reads > 0).map((a) => dayNumberFromString(a.day)),
  );
  let d = days.has(today) ? today : today - 1;
  let streak = 0;
  while (days.has(d)) {
    streak += 1;
    d -= 1;
  }
  return streak;
}

export function wordsLearned(cards: Card[]): number {
  return cards.filter(isLearned).length;
}

export function dueCount(cards: Card[], today: number): number {
  return cards.filter((c) => c.due <= today).length;
}

export interface WeakWord {
  word: string;
  wrong: number;
  correct: number;
  accuracy: number; // 0..1
}

/** Weak words: answered wrong at least once, lowest accuracy first, then most wrong answers. */
export function weakWords(stats: WordStat[], cards: Card[], limit = 10): WeakWord[] {
  const lapses = new Map(cards.map((c) => [c.word, c.lapses]));
  return stats
    .map((s) => {
      const wrong = s.wrong + (lapses.get(s.word) ?? 0);
      const total = s.correct + wrong;
      return { word: s.word, wrong, correct: s.correct, accuracy: total ? s.correct / total : 1 };
    })
    .filter((w) => w.wrong > 0)
    .sort((a, b) => a.accuracy - b.accuracy || b.wrong - a.wrong || a.word.localeCompare(b.word))
    .slice(0, limit);
}

export interface Summary {
  learned: number;
  studied: number;
  due: number;
  streak: number;
  totalReviews: number;
  totalQuizzes: number;
}

export function summarize(cards: Card[], activity: ActivityDay[], today: number): Summary {
  return {
    learned: wordsLearned(cards),
    studied: cards.length,
    due: dueCount(cards, today),
    streak: computeStreak(activity, today),
    totalReviews: activity.reduce((n, a) => n + a.reviews, 0),
    totalQuizzes: activity.reduce((n, a) => n + a.quizzes, 0),
  };
}

/** Last N days of activity (oldest first), filling empty days with 0. */
export function lastDays(activity: ActivityDay[], today: number, n = 7): { day: number; count: number }[] {
  const byDay = new Map(activity.map((a) => [dayNumberFromString(a.day), a.reviews + a.quizzes + a.reads]));
  return Array.from({ length: n }, (_, i) => {
    const day = today - (n - 1 - i);
    return { day, count: byDay.get(day) ?? 0 };
  });
}
