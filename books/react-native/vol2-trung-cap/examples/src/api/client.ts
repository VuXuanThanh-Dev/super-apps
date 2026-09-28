// Một "HttpClient" nhỏ dựa trên fetch. Angular có HttpClient + interceptor;
// ở đây ta viết hàm bọc (wrapper) để: thêm baseUrl, timeout, và báo lỗi rõ ràng.

export class ApiError extends Error {
  constructor(
    message: string,
    public readonly status: number | null, // null = lỗi mạng/timeout (không có phản hồi)
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export interface ApiClientOptions {
  baseUrl: string;
  timeoutMs?: number;
  fetchImpl?: typeof fetch; // cho phép "inject" fetch giả trong test
}

export interface ApiClient {
  getJson<T>(path: string): Promise<T>;
  postJson<T>(path: string, body: unknown): Promise<T>;
}

export function createApiClient({ baseUrl, timeoutMs = 10_000, fetchImpl }: ApiClientOptions): ApiClient {
  async function request<T>(path: string, init: RequestInit): Promise<T> {
    const doFetch = fetchImpl ?? fetch; // đọc fetch lúc gọi (không phải lúc tạo) để test có thể thay global.fetch
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    try {
      const res = await doFetch(`${baseUrl}${path}`, {
        ...init,
        headers: { Accept: 'application/json', 'Content-Type': 'application/json', ...init.headers },
        signal: controller.signal,
      });
      if (!res.ok) throw new ApiError(`HTTP ${res.status}`, res.status);
      return (await res.json()) as T;
    } catch (e) {
      if (e instanceof ApiError) throw e;
      const aborted = e instanceof Error && e.name === 'AbortError';
      throw new ApiError(aborted ? 'Hết thời gian chờ (timeout)' : 'Không kết nối được máy chủ', null);
    } finally {
      clearTimeout(timer);
    }
  }

  return {
    getJson: (path) => request(path, { method: 'GET' }),
    postJson: (path, body) => request(path, { method: 'POST', body: JSON.stringify(body) }),
  };
}

export const api = createApiClient({ baseUrl: 'https://jsonplaceholder.typicode.com' });
