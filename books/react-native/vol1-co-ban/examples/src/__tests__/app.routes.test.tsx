import { act, screen, userEvent } from '@testing-library/react-native';
import { Alert, type AlertButton } from 'react-native';
import { renderRouter } from 'expo-router/testing-library';

// Lưu ý (expo-router 57 + RNTL 14): renderRouter() trả về một Promise đã được gắn thêm
// các hàm getPathname()... Nếu `return` thẳng Promise đó từ hàm async, JavaScript sẽ
// "mở" Promise và các hàm này bị mất. Vì vậy ta bọc chúng trong một object thường.
async function renderApp(initialUrl: string) {
  const view = renderRouter('./src/app', { initialUrl });
  await view;
  return { getPathname: () => view.getPathname() };
}

describe('App Việc Cần Làm (Expo Router)', () => {
  it('mở chi tiết khi bấm vào một việc', async () => {
    const app = await renderApp('/');
    const user = userEvent.setup();

    await user.press(await screen.findByLabelText('Mở Đọc chương Flexbox'));

    expect(await screen.findByText('Trạng thái: Chưa xong')).toBeOnTheScreen();
    expect(app.getPathname()).toBe('/task/seed-2');
  });

  it('thêm việc mới qua màn hình modal rồi quay về danh sách', async () => {
    const app = await renderApp('/');
    const user = userEvent.setup();

    await user.press(await screen.findByLabelText('Thêm việc'));
    expect(app.getPathname()).toBe('/task/new');

    await user.type(await screen.findByLabelText('Tiêu đề'), 'Viết test cho router');
    await user.press(screen.getByRole('button', { name: 'Thêm' }));

    expect(await screen.findByText('Viết test cho router')).toBeOnTheScreen();
    expect(app.getPathname()).toBe('/');
  });

  it('lọc "Đã xong" chỉ còn việc đã xong', async () => {
    await renderApp('/');
    const user = userEvent.setup();

    await user.press(await screen.findByRole('tab', { name: 'Đã xong' }));

    expect(screen.getByText('Cài Expo Go trên iPhone')).toBeOnTheScreen();
    expect(screen.queryByText('Đọc chương Flexbox')).not.toBeOnTheScreen();
  });

  it('màn hình thống kê tính phần trăm', async () => {
    await renderApp('/stats');
    expect(await screen.findByText('33%')).toBeOnTheScreen();
  });
});

describe('Tab Lab', () => {
  it('mở ví dụ Flexbox từ danh sách Lab', async () => {
    const app = await renderApp('/lab');
    const user = userEvent.setup();
    await user.press(await screen.findByText('Ch.4 — Flexbox playground'));
    expect(await screen.findByRole('button', { name: 'flexDirection: column' })).toBeOnTheScreen();
    expect(app.getPathname()).toBe('/lab/ch04');
  });

  it('id không tồn tại thì báo lỗi thân thiện', async () => {
    await renderApp('/lab/khong-co');
    expect(await screen.findByText('Không có ví dụ "khong-co"')).toBeOnTheScreen();
  });
});

describe('Bài tập Chương 7 và 8', () => {
  it('sửa tiêu đề qua /task/edit/[id]', async () => {
    const app = await renderApp('/task/seed-3');
    const user = userEvent.setup();
    await user.press(await screen.findByRole('button', { name: 'Sửa' }));
    expect(app.getPathname()).toBe('/task/edit/seed-3');
    const input = await screen.findByLabelText('Tiêu đề');
    expect(input).toHaveDisplayValue('Làm bài tập FlatList');
    await user.clear(input);
    await user.type(input, 'Làm bài tập SectionList');
    await user.press(screen.getByRole('button', { name: 'Cập nhật' }));
    expect(await screen.findByText('Làm bài tập SectionList')).toBeOnTheScreen();
    expect(app.getPathname()).toBe('/task/seed-3');
  });

  it('nút "Xóa việc đã xong" ở tab Thống kê', async () => {
    await renderApp('/stats');
    const user = userEvent.setup();
    await user.press(await screen.findByRole('button', { name: 'Xóa 1 việc đã xong' }));
    expect(await screen.findByText('0%')).toBeOnTheScreen();
    expect(screen.getByRole('button', { name: 'Xóa 0 việc đã xong' })).toBeDisabled();
  });
});

describe('Xóa việc (bài tập 2, Tập 2 Chương 6)', () => {
  it('xóa việc sau khi xác nhận trong Alert', async () => {
    const alertSpy = jest.spyOn(Alert, 'alert').mockImplementation(() => {});
    const app = await renderApp('/task/seed-2');
    await userEvent.setup().press(await screen.findByRole('button', { name: 'Xóa' }));
    const buttons = alertSpy.mock.calls[0][2] as AlertButton[];
    await act(async () => {
      buttons.find((b) => b.text === 'Xóa')?.onPress?.();
    });
    expect(app.getPathname()).toBe('/');
    expect(screen.queryByText('Đọc chương Flexbox')).not.toBeOnTheScreen();
    alertSpy.mockRestore();
  });
});
