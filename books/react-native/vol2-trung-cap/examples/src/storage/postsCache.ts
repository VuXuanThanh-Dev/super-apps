import AsyncStorage from '@react-native-async-storage/async-storage';
import type { Post } from '@/api/types';

// "Repository" cho cache bài viết. Hai cách cài đặt cùng một interface:
// AsyncStorage (key-value, đơn giản) và SQLite (có truy vấn). Giống việc có 2 class
// cùng implement một abstract class rồi chọn qua DI trong Angular.
export interface CachedPosts {
  posts: Post[];
  savedAt: number; // epoch ms
}

export interface PostsCache {
  load(): Promise<CachedPosts | null>;
  save(posts: Post[], now?: number): Promise<void>;
  clear(): Promise<void>;
}

const KEY = 'posts-cache-v1';

export const asyncStoragePostsCache: PostsCache = {
  async load() {
    const raw = await AsyncStorage.getItem(KEY);
    if (!raw) return null;
    try {
      return JSON.parse(raw) as CachedPosts;
    } catch {
      return null; // dữ liệu hỏng → coi như chưa có cache
    }
  },
  async save(posts, now = Date.now()) {
    await AsyncStorage.setItem(KEY, JSON.stringify({ posts, savedAt: now } satisfies CachedPosts));
  },
  async clear() {
    await AsyncStorage.removeItem(KEY);
  },
};

// Kiểm tra cache còn "tươi" không (TTL = time to live).
export function isFresh(savedAt: number, now: number, ttlMs: number): boolean {
  return now - savedAt < ttlMs;
}
