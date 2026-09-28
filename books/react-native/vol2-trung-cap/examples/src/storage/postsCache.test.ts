import AsyncStorage from '@react-native-async-storage/async-storage';
import { POSTS } from '@/test/fixtures';
import { createNodeSqliteDb } from '@/test/nodeSqliteDb';
import { asyncStoragePostsCache, isFresh } from './postsCache';
import { createSqlitePostsCache, migrate, searchCachedPosts } from './sqlitePostsCache';

describe('asyncStoragePostsCache', () => {
  beforeEach(() => AsyncStorage.clear());

  it('lưu và đọc lại cùng thời điểm lưu', async () => {
    await asyncStoragePostsCache.save(POSTS, 1000);
    await expect(asyncStoragePostsCache.load()).resolves.toEqual({ posts: POSTS, savedAt: 1000 });
  });

  it('dữ liệu hỏng → null thay vì crash', async () => {
    await AsyncStorage.setItem('posts-cache-v1', '{hỏng');
    await expect(asyncStoragePostsCache.load()).resolves.toBeNull();
  });
});

describe('createSqlitePostsCache (chạy SQL thật bằng node:sqlite)', () => {
  it('migrate → save → load → search', async () => {
    const db = createNodeSqliteDb();
    await migrate(db);
    const cache = createSqlitePostsCache(db);
    expect(await cache.load()).toBeNull();
    await cache.save(POSTS, 42);
    expect(await cache.load()).toEqual({ posts: POSTS, savedAt: 42 });
    const found = await searchCachedPosts(db, 'Flexbox');
    expect(found.map((r) => r.id)).toEqual([2]);
  });

  it('save lần 2 thay thế toàn bộ dữ liệu cũ', async () => {
    const db = createNodeSqliteDb();
    await migrate(db);
    const cache = createSqlitePostsCache(db);
    await cache.save(POSTS, 1);
    await cache.save([POSTS[0]], 2);
    expect((await cache.load())?.posts).toHaveLength(1);
  });
});

test('isFresh theo TTL', () => {
  expect(isFresh(0, 59_000, 60_000)).toBe(true);
  expect(isFresh(0, 60_000, 60_000)).toBe(false);
});
