import AsyncStorage from '@react-native-async-storage/async-storage';
import { screen, userEvent } from '@testing-library/react-native';
import { renderRouter } from 'expo-router/testing-library';
import { asyncStoragePostsCache } from '@/storage/postsCache';
import { useFavorites } from '@/state/favorites';
import { POSTS, jsonResponse } from '@/test/fixtures';

// Mạng giả: expo-network luôn "có mạng"; fetch do từng test quyết định.
jest.mock('expo-network', () => ({
  useNetworkState: () => ({ isConnected: true, isInternetReachable: true }),
  addNetworkStateListener: () => ({ remove: () => {} }),
  getNetworkStateAsync: async () => ({ isConnected: true }),
}));

const fetchMock = jest.fn();
beforeEach(async () => {
  fetchMock.mockReset();
  globalThis.fetch = fetchMock as unknown as typeof fetch;
  await AsyncStorage.clear();
  useFavorites.getState().clear();
});

async function renderApp(initialUrl = '/') {
  const view = renderRouter('./src/app', { initialUrl });
  await view;
  return { getPathname: () => view.getPathname() };
}

describe('App Tập 2: Tin Đọc Sau', () => {
  it('tải bài viết từ mạng, mở chi tiết', async () => {
    fetchMock.mockResolvedValue(jsonResponse(POSTS));
    const app = await renderApp();
    const user = userEvent.setup();
    await user.press(await screen.findByLabelText('Mở Flexbox không khó'));
    expect(await screen.findByText('Mặc định flexDirection là column.')).toBeOnTheScreen();
    expect(app.getPathname()).toBe('/post/2');
    expect(fetchMock).toHaveBeenCalledTimes(1); // chi tiết dùng initialData, không gọi mạng thêm
  });

  it('mất mạng: hiện dữ liệu đã lưu trong cache', async () => {
    await asyncStoragePostsCache.save([POSTS[2]], new Date(2026, 8, 28, 8, 5).getTime());
    fetchMock.mockRejectedValue(new TypeError('Network request failed'));
    await renderApp();
    expect(await screen.findByText('Dữ liệu offline, lưu lúc 08:05 28/09')).toBeOnTheScreen();
    expect(screen.getByText('TanStack Query cho người mới')).toBeOnTheScreen();
  });

  it('mất mạng và chưa có cache: báo lỗi + nút Thử lại', async () => {
    fetchMock.mockRejectedValue(new TypeError('Network request failed'));
    await renderApp();
    expect(await screen.findByText('Không tải được bài viết: Không kết nối được máy chủ', {}, { timeout: 10_000 })).toBeOnTheScreen();
    expect(screen.getByRole('button', { name: 'Thử lại' })).toBeOnTheScreen();
  });

  it('yêu thích một bài → xuất hiện ở tab Yêu thích', async () => {
    fetchMock.mockResolvedValue(jsonResponse(POSTS));
    await renderApp();
    const user = userEvent.setup();
    const [firstHeart] = await screen.findAllByRole('button', { name: 'Yêu thích' });
    await user.press(firstHeart);
    expect(useFavorites.getState().ids).toEqual([1]);
    await user.press(screen.getByText('Yêu thích'));
    expect(await screen.findByLabelText('Mở Học React Native trong 30 ngày')).toBeOnTheScreen();
  });
});

describe('Tab Lab', () => {
  it('mở ví dụ Zustand', async () => {
    fetchMock.mockResolvedValue(jsonResponse(POSTS));
    const app = await renderApp('/lab');
    await userEvent.setup().press(await screen.findByText('Ch.1 — Zustand vs useReducer'));
    expect(await screen.findByLabelText('Số món')).toBeOnTheScreen();
    expect(app.getPathname()).toBe('/lab/ch01');
  });
});
