import { act, render, screen, userEvent } from '@testing-library/react-native';
import { AnimationDemo } from './AnimationDemo';
import { FadeInView } from './FadeInView';
import { ShakeOnError } from './ShakeOnError';
import { Animated, Text } from 'react-native';

describe('Tập 2 — Chương 4: animation', () => {
  it('FadeInView: bắt đầu opacity 0 và chạy Animated.timing tới 1 bằng native driver', async () => {
    // Với useNativeDriver: true, khung hình chạy trên UI thread (native) nên Jest không "thấy"
    // opacity đổi dần. Ta kiểm tra: giá trị đầu, và cấu hình animation được gửi đi.
    const timingSpy = jest.spyOn(Animated, 'timing');
    await render(
      <FadeInView duration={300}>
        <Text>Xin chào</Text>
      </FadeInView>,
    );
    expect(screen.getByTestId('fade')).toHaveStyle({ opacity: 0 });
    expect(timingSpy).toHaveBeenCalledWith(expect.anything(), { toValue: 1, duration: 300, useNativeDriver: true });
    timingSpy.mockRestore();
  });

  it('bài tập: ShakeOnError lệch sang trái rồi về 0', async () => {
    jest.useFakeTimers();
    const view = await render(<ShakeOnError error={null} />);
    expect(screen.getByTestId('shake')).toHaveAnimatedStyle({ transform: [{ translateX: 0 }] });
    await view.rerender(<ShakeOnError error="Sai mật khẩu" />);
    await act(async () => {
      jest.advanceTimersByTime(50);
    });
    expect(screen.getByTestId('shake')).toHaveAnimatedStyle({ transform: [{ translateX: -10 }] });
    await act(async () => {
      jest.advanceTimersByTime(300);
    });
    expect(screen.getByTestId('shake')).toHaveAnimatedStyle({ transform: [{ translateX: 0 }] });
    jest.useRealTimers();
  });

  it('layout animation: thêm và xóa phần tử', async () => {
    const user = userEvent.setup();
    await render(<AnimationDemo />);
    await user.press(screen.getByRole('button', { name: '＋ Thêm' }));
    expect(screen.getByText('Mục 4 (bấm để xóa)')).toBeOnTheScreen();
    await user.press(screen.getByRole('button', { name: 'Mục 1 (bấm để xóa)' }));
    expect(screen.queryByText('Mục 1 (bấm để xóa)')).not.toBeOnTheScreen();
  });
});
