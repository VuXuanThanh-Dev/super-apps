import { api, type ApiClient } from './client';
import type { Post } from './types';

// Query key: "địa chỉ" của dữ liệu trong cache của TanStack Query.
export const postKeys = {
  all: ['posts'] as const,
  list: (limit: number) => ['posts', 'list', limit] as const,
  detail: (id: number) => ['posts', 'detail', id] as const,
};

export function fetchPosts(limit = 20, client: ApiClient = api): Promise<Post[]> {
  return client.getJson<Post[]>(`/posts?_limit=${limit}`);
}

export function fetchPost(id: number, client: ApiClient = api): Promise<Post> {
  return client.getJson<Post>(`/posts/${id}`);
}

export function createPost(input: Pick<Post, 'title' | 'body' | 'userId'>, client: ApiClient = api): Promise<Post> {
  return client.postJson<Post>('/posts', input);
}
