import { render, screen, userEvent } from '@testing-library/react-native';
import { useNetworkState } from 'expo-network';
import { Alert, type AlertButton } from 'react-native';
import { OfflineBanner } from '@/components/OfflineBanner';
import { ConfirmDeleteButton } from './ConfirmDeleteButton';

jest.mock('expo-network', () => ({ useNetworkState: jest.fn() }));

// Helper: bấm một nút trong Alert giả theo tên nút.
function pressAlertButton(spy: jest.SpyInstance, text: string) {
  const buttons = spy.mock.calls[0][2] as AlertButton[];
  buttons.find((b) => b.text === text)?.onPress?.();
}

describe('Tập 2 — Chương 6: kỹ thuật test', () => {
  it('Alert: bấm "Xóa" thì gọi onConfirm', async () => {
    const alertSpy = jest.spyOn(Alert, 'alert').mockImplementation(() => {});
    const onConfirm = jest.fn();
    const user = userEvent.setup();
    await render(<ConfirmDeleteButton itemName="Bài 1" onConfirm={onConfirm} />);

    await user.press(screen.getByRole('button', { name: 'Xóa Bài 1' }));
    expect(alertSpy).toHaveBeenCalledWith('Xóa?', 'Bài 1', expect.any(Array));

    pressAlertButton(alertSpy, 'Xóa');
    expect(onConfirm).toHaveBeenCalledTimes(1);
    alertSpy.mockRestore();
  });

  it('Alert: bấm "Hủy" thì không xóa', async () => {
    const alertSpy = jest.spyOn(Alert, 'alert').mockImplementation(() => {});
    const onConfirm = jest.fn();
    await render(<ConfirmDeleteButton itemName="Bài 2" onConfirm={onConfirm} />);
    await userEvent.setup().press(screen.getByRole('button', { name: 'Xóa Bài 2' }));
    pressAlertButton(alertSpy, 'Hủy');
    expect(onConfirm).not.toHaveBeenCalled();
    alertSpy.mockRestore();
  });

  it.each([
    [{ isConnected: false, isInternetReachable: false }, true],
    [{ isConnected: true, isInternetReachable: false }, true],
    [{ isConnected: true, isInternetReachable: true }, false],
    [{ isConnected: true, isInternetReachable: undefined }, false],
  ])('bài tập: OfflineBanner với %o → hiện = %p', async (state, visible) => {
    jest.mocked(useNetworkState).mockReturnValue(state as never);
    await render(<OfflineBanner />);
    const banner = screen.queryByRole('alert');
    if (visible) expect(banner).toBeOnTheScreen();
    else expect(banner).not.toBeOnTheScreen();
  });
});
