import { act, screen, userEvent } from '@testing-library/react-native';
import { renderRouter } from 'expo-router/testing-library';
import { resetNotesRepositoryForTests } from '@/notes/db';
import { useAuth } from '@/state/auth';
import { useNotes } from '@/state/notes';
import { secureStoreMock } from '@/test/mockSecureStore';

/* eslint-disable @typescript-eslint/no-require-imports -- jest.mock factory phải dùng require */
jest.mock('expo-secure-store', () => require('@/test/mockSecureStore').secureStoreMock);
jest.mock('expo-crypto', () => ({
  CryptoDigestAlgorithm: { SHA256: 'SHA-256' },
  digestStringAsync: async (_alg: string, text: string) => require('node:crypto').createHash('sha256').update(text).digest('hex'),
  getRandomBytes: (n: number) => Uint8Array.from({ length: n }, (_, i) => i),
}));
jest.mock('expo-sqlite', () => ({
  openDatabaseAsync: async () => require('@/test/nodeSqliteDb').createNodeSqliteDb(),
}));
/* eslint-enable @typescript-eslint/no-require-imports */

beforeEach(async () => {
  secureStoreMock.__clear();
  resetNotesRepositoryForTests(); // mỗi test một database mới
  useNotes.getState().reset();
  useAuth.setState({ status: 'loading', lock: { failedAttempts: 0, lockedUntil: null } });
});

async function renderApp(initialUrl = '/') {
  const view = renderRouter('./src/app', { initialUrl });
  await view;
  return { getPathname: () => view.getPathname() };
}

async function createPin(user: ReturnType<typeof userEvent.setup>, pin = '2580') {
  await user.type(await screen.findByLabelText('Mã PIN'), pin);
  await user.type(screen.getByLabelText('Nhập lại mã PIN'), pin);
  await user.press(screen.getByRole('button', { name: 'Tạo PIN' }));
}

describe('App Tập 3: Sổ Ghi Chú Bảo Mật', () => {
  it('lần đầu: tạo PIN → vào danh sách ghi chú', async () => {
    const app = await renderApp();
    const user = userEvent.setup();
    expect(await screen.findByText('Tạo mã PIN (4–6 chữ số)')).toBeOnTheScreen();
    await createPin(user);
    expect(await screen.findByText('Chưa có ghi chú.')).toBeOnTheScreen();
    expect(app.getPathname()).toBe('/');
  });

  it('PIN yếu bị từ chối', async () => {
    await renderApp();
    const user = userEvent.setup();
    await createPin(user, '1234');
    expect(await screen.findByText('PIN không được là dãy số liên tiếp')).toBeOnTheScreen();
  });

  it('thêm, sửa, xóa ghi chú (lưu trong SQLite)', async () => {
    await renderApp();
    const user = userEvent.setup();
    await createPin(user);
    await user.press(await screen.findByLabelText('Thêm ghi chú'));
    await user.type(await screen.findByLabelText('Tiêu đề'), 'Mật khẩu wifi');
    await user.type(screen.getByLabelText('Nội dung'), 'nhà-riêng-123');
    await user.press(screen.getByRole('button', { name: 'Lưu' }));
    expect(await screen.findByLabelText('Mở Mật khẩu wifi')).toBeOnTheScreen();

    await user.press(screen.getByLabelText('Mở Mật khẩu wifi'));
    const title = await screen.findByLabelText('Tiêu đề');
    await user.clear(title);
    await user.type(title, 'Wifi nhà');
    await user.press(screen.getByRole('button', { name: 'Lưu' }));
    expect(await screen.findByLabelText('Mở Wifi nhà')).toBeOnTheScreen();

    await user.press(screen.getByLabelText('Mở Wifi nhà'));
    await user.press(await screen.findByRole('button', { name: 'Xóa' }));
    expect(await screen.findByText('Chưa có ghi chú.')).toBeOnTheScreen();
  });

  it('khóa lại → nhập sai → nhập đúng', async () => {
    await renderApp();
    const user = userEvent.setup();
    await createPin(user);
    await screen.findByText('Chưa có ghi chú.');
    await act(async () => useAuth.getState().lockNow()); // như khi app xuống nền
    await user.type(await screen.findByLabelText('Mã PIN'), '0000');
    await user.press(screen.getByRole('button', { name: 'Mở khóa' }));
    expect(await screen.findByText('PIN không đúng')).toBeOnTheScreen();
    await user.type(screen.getByLabelText('Mã PIN'), '2580');
    await user.press(screen.getByRole('button', { name: 'Mở khóa' }));
    expect(await screen.findByText('Chưa có ghi chú.')).toBeOnTheScreen();
  });

  it('deep link vào ghi chú khi đang khóa → chỉ thấy màn hình khóa (Protected route)', async () => {
    await useAuth.getState().setPin('2580');
    useAuth.setState({ status: 'loading' });
    const app = await renderApp('/note/abc');
    expect(await screen.findByText('Nhập mã PIN để mở')).toBeOnTheScreen();
    expect(screen.queryByLabelText('Nội dung')).not.toBeOnTheScreen();
    expect(app.getPathname()).toBe('/lock');
  });

  it('Error Boundary bắt lỗi từ nút "Thử lỗi" trong Cài đặt', async () => {
    const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
    const warnSpy = jest.spyOn(console, 'warn').mockImplementation(() => {});
    await renderApp();
    const user = userEvent.setup();
    await createPin(user);
    await user.press(await screen.findByLabelText('Cài đặt'));
    await user.press(await screen.findByRole('button', { name: '💥 Thử lỗi (Error Boundary)' }));
    expect(await screen.findByText('Lỗi thử nghiệm từ màn hình Cài đặt')).toBeOnTheScreen();
    expect(warnSpy).toHaveBeenCalledWith(expect.stringContaining('[monitoring] Error: Lỗi thử nghiệm'), expect.anything());
    consoleSpy.mockRestore();
    warnSpy.mockRestore();
  });
});
