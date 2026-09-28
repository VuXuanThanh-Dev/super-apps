import { MemoryUserStore } from '../memoryStore';
import { SqliteUserStore } from '../sqliteStore';
import { dayNumberFromString, dayStringFromNumber, localDayString } from '../dates';

describe('MemoryUserStore', () => {
  it('saves and removes words (case-insensitive)', async () => {
    const s = new MemoryUserStore();
    await s.setSaved('Company', true, 1);
    await s.setSaved('run', true, 2);
    expect(await s.isSaved('company')).toBe(true);
    expect((await s.getSavedWords()).map((x) => x.word)).toEqual(['run', 'company']);
    await s.setSaved('COMPANY', false);
    expect(await s.isSaved('company')).toBe(false);
  });

  it('records answers, activity and settings', async () => {
    const s = new MemoryUserStore();
    await s.recordAnswer('run', true, 1);
    await s.recordAnswer('run', false, 2);
    expect(await s.getWordStats()).toEqual([{ word: 'run', correct: 1, wrong: 1, lastSeen: 2 }]);
    await s.recordActivity('2026-09-28', 'review');
    await s.recordActivity('2026-09-28', 'quiz');
    expect(await s.getActivity()).toEqual([{ day: '2026-09-28', reviews: 1, quizzes: 1, reads: 0 }]);
    await s.setSetting('theme', 'dark');
    expect(await s.getSetting('theme')).toBe('dark');
    await s.reset();
    expect(await s.getSetting('theme')).toBeNull();
  });
});

describe('SqliteUserStore SQL (with a fake expo-sqlite database)', () => {
  it('creates tables and uses parameterized queries', async () => {
    const db = {
      execAsync: jest.fn(async (_sql: string) => undefined),
      runAsync: jest.fn(async () => ({ changes: 1, lastInsertRowId: 1 })),
      getFirstAsync: jest.fn(async () => ({ n: 1 })),
      getAllAsync: jest.fn(async () => [{ word: 'run', added_at: 5 }]),
    };
    const s = new SqliteUserStore(async () => db as never);
    await s.init();
    expect(db.execAsync.mock.calls[0]?.[0]).toContain('CREATE TABLE IF NOT EXISTS cards');
    await s.setSaved('Run', true, 5);
    expect(db.runAsync).toHaveBeenCalledWith('INSERT OR REPLACE INTO saved_words (word, added_at) VALUES (?, ?)', 'run', 5);
    expect(await s.isSaved('run')).toBe(true);
    expect(await s.getSavedWords()).toEqual([{ word: 'run', addedAt: 5 }]);
    await s.recordActivity('2026-09-28', 'quiz');
    expect(db.runAsync).toHaveBeenLastCalledWith(expect.stringContaining('quizzes = quizzes + 1'), '2026-09-28');
  });
});

describe('dates', () => {
  it('converts between local day strings and day numbers', () => {
    const n = dayNumberFromString('2026-09-28');
    expect(dayStringFromNumber(n)).toBe('2026-09-28');
    expect(dayNumberFromString('2026-09-29') - n).toBe(1);
    expect(localDayString(new Date(2026, 0, 5, 23, 59))).toBe('2026-01-05');
  });
});
