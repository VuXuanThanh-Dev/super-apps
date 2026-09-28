import { useQuery } from '@tanstack/react-query';
import { postKeys } from '@/api/posts';
import { loadPosts } from './loadPosts';

// Hook dùng TanStack Query: tự quản loading/error/cache/refetch.
// Giống một service trả Observable + async pipe, nhưng có sẵn cache và retry.
export function usePosts() {
  return useQuery({
    queryKey: postKeys.list(20),
    queryFn: () => loadPosts(),
    staleTime: 60_000, // 1 phút coi là "tươi", không gọi lại
  });
}
