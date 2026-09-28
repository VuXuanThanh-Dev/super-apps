# Chương 2 — Lấy dữ liệu (data fetching): fetch và TanStack Query

## Mục tiêu

- Viết một "HttpClient" nhỏ trên `fetch`: baseUrl, timeout, lỗi rõ ràng.
- Dùng **TanStack Query**: `useQuery`, query key, `staleTime`, retry, refetch.
- Dùng `useMutation` với **optimistic update** (cập nhật lạc quan) và rollback.
- Kết nối TanStack Query với trạng thái mạng và vòng đời app trên React Native.
- Test bằng `fetch` giả.

## Giải thích đơn giản

React Native có sẵn `fetch` giống trình duyệt. Nhưng một màn hình thật cần nhiều hơn:
đang tải, lỗi, thử lại, cache, tải lại khi quay lại app... Trong Angular, bạn viết service +
`HttpClient` + RxJS + tự cache. Trong React, **TanStack Query** làm hết phần đó:

- Bạn đưa **query key** (địa chỉ cache, ví dụ `['posts', 'list', 20]`) và **query function** (hàm trả Promise).
- Hook trả về `{ data, isPending, isError, error, refetch, ... }`.
- Dữ liệu được cache; màn hình khác dùng cùng key sẽ **không gọi mạng lại**.

API dùng trong sách: **JSONPlaceholder** (`https://jsonplaceholder.typicode.com`), một REST API
giả miễn phí, trả `/posts` với các trường `userId, id, title, body`.

## Ví dụ

### 1. Client nhỏ trên fetch

`examples/src/api/client.ts` (trích):

```ts
export class ApiError extends Error {
  constructor(message: string, public readonly status: number | null) {
    super(message);
    this.name = 'ApiError';
  }
}

export function createApiClient({ baseUrl, timeoutMs = 10_000, fetchImpl }: ApiClientOptions): ApiClient {
  async function request<T>(path: string, init: RequestInit): Promise<T> {
    const doFetch = fetchImpl ?? fetch; // đọc fetch lúc gọi để test có thể thay global.fetch
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
  // ...
}
```

- `fetch` **không** ném lỗi khi HTTP 404/500 — phải tự kiểm tra `res.ok` (khác `HttpClient`).
- `fetch` không có timeout mặc định → dùng `AbortController`.
- Tham số `fetchImpl` = "inject" một fetch giả khi test (giống DI).

Query key và các hàm gọi API (`src/api/posts.ts`):

```ts
export const postKeys = {
  all: ['posts'] as const,
  list: (limit: number) => ['posts', 'list', limit] as const,
  detail: (id: number) => ['posts', 'detail', id] as const,
};

export function fetchPosts(limit = 20, client: ApiClient = api): Promise<Post[]> {
  return client.getJson<Post[]>(`/posts?_limit=${limit}`);
}
```

### 2. useQuery

`examples/src/chapters/ch02/PostsDemo.tsx`:

```tsx
export function PostsDemo({ limit = 5 }: { limit?: number }) {
  const query = useQuery({ queryKey: postKeys.list(limit), queryFn: () => fetchPosts(limit) });

  if (query.isPending) return <ActivityIndicator accessibilityLabel="Đang tải" />;
  if (query.isError)
    return (
      <View style={{ padding: 16, gap: 8 }}>
        <Text>Lỗi: {query.error.message}</Text>
        <Pressable accessibilityRole="button" onPress={() => query.refetch()}>
          <Text>Thử lại</Text>
        </Pressable>
      </View>
    );
  return (
    <View style={{ padding: 16, gap: 8 }}>
      {query.data.map((p) => <Text key={p.id}>• {p.title}</Text>)}
    </View>
  );
}
```

Sau khi kiểm tra `isPending` và `isError`, TypeScript biết chắc `query.data` có giá trị.

Layout gốc tạo **một** `QueryClient` cho cả app (`src/app/_layout.tsx`):

