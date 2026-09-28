import type { Post } from '@/api/types';

// Dữ liệu giả cho test (tự viết, cùng cấu trúc với JSONPlaceholder).
export const POSTS: Post[] = [
  { userId: 1, id: 1, title: 'Học React Native trong 30 ngày', body: 'Bắt đầu với Expo Go trên iPhone.' },
  { userId: 1, id: 2, title: 'Flexbox không khó', body: 'Mặc định flexDirection là column.' },
  { userId: 2, id: 3, title: 'TanStack Query cho người mới', body: 'Server state khác client state.' },
];

export function jsonResponse(data: unknown, status = 200): Response {
  return {
    ok: status >= 200 && status < 300,
    status,
    json: async () => data,
  } as Response;
}
