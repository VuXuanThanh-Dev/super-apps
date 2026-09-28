import { fetchPosts } from '@/api/posts';
import type { Post } from '@/api/types';
import { asyncStoragePostsCache, type PostsCache } from '@/storage/postsCache';

export interface PostsResult {
  posts: Post[];
  source: 'network' | 'cache';
  savedAt: number;
}

// Chiến lược "network-first, cache fallback":
// 1) thử gọi mạng → thành công thì lưu cache;
// 2) lỗi mạng → đọc cache; không có cache thì ném lỗi gốc.
export async function loadPosts(
  deps: { fetcher?: () => Promise<Post[]>; cache?: PostsCache; now?: () => number } = {},
): Promise<PostsResult> {
  const { fetcher = () => fetchPosts(20), cache = asyncStoragePostsCache, now = Date.now } = deps;
  try {
    const posts = await fetcher();
    const savedAt = now();
    await cache.save(posts, savedAt);
    return { posts, source: 'network', savedAt };
  } catch (error) {
    const cached = await cache.load();
    if (cached) return { ...cached, source: 'cache' };
    throw error;
  }
}
