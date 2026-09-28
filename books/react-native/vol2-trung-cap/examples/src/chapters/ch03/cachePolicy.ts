import { isFresh, type CachedPosts } from '@/storage/postsCache';

// Lời giải bài tập Chương 3: quyết định dùng cache hay tải lại.
// - không có cache           → 'fetch'
// - cache còn tươi (< TTL)   → 'use-cache'
// - cache cũ                 → 'use-cache-and-refresh' (hiện cũ trước, tải mới ở nền)
export type CacheDecision = 'fetch' | 'use-cache' | 'use-cache-and-refresh';

export function decideCache(cached: CachedPosts | null, now: number, ttlMs: number): CacheDecision {
  if (!cached || cached.posts.length === 0) return 'fetch';
  return isFresh(cached.savedAt, now, ttlMs) ? 'use-cache' : 'use-cache-and-refresh';
}
