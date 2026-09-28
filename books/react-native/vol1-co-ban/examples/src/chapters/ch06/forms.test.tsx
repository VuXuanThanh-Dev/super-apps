import { fireEvent, render, screen, userEvent } from '@testing-library/react-native';
import { SignUpForm } from './SignUpForm';
import { isValid, validateSignUp } from './validation';

describe('Chương 6 — form', () => {
  it('validateSignUp trả lỗi đúng từng trường', () => {
    expect(validateSignUp({ email: 'abc', password: 'short', confirm: 'x', acceptTerms: false })).toEqual({
      email: 'Email không hợp lệ',
      password: 'Mật khẩu cần ít nhất 8 ký tự',
      confirm: 'Mật khẩu nhập lại không khớp',
      acceptTerms: 'Bạn cần đồng ý điều khoản',
    });
    expect(isValid(validateSignUp({ email: 'a@b.vn', password: 'abc12345', confirm: 'abc12345', acceptTerms: true }))).toBe(true);
  });

  it('không hiện lỗi trước khi người dùng chạm vào form', async () => {
    await render(<SignUpForm onSubmit={jest.fn()} />);
    expect(screen.queryByText('Vui lòng nhập email')).not.toBeOnTheScreen();
  });

  it('gửi form hợp lệ', async () => {
    const onSubmit = jest.fn();
    const user = userEvent.setup();
    await render(<SignUpForm onSubmit={onSubmit} />);
    await user.type(screen.getByLabelText('Email'), 'nobin@vidu.vn');
    await user.type(screen.getByLabelText('Mật khẩu'), 'matkhau1');
    await user.type(screen.getByLabelText('Nhập lại mật khẩu'), 'matkhau1');
    await fireEvent(screen.getByLabelText('Đồng ý điều khoản'), 'valueChange', true);
    await user.press(screen.getByRole('button', { name: 'Đăng ký' }));
    expect(onSubmit).toHaveBeenCalledWith({ email: 'nobin@vidu.vn', password: 'matkhau1', confirm: 'matkhau1', acceptTerms: true });
  });

  it('bấm Đăng ký khi trống thì hiện tất cả lỗi', async () => {
    const onSubmit = jest.fn();
    const user = userEvent.setup();
    await render(<SignUpForm onSubmit={onSubmit} />);
    await user.press(screen.getByRole('button', { name: 'Đăng ký' }));
    expect(screen.getByText('Vui lòng nhập email')).toBeOnTheScreen();
    expect(screen.getByText('Bạn cần đồng ý điều khoản')).toBeOnTheScreen();
    expect(onSubmit).not.toHaveBeenCalled();
  });
});
