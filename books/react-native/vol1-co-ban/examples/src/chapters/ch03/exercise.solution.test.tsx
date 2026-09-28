import { render, screen, userEvent } from '@testing-library/react-native';
import { LikeButton } from './exercise.solution';

test('LikeButton bật/tắt và đổi số lượt thích', async () => {
  const user = userEvent.setup();
  await render(<LikeButton initialLikes={10} />);
  await user.press(screen.getByRole('button', { name: 'Thích' }));
  expect(screen.getByRole('button', { name: 'Bỏ thích' })).toHaveTextContent('❤️ 11');
  await user.press(screen.getByRole('button', { name: 'Bỏ thích' }));
  expect(screen.getByRole('button', { name: 'Thích' })).toHaveTextContent('🤍 10');
});
