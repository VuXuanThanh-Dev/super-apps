import type { ActivityDay, ActivityKind, Card, UserStore, WordStat } from './types';

/** In-memory UserStore, used by tests (same behaviour as the SQLite store). */
export class MemoryUserStore implements UserStore {
  private saved = new Map<string, number>();
  private cards = new Map<string, Card>();
  private stats = new Map<string, WordStat>();
  private activity = new Map<string, ActivityDay>();
  private settings = new Map<string, string>();

  async init(): Promise<void> {}

  async getSavedWords() {
    return [...this.saved.entries()]
      .map(([word, addedAt]) => ({ word, addedAt }))
      .sort((a, b) => b.addedAt - a.addedAt || a.word.localeCompare(b.word));
  }

  async isSaved(word: string) {
    return this.saved.has(word.toLowerCase());
  }

  async setSaved(word: string, saved: boolean, now = Date.now()) {
    const key = word.toLowerCase();
    if (saved) this.saved.set(key, now);
    else this.saved.delete(key);
  }

  async getCard(word: string) {
    return this.cards.get(word.toLowerCase()) ?? null;
  }

  async getCards() {
    return [...this.cards.values()];
  }

  async saveCard(card: Card) {
    this.cards.set(card.word.toLowerCase(), { ...card, word: card.word.toLowerCase() });
  }

  async recordAnswer(word: string, correct: boolean, day: number) {
    const key = word.toLowerCase();
    const s = this.stats.get(key) ?? { word: key, correct: 0, wrong: 0, lastSeen: day };
    this.stats.set(key, {
      word: key,
      correct: s.correct + (correct ? 1 : 0),
      wrong: s.wrong + (correct ? 0 : 1),
      lastSeen: day,
    });
  }

  async getWordStats() {
    return [...this.stats.values()];
  }

  async recordActivity(day: string, kind: ActivityKind) {
    const a = this.activity.get(day) ?? { day, reviews: 0, quizzes: 0, reads: 0 };
    if (kind === 'review') a.reviews += 1;
    if (kind === 'quiz') a.quizzes += 1;
    if (kind === 'read') a.reads += 1;
    this.activity.set(day, a);
  }

  async getActivity() {
    return [...this.activity.values()].sort((a, b) => a.day.localeCompare(b.day));
  }

  async getSetting(key: string) {
    return this.settings.get(key) ?? null;
  }

  async setSetting(key: string, value: string) {
    this.settings.set(key, value);
  }

  async reset() {
    this.saved.clear();
    this.cards.clear();
    this.stats.clear();
    this.activity.clear();
    this.settings.clear();
  }
}
