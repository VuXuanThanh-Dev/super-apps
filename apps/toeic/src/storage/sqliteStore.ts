import type { SQLiteDatabase } from 'expo-sqlite';
import type { ActivityDay, ActivityKind, Card, UserStore, WordStat } from './types';

const SCHEMA_VERSION = 1;

/** UserStore backed by expo-sqlite (on-device, offline). */
export class SqliteUserStore implements UserStore {
  private database: SQLiteDatabase | null = null;

  /** `open` is called once in init(), e.g. () => openDatabaseAsync('toeic-user.db'). */
  constructor(private readonly open: () => Promise<SQLiteDatabase>) {}

  private get db(): SQLiteDatabase {
    if (!this.database) throw new Error('SqliteUserStore: call init() first');
    return this.database;
  }

  async init(): Promise<void> {
    if (!this.database) this.database = await this.open();
    await this.db.execAsync(`
      PRAGMA journal_mode = WAL;
      CREATE TABLE IF NOT EXISTS saved_words (word TEXT PRIMARY KEY NOT NULL, added_at INTEGER NOT NULL);
      CREATE TABLE IF NOT EXISTS cards (
        word TEXT PRIMARY KEY NOT NULL, ease REAL NOT NULL, interval INTEGER NOT NULL,
        repetitions INTEGER NOT NULL, due INTEGER NOT NULL, last_review INTEGER, lapses INTEGER NOT NULL DEFAULT 0);
      CREATE TABLE IF NOT EXISTS word_stats (
        word TEXT PRIMARY KEY NOT NULL, correct INTEGER NOT NULL, wrong INTEGER NOT NULL, last_seen INTEGER NOT NULL);
      CREATE TABLE IF NOT EXISTS activity (
        day TEXT PRIMARY KEY NOT NULL, reviews INTEGER NOT NULL DEFAULT 0, quizzes INTEGER NOT NULL DEFAULT 0,
        reads INTEGER NOT NULL DEFAULT 0);
      CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY NOT NULL, value TEXT NOT NULL);
      PRAGMA user_version = ${SCHEMA_VERSION};
    `);
  }

  async getSavedWords() {
    const rows = await this.db.getAllAsync<{ word: string; added_at: number }>(
      'SELECT word, added_at FROM saved_words ORDER BY added_at DESC, word ASC',
    );
    return rows.map((r) => ({ word: r.word, addedAt: r.added_at }));
  }

  async isSaved(word: string) {
    const row = await this.db.getFirstAsync<{ n: number }>(
      'SELECT COUNT(*) AS n FROM saved_words WHERE word = ?',
      word.toLowerCase(),
    );
    return (row?.n ?? 0) > 0;
  }

  async setSaved(word: string, saved: boolean, now = Date.now()) {
    if (saved) {
      await this.db.runAsync('INSERT OR REPLACE INTO saved_words (word, added_at) VALUES (?, ?)', word.toLowerCase(), now);
    } else {
      await this.db.runAsync('DELETE FROM saved_words WHERE word = ?', word.toLowerCase());
    }
  }

  async getCard(word: string) {
    const r = await this.db.getFirstAsync<CardRow>('SELECT * FROM cards WHERE word = ?', word.toLowerCase());
    return r ? fromRow(r) : null;
  }

  async getCards() {
    const rows = await this.db.getAllAsync<CardRow>('SELECT * FROM cards');
    return rows.map(fromRow);
  }

  async saveCard(c: Card) {
    await this.db.runAsync(
      `INSERT OR REPLACE INTO cards (word, ease, interval, repetitions, due, last_review, lapses)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      c.word.toLowerCase(),
      c.ease,
      c.interval,
      c.repetitions,
      c.due,
      c.lastReview,
      c.lapses,
    );
  }

  async recordAnswer(word: string, correct: boolean, day: number) {
    await this.db.runAsync(
      `INSERT INTO word_stats (word, correct, wrong, last_seen) VALUES (?, ?, ?, ?)
       ON CONFLICT(word) DO UPDATE SET correct = correct + excluded.correct,
         wrong = wrong + excluded.wrong, last_seen = excluded.last_seen`,
      word.toLowerCase(),
      correct ? 1 : 0,
      correct ? 0 : 1,
      day,
    );
  }

  async getWordStats(): Promise<WordStat[]> {
    const rows = await this.db.getAllAsync<{ word: string; correct: number; wrong: number; last_seen: number }>(
      'SELECT * FROM word_stats',
    );
    return rows.map((r) => ({ word: r.word, correct: r.correct, wrong: r.wrong, lastSeen: r.last_seen }));
  }

  async recordActivity(day: string, kind: ActivityKind) {
    const col = kind === 'review' ? 'reviews' : kind === 'quiz' ? 'quizzes' : 'reads';
    await this.db.runAsync(
      `INSERT INTO activity (day, ${col}) VALUES (?, 1)
       ON CONFLICT(day) DO UPDATE SET ${col} = ${col} + 1`,
      day,
    );
  }

  async getActivity(): Promise<ActivityDay[]> {
    return this.db.getAllAsync<ActivityDay>('SELECT day, reviews, quizzes, reads FROM activity ORDER BY day ASC');
  }

  async getSetting(key: string) {
    const r = await this.db.getFirstAsync<{ value: string }>('SELECT value FROM settings WHERE key = ?', key);
    return r?.value ?? null;
  }

  async setSetting(key: string, value: string) {
    await this.db.runAsync('INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)', key, value);
  }

  async reset() {
    await this.db.execAsync(
      'DELETE FROM saved_words; DELETE FROM cards; DELETE FROM word_stats; DELETE FROM activity; DELETE FROM settings;',
    );
  }
}

interface CardRow {
  word: string;
  ease: number;
  interval: number;
  repetitions: number;
  due: number;
  last_review: number | null;
  lapses: number;
}

function fromRow(r: CardRow): Card {
  return {
    word: r.word,
    ease: r.ease,
    interval: r.interval,
    repetitions: r.repetitions,
    due: r.due,
    lastReview: r.last_review,
    lapses: r.lapses,
  };
}