```tsx
const [queryClient] = useState(createQueryClient); // tạo đúng một lần
useEffect(() => setupReactNativeManagers(), []);
return <QueryClientProvider client={queryClient}>{/* Stack */}</QueryClientProvider>;
```

### 3. Test với fetch giả

```tsx
const fetchMock = jest.fn();
beforeEach(() => {
  fetchMock.mockReset();
  globalThis.fetch = fetchMock as unknown as typeof fetch;
});

it('lỗi → nút Thử lại gọi lại API', async () => {
  fetchMock.mockResolvedValueOnce(jsonResponse({}, 500)).mockResolvedValueOnce(jsonResponse(POSTS));
  const user = userEvent.setup();
  await renderWithProviders(<PostsDemo limit={3} />);
  expect(await screen.findByText('Lỗi: HTTP 500')).toBeOnTheScreen();
  await user.press(screen.getByRole('button', { name: 'Thử lại' }));
  expect(await screen.findByText('• Học React Native trong 30 ngày')).toBeOnTheScreen();
});
```

`renderWithProviders` (`src/test/renderWithProviders.tsx`) tạo một `QueryClient` **mới cho mỗi
test** với `retry: false` — đúng khuyến nghị trong hướng dẫn Testing của TanStack Query.

Kết quả (2026-09-28):

```text
PASS src/chapters/ch02/fetching.test.tsx
    ✓ hiện danh sách sau khi tải
    ✓ lỗi → nút Thử lại gọi lại API
    ✓ bài tập: optimistic update rồi rollback khi server lỗi
Tests:       3 passed, 3 total
PASS src/api/client.test.ts
  createApiClient
    ✓ ghép baseUrl và trả JSON
    ✓ HTTP 404 → ApiError có status
    ✓ lỗi mạng → ApiError status null
    ✓ quá thời gian → hủy request (AbortController)
```

## Đi sâu

### Mặc định quan trọng của TanStack Query

Theo trang "Important Defaults":

- Dữ liệu trong cache mặc định bị coi là **stale** (cũ) ngay → dễ refetch. Đặt `staleTime` để giảm gọi mạng.
- Query lỗi được **thử lại 3 lần** với độ trễ tăng dần (exponential backoff) trước khi báo lỗi.
- Query không còn ai dùng bị xóa khỏi cache sau **5 phút** (`gcTime`).

App mẫu đặt `retry: 2`, `staleTime: 30_000` (toàn cục) và `staleTime: 60_000` cho danh sách bài.
Vì có retry, test "mất mạng và chưa có cache" của app phải chờ lâu hơn (`findByText(…, {}, { timeout: 10_000 })`).

### React Native: mạng và foreground

Trên web, TanStack Query tự refetch khi có mạng lại và khi tab được focus. Trên RN, bạn phải nối
tay — theo trang "React Native" của TanStack Query. App mẫu làm trong `src/lib/queryClient.ts`:

```ts
onlineManager.setEventListener((setOnline) => {
  let initialised = false;
  const sub = Network.addNetworkStateListener((state) => {
    initialised = true;
    setOnline(!!state.isConnected);
  });
  Network.getNetworkStateAsync().then((state) => { if (!initialised) setOnline(!!state.isConnected); }).catch(() => {});
  return () => sub.remove();
});

const onAppStateChange = (status: AppStateStatus) => {
  if (Platform.OS !== 'web') focusManager.setFocused(status === 'active');
};
AppState.addEventListener('change', onAppStateChange);
```

`expo-network` có trong Expo Go SDK 57, không cần cài thêm native code.

### So với Angular

| Angular | TanStack Query |
|---|---|
| `http.get<Post[]>(url)` trả Observable | `queryFn: () => fetchPosts()` trả Promise |
| `shareReplay(1)` để cache | cache theo `queryKey`, tự động |
| `retry(3)` | `retry: 3` (mặc định) |
| `async` pipe + `*ngIf="data$ | async as data"` | `const { data, isPending } = useQuery(...)` |
| Interceptor thêm header | hàm `request()` trong client |

