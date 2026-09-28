import { act, render, screen, userEvent } from '@testing-library/react-native';
import { Clock } from './Clock';
import { LikeButton } from './exercise.solution';

test('LikeButton bật/tắt và đổi số lượt thích', async () => {
  const user = userEvent.setup();
  await render(<LikeButton initialLikes={10} />);
  await user.press(screen.getByRole('button', { name: 'Thích' }));
  expect(screen.getByRole('button', { name: 'Bỏ thích' })).toHaveTextContent('❤️ 11');
  await user.press(screen.getByRole('button', { name: 'Bỏ thích' }));
  expect(screen.getByRole('button', { name: 'Thích' })).toHaveTextContent('🤍 10');
});

test('Bài 2: Clock dừng khi paused = true và chạy lại khi false', async () => {
  jest.useFakeTimers();
  jest.setSystemTime(new Date(2026, 0, 1, 8, 0, 0));
  const view = await render(<Clock paused />);
  await act(async () => {
    jest.advanceTimersByTime(3000);
  });
  expect(screen.getByLabelText('Đồng hồ')).toHaveTextContent('08:00:00');
  await view.rerender(<Clock paused={false} />);
  await act(async () => {
    jest.advanceTimersByTime(1000);
  });
  expect(screen.getByLabelText('Đồng hồ')).toHaveTextContent('08:00:04');
  jest.useRealTimers();
});
