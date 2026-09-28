import { act, renderHook, screen, userEvent } from '@testing-library/react-native';
import { postKeys } from '@/api/posts';
import type { Post } from '@/api/types';
import { POSTS, jsonResponse } from '@/test/fixtures';
import { createTestQueryClient, renderWithProviders } from '@/test/renderWithProviders';
import { QueryClientProvider } from '@tanstack/react-query';
import type { ReactNode } from 'react';
import { PostsDemo } from './PostsDemo';
import { useCreatePost } from './useCreatePost';

const fetchMock = jest.fn();
beforeEach(() => {
  fetchMock.mockReset();
  globalThis.fetch = fetchMock as unknown as typeof fetch;
});

describe('Tập 2 — Chương 2: data fetching', () => {
  it('hiện danh sách sau khi tải', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse(POSTS));
    await renderWithProviders(<PostsDemo limit={3} />);
    expect(screen.getByLabelText('Đang tải')).toBeOnTheScreen();
    expect(await screen.findByText('• Flexbox không khó')).toBeOnTheScreen();
    expect(fetchMock).toHaveBeenCalledWith('https://jsonplaceholder.typicode.com/posts?_limit=3', expect.anything());
  });

  it('lỗi → nút Thử lại gọi lại API', async () => {
    fetchMock.mockResolvedValueOnce(jsonResponse({}, 500)).mockResolvedValueOnce(jsonResponse(POSTS));
    const user = userEvent.setup();
    await renderWithProviders(<PostsDemo limit={3} />);
    expect(await screen.findByText('Lỗi: HTTP 500')).toBeOnTheScreen();
    await user.press(screen.getByRole('button', { name: 'Thử lại' }));
    expect(await screen.findByText('• Học React Native trong 30 ngày')).toBeOnTheScreen();
  });

  it('bài tập: optimistic update rồi rollback khi server lỗi', async () => {
    const client = createTestQueryClient();
    client.setQueryData<Post[]>(postKeys.list(3), POSTS);
    let rejectRequest: (e: Error) => void = () => {};
    fetchMock.mockImplementationOnce(() => new Promise((_res, rej) => (rejectRequest = rej)));
    fetchMock.mockResolvedValue(jsonResponse(POSTS)); // cho lần refetch sau onSettled
    const wrapper = ({ children }: { children: ReactNode }) => <QueryClientProvider client={client}>{children}</QueryClientProvider>;
    const { result } = await renderHook(() => useCreatePost(3), { wrapper });

    await act(async () => {
      result.current.mutate({ title: 'Bài mới', body: '...', userId: 1 });
    });
    expect(client.getQueryData<Post[]>(postKeys.list(3))?.[0].title).toBe('Bài mới'); // hiện ngay

    await act(async () => {
      rejectRequest(new TypeError('Network request failed'));
    });
    expect(client.getQueryData<Post[]>(postKeys.list(3))?.[0].title).toBe(POSTS[0].title); // đã hoàn tác
  });
});
