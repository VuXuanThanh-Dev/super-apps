/** User data kept on the device (SQLite in the app, memory in tests).
 * Words are keyed by their text (lower-case) so saved data survives a dataset rebuild. */

export interface Card {
  word: string;
  ease: number; // SM-2 easiness factor (>= 1.3)
  interval: number; // days
  repetitions: number; // successful reviews in a row
  due: number; // day number (see dates.ts)
  lastReview: number | null;
  lapses: number;
}

export interface WordStat {
  word: string;
  correct: number;
  wrong: number;
  lastSeen: number; // day number
}

export interface ActivityDay {
  day: string; // YYYY-MM-DD (local)
  reviews: number;
  quizzes: number;
  reads: number;
}

export type ActivityKind = 'review' | 'quiz' | 'read';

export interface UserStore {
  init(): Promise<void>;
  getSavedWords(): Promise<{ word: string; addedAt: number }[]>;
  isSaved(word: string): Promise<boolean>;
  setSaved(word: string, saved: boolean, now?: number): Promise<void>;
  getCard(word: string): Promise<Card | null>;
  getCards(): Promise<Card[]>;
  saveCard(card: Card): Promise<void>;
  recordAnswer(word: string, correct: boolean, day: number): Promise<void>;
  getWordStats(): Promise<WordStat[]>;
  recordActivity(day: string, kind: ActivityKind): Promise<void>;
  getActivity(): Promise<ActivityDay[]>;
  getSetting(key: string): Promise<string | null>;
  setSetting(key: string, value: string): Promise<void>;
  reset(): Promise<void>;
}
