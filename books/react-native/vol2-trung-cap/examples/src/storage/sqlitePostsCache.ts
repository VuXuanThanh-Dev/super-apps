import type { Post } from '@/api/types';
import type { CachedPosts, PostsCache } from './postsCache';

// Phần nhỏ của API SQLiteDatabase (expo-sqlite) mà ta cần. Khai báo interface riêng giúp
// test được bằng một database khác (Node `node:sqlite`) mà không cần iPhone.
export interface SqlDb {
  execAsync(sql: string): Promise<void>;
  runAsync(sql: string, ...params: (string | number)[]): Promise<unknown>;
  getAllAsync<T>(sql: string, ...params: (string | number)[]): Promise<T[]>;
  getFirstAsync<T>(sql: string, ...params: (string | number)[]): Promise<T | null>;
}

export async function migrate(db: SqlDb): Promise<void> {
  await db.execAsync(`
    CREATE TABLE IF NOT EXISTS posts (
      id INTEGER PRIMARY KEY NOT NULL,
      user_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      body TEXT NOT NULL
    );
    CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY NOT NULL, value TEXT NOT NULL);
  `);
}

interface PostRow {
  id: number;
  user_id: number;
  title: string;
  body: string;
}

export function createSqlitePostsCache(db: SqlDb): PostsCache {
  return {
    async load(): Promise<CachedPosts | null> {
      const meta = await db.getFirstAsync<{ value: string }>('SELECT value FROM meta WHERE key = ?', 'savedAt');
      if (!meta) return null;
      const rows = await db.getAllAsync<PostRow>('SELECT id, user_id, title, body FROM posts ORDER BY id');
      return {
        savedAt: Number(meta.value),
        posts: rows.map((r) => ({ id: r.id, userId: r.user_id, title: r.title, body: r.body })),
      };
    },
    async save(posts: Post[], now = Date.now()) {
      // Luôn dùng tham số "?" — KHÔNG nối chuỗi SQL với dữ liệu (chống SQL injection).
      await db.execAsync('BEGIN');
      try {
        await db.runAsync('DELETE FROM posts');
        for (const p of posts) {
          await db.runAsync('INSERT INTO posts (id, user_id, title, body) VALUES (?, ?, ?, ?)', p.id, p.userId, p.title, p.body);
        }
        await db.runAsync('INSERT OR REPLACE INTO meta (key, value) VALUES (?, ?)', 'savedAt', String(now));
        await db.execAsync('COMMIT');
      } catch (e) {
        await db.execAsync('ROLLBACK');
        throw e;
      }
    },
    async clear() {
      await db.runAsync('DELETE FROM posts');
      await db.runAsync('DELETE FROM meta');
    },
  };
}

// Tìm kiếm ngay trong SQLite (điều AsyncStorage không làm được).
export function searchCachedPosts(db: SqlDb, keyword: string) {
  return db.getAllAsync<PostRow>('SELECT id, user_id, title, body FROM posts WHERE title LIKE ? ORDER BY id', `%${keyword}%`);
}