## Lỗi và bẫy thường gặp

- **Quên kiểm tra `res.ok`** → xử lý trang lỗi HTML như JSON.
- **Tạo `QueryClient` trong thân component** mà không có `useState` → mỗi lần render một cache mới.
- **Query key không chứa tham số** (`['posts']` cho mọi `limit`) → hiển thị nhầm dữ liệu.
- **Test dùng chung QueryClient** → test sau thấy cache của test trước.
- **Client "bắt" `fetch` lúc tạo** (`const f = fetch` ở cấp module) → test thay `globalThis.fetch`
  sau đó sẽ không có tác dụng. Vì vậy client đọc `fetch` **lúc gọi** (`fetchImpl ?? fetch` trong `request`).
- **HTTP (không S) trên iOS** bị App Transport Security chặn. Luôn dùng HTTPS.

## Tóm tắt

- `fetch` + client nhỏ: baseUrl, timeout, lỗi rõ ràng, inject được.
- TanStack Query quản cache/loading/error/retry; key là địa chỉ cache.
- Trên RN, nối `onlineManager` với `expo-network` và `focusManager` với `AppState`.

## Bài tập (có lời giải)

**Bài 1.** Viết hook `useCreatePost(limit)` dùng `useMutation`. Khi gọi `mutate`, bài mới phải hiện
**ngay** đầu danh sách; nếu server lỗi, danh sách trở lại như cũ. Viết test.

<details>
<summary>Lời giải</summary>

`examples/src/chapters/ch02/useCreatePost.ts`:

```ts
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
```

Test giữ Promise của `fetch` ở trạng thái chờ, kiểm tra bài mới đã ở đầu danh sách, rồi mới
`reject` để kiểm tra rollback (xem "bài tập: optimistic update rồi rollback khi server lỗi").
Lưu ý: JSONPlaceholder **không lưu thật** bài mới (API giả), nên sau `invalidateQueries` danh sách
trên máy thật sẽ trở về dữ liệu gốc.
</details>

**Bài 2.** Màn hình chi tiết `/post/[id]` không nên gọi mạng nếu bài đã có trong danh sách. Làm thế nào?

<details>
<summary>Lời giải</summary>

Dùng `initialData` lấy từ cache danh sách (`src/app/post/[id].tsx`):

```tsx
const list = usePosts();
const fromList = list.data?.posts.find((p) => p.id === postId);
const { data: post } = useQuery({
  queryKey: postKeys.detail(postId),
  queryFn: () => fetchPost(postId),
  initialData: fromList,
  enabled: Number.isFinite(postId),
});
```

Test tích hợp "tải bài viết từ mạng, mở chi tiết" trong `src/__tests__/app.test.tsx` mở màn hình
chi tiết rồi kiểm tra `expect(fetchMock).toHaveBeenCalledTimes(1)` — chỉ có một lần gọi mạng
(cho danh sách); chi tiết dùng `initialData`.
</details>

## Nguồn tham khảo (Sources)

Đã mở ngày 2026-09-28:

- TanStack Query — React Native: https://github.com/TanStack/query/blob/main/docs/framework/react/react-native.md
- TanStack Query — Important Defaults: https://github.com/TanStack/query/blob/main/docs/framework/react/guides/important-defaults.md
- TanStack Query — Query Keys: https://github.com/TanStack/query/blob/main/docs/framework/react/guides/query-keys.md
- TanStack Query — Mutations: https://github.com/TanStack/query/blob/main/docs/framework/react/guides/mutations.md
- TanStack Query — Testing: https://github.com/TanStack/query/blob/main/docs/framework/react/guides/testing.md
- React Native — Networking: https://github.com/facebook/react-native-website/blob/main/docs/network.md
- Expo — expo-network (SDK 57): https://github.com/expo/expo/blob/main/docs/pages/versions/v57.0.0/sdk/network.mdx
- JSONPlaceholder (README và data.json): https://github.com/typicode/jsonplaceholder
