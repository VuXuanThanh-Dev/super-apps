import { render, screen, userEvent } from '@testing-library/react-native';
import { HelloWithReset } from './exercise.solution';

test('nút Đặt lại bị vô hiệu khi 0 và đưa bộ đếm về 0', async () => {
  const user = userEvent.setup();
  await render(<HelloWithReset />);
  expect(screen.getByRole('button', { name: 'Đặt lại' })).toBeDisabled();
  await user.press(screen.getByRole('button', { name: 'Đã bấm 0 lần' }));
  expect(screen.getByRole('button', { name: 'Đặt lại' })).toBeEnabled();
  await user.press(screen.getByRole('button', { name: 'Đặt lại' }));
  expect(screen.getByRole('button', { name: 'Đã bấm 0 lần' })).toBeOnTheScreen();
});
