import { ApiError } from '@/api/client';
import type { CachedPosts, PostsCache } from '@/storage/postsCache';
import { POSTS } from '@/test/fixtures';
import { loadPosts } from './loadPosts';

function memoryCache(initial: CachedPosts | null = null): PostsCache {
  let value = initial;
  return {
    load: async () => value,
    save: async (posts, now = 0) => {
      value = { posts, savedAt: now };
    },
    clear: async () => {
      value = null;
    },
  };
}

describe('loadPosts (network-first, cache fallback)', () => {
  it('có mạng: trả dữ liệu mạng và lưu cache', async () => {
    const cache = memoryCache();
    const r = await loadPosts({ fetcher: async () => POSTS, cache, now: () => 5 });
    expect(r).toEqual({ posts: POSTS, source: 'network', savedAt: 5 });
    expect(await cache.load()).toEqual({ posts: POSTS, savedAt: 5 });
  });

  it('mất mạng: dùng cache', async () => {
    const cache = memoryCache({ posts: [POSTS[0]], savedAt: 1 });
    const r = await loadPosts({ fetcher: async () => Promise.reject(new ApiError('offline', null)), cache });
    expect(r.source).toBe('cache');
    expect(r.posts).toHaveLength(1);
  });

  it('mất mạng và chưa có cache: ném lỗi gốc', async () => {
    const err = new ApiError('offline', null);
    await expect(loadPosts({ fetcher: async () => Promise.reject(err), cache: memoryCache() })).rejects.toBe(err);
  });
});
