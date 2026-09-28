import { render, screen, userEvent } from '@testing-library/react-native';
import { HelloExpo } from './HelloExpo';

test('bấm nút thì tăng bộ đếm', async () => {
  const user = userEvent.setup();
  await render(<HelloExpo />);
  expect(screen.getByText('Bạn đang chạy trên: ios')).toBeOnTheScreen(); // jest-expo mặc định giả lập iOS
  await user.press(screen.getByRole('button', { name: 'Đã bấm 0 lần' }));
  expect(screen.getByRole('button', { name: 'Đã bấm 1 lần' })).toBeOnTheScreen();
});
