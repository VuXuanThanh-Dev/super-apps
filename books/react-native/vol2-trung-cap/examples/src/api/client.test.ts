import { POSTS, jsonResponse } from '@/test/fixtures';
import { ApiError, createApiClient } from './client';
import { fetchPosts } from './posts';

describe('createApiClient', () => {
  it('ghép baseUrl và trả JSON', async () => {
    const fetchImpl = jest.fn(async () => jsonResponse(POSTS));
    const client = createApiClient({ baseUrl: 'https://api.test', fetchImpl });
    await expect(fetchPosts(3, client)).resolves.toHaveLength(3);
    expect(fetchImpl).toHaveBeenCalledWith('https://api.test/posts?_limit=3', expect.objectContaining({ method: 'GET' }));
  });

  it('HTTP 404 → ApiError có status', async () => {
    const client = createApiClient({ baseUrl: 'x', fetchImpl: async () => jsonResponse({}, 404) });
    await expect(client.getJson('/nope')).rejects.toEqual(new ApiError('HTTP 404', 404));
  });

  it('lỗi mạng → ApiError status null', async () => {
    const client = createApiClient({
      baseUrl: 'x',
      fetchImpl: async () => {
        throw new TypeError('Network request failed');
      },
    });
    await expect(client.getJson('/a')).rejects.toMatchObject({ status: null, message: 'Không kết nối được máy chủ' });
  });

  it('quá thời gian → hủy request (AbortController)', async () => {
    jest.useFakeTimers();
    const fetchImpl = jest.fn(
      (_url: string, init?: RequestInit) =>
        new Promise<Response>((_resolve, reject) => {
          init?.signal?.addEventListener('abort', () => {
            const err = new Error('Aborted');
            err.name = 'AbortError';
            reject(err);
          });
        }),
    );
    const client = createApiClient({ baseUrl: 'x', timeoutMs: 500, fetchImpl: fetchImpl as unknown as typeof fetch });
    const promise = client.getJson('/slow');
    jest.advanceTimersByTime(500);
    await expect(promise).rejects.toMatchObject({ message: 'Hết thời gian chờ (timeout)' });
    jest.useRealTimers();
  });
});
