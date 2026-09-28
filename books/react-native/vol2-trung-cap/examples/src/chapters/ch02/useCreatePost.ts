import { useMutation, useQueryClient } from '@tanstack/react-query';
import { createPost, postKeys } from '@/api/posts';
import type { Post } from '@/api/types';

// Lời giải bài tập Chương 2: useMutation + "optimistic update" (cập nhật lạc quan):
// hiện bài mới ngay, nếu server lỗi thì hoàn tác (rollback).
export function useCreatePost(limit: number) {
  const qc = useQueryClient();
  const key = postKeys.list(limit);

  return useMutation({
    mutationFn: (input: Pick<Post, 'title' | 'body' | 'userId'>) => createPost(input),
    onMutate: async (input) => {
      await qc.cancelQueries({ queryKey: key });
      const previous = qc.getQueryData<Post[]>(key);
      const optimistic: Post = { ...input, id: -Date.now() }; // id âm = tạm thời
      qc.setQueryData<Post[]>(key, (old = []) => [optimistic, ...old]);
      return { previous };
    },
    onError: (_err, _input, context) => {
      if (context?.previous) qc.setQueryData(key, context.previous);
    },
    onSettled: () => qc.invalidateQueries({ queryKey: key }),
  });
}
