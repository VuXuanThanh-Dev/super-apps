import { render, screen, userEvent } from '@testing-library/react-native';
import { POSTS } from '@/test/fixtures';
import { createNodeSqliteDb } from '@/test/nodeSqliteDb';
import { decideCache } from './cachePolicy';
import { SqliteDemo } from './SqliteDemo';

// Thay expo-sqlite (cần điện thoại) bằng node:sqlite có cùng API tối thiểu.
jest.mock('expo-sqlite', () => ({
  // eslint-disable-next-line @typescript-eslint/no-require-imports -- jest.mock factory không dùng được import
  openDatabaseAsync: async () => require('@/test/nodeSqliteDb').createNodeSqliteDb(),
}));

describe('Tập 2 — Chương 3: lưu trữ offline', () => {
  it('bài tập: decideCache theo TTL', () => {
    expect(decideCache(null, 0, 1000)).toBe('fetch');
    expect(decideCache({ posts: POSTS, savedAt: 0 }, 500, 1000)).toBe('use-cache');
    expect(decideCache({ posts: POSTS, savedAt: 0 }, 1500, 1000)).toBe('use-cache-and-refresh');
  });

  it('SqliteDemo: mở DB, lưu dữ liệu, tìm theo từ khóa', async () => {
    const user = userEvent.setup();
    await render(<SqliteDemo />);
    expect(await screen.findByText('SQLite sẵn sàng')).toBeOnTheScreen();
    await user.type(screen.getByLabelText('Tìm trong SQLite'), 'Query');
    expect(await screen.findByText('• TanStack Query cho người mới')).toBeOnTheScreen();
    expect(screen.queryByText('• Flexbox không khó')).not.toBeOnTheScreen();
  });

  it('adapter node:sqlite dùng được độc lập', async () => {
    const db = createNodeSqliteDb();
    await db.execAsync('CREATE TABLE t (x INTEGER)');
    await db.runAsync('INSERT INTO t (x) VALUES (?)', 7);
    expect(await db.getFirstAsync<{ x: number }>('SELECT x FROM t')).toEqual({ x: 7 });
  });
});
