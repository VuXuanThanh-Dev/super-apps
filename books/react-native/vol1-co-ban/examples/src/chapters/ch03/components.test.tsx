import { act, render, screen, userEvent } from '@testing-library/react-native';
import { Clock, formatTime } from './Clock';
import { ComponentsDemo } from './ComponentsDemo';
import { Counter } from './Counter';

describe('Chương 3 — component, props, state', () => {
  it('Counter tăng/giảm theo step', async () => {
    const user = userEvent.setup();
    await render(<Counter step={5} />);
    await user.press(screen.getByRole('button', { name: 'Tăng' }));
    await user.press(screen.getByRole('button', { name: 'Tăng' }));
    await user.press(screen.getByRole('button', { name: 'Giảm' }));
    expect(screen.getByLabelText('Giá trị')).toHaveTextContent('5');
  });

  it('ProfileCard đổi nhãn nút khi bấm Theo dõi', async () => {
    const user = userEvent.setup();
    await render(<ComponentsDemo />);
    await user.press(screen.getByRole('button', { name: 'Theo dõi' }));
    expect(screen.getByRole('button', { name: 'Đang theo dõi' })).toBeOnTheScreen();
  });

  it('formatTime thêm số 0 phía trước', () => {
    expect(formatTime(new Date(2026, 0, 1, 9, 5, 3))).toBe('09:05:03');
  });

  it('Clock tự cập nhật mỗi giây và dọn interval khi unmount', async () => {
    jest.useFakeTimers();
    jest.setSystemTime(new Date(2026, 0, 1, 8, 0, 0));
    const clearSpy = jest.spyOn(globalThis, 'clearInterval');
    const view = await render(<Clock />);
    expect(screen.getByLabelText('Đồng hồ')).toHaveTextContent('08:00:00');
    await act(async () => {
      jest.advanceTimersByTime(2000);
    });
    expect(screen.getByLabelText('Đồng hồ')).toHaveTextContent('08:00:02');
    await view.unmount();
    expect(clearSpy).toHaveBeenCalled(); // cleanup của useEffect đã chạy
    clearSpy.mockRestore();
    jest.useRealTimers();
  });
});
