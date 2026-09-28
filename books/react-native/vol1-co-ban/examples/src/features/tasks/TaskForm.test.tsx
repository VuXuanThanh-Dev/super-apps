import { render, screen, userEvent } from '@testing-library/react-native';
import { TaskForm } from './TaskForm';

describe('TaskForm', () => {
  it('không gọi onSubmit khi tiêu đề rỗng và hiện lỗi', async () => {
    const onSubmit = jest.fn();
    const user = userEvent.setup();
    await render(<TaskForm onSubmit={onSubmit} />);

    await user.press(screen.getByRole('button', { name: 'Lưu' }));

    expect(onSubmit).not.toHaveBeenCalled();
    expect(screen.getByText('Tiêu đề không được để trống')).toBeOnTheScreen();
  });

  it('gửi dữ liệu hợp lệ', async () => {
    const onSubmit = jest.fn();
    const user = userEvent.setup();
    await render(<TaskForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText('Tiêu đề'), 'Học Expo Router');
    await user.press(screen.getByRole('radio', { name: 'Cao' }));
    await user.press(screen.getByRole('button', { name: 'Lưu' }));

    expect(onSubmit).toHaveBeenCalledWith({ title: 'Học Expo Router', note: '', priority: 'high' });
  });
});
