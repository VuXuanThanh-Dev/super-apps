import { render, screen, userEvent } from '@testing-library/react-native';
import * as Haptics from 'expo-haptics';
import * as ImagePicker from 'expo-image-picker';
import * as Location from 'expo-location';
import { AvatarPicker } from './AvatarPicker';
import { formatCoords } from './formatCoords';
import { LocationCard } from './LocationCard';
import { nextPermissionAction } from './permissions';

// Module native được thay bằng jest.fn() — ta điều khiển kết quả trả về.
jest.mock('expo-location', () => ({
  Accuracy: { Balanced: 3 },
  getForegroundPermissionsAsync: jest.fn(),
  requestForegroundPermissionsAsync: jest.fn(),
  getCurrentPositionAsync: jest.fn(),
}));
jest.mock('expo-image-picker', () => ({ launchImageLibraryAsync: jest.fn() }));
jest.mock('expo-haptics', () => ({
  impactAsync: jest.fn(),
  notificationAsync: jest.fn(),
  ImpactFeedbackStyle: { Light: 'light' },
  NotificationFeedbackType: { Success: 'success' },
}));

const loc = jest.mocked(Location);
beforeEach(() => jest.clearAllMocks()); // xóa số lần gọi giữa các test

describe('Tập 2 — Chương 5: device APIs', () => {
  it('nextPermissionAction', () => {
    expect(nextPermissionAction('granted', false)).toBe('use');
    expect(nextPermissionAction('undetermined', true)).toBe('ask');
    expect(nextPermissionAction('denied', true)).toBe('ask');
    expect(nextPermissionAction('denied', false)).toBe('open-settings');
  });

  it('bài tập: formatCoords', () => {
    expect(formatCoords(10.77689, 106.70092)).toBe('10,7769° B, 106,7009° Đ');
    expect(formatCoords(-33.8688, -70.5)).toBe('33,8688° N, 70,5000° T');
  });

  it('LocationCard: xin quyền lần đầu rồi hiện tọa độ', async () => {
    loc.getForegroundPermissionsAsync.mockResolvedValue({ status: 'undetermined', canAskAgain: true } as never);
    loc.requestForegroundPermissionsAsync.mockResolvedValue({ status: 'granted', canAskAgain: true } as never);
    loc.getCurrentPositionAsync.mockResolvedValue({ coords: { latitude: 21.0285, longitude: 105.8542 } } as never);
    const user = userEvent.setup();
    await render(<LocationCard />);
    await user.press(screen.getByRole('button', { name: '📍 Lấy vị trí của tôi' }));
    expect(await screen.findByLabelText('Tọa độ')).toHaveTextContent('21,0285° B, 105,8542° Đ');
    expect(loc.requestForegroundPermissionsAsync).toHaveBeenCalledTimes(1);
  });

  it('LocationCard: đã từ chối vĩnh viễn → gợi ý mở Cài đặt', async () => {
    loc.getForegroundPermissionsAsync.mockResolvedValue({ status: 'denied', canAskAgain: false } as never);
    const user = userEvent.setup();
    await render(<LocationCard />);
    await user.press(screen.getByRole('button', { name: '📍 Lấy vị trí của tôi' }));
    expect(await screen.findByText('Bạn đã tắt quyền vị trí. Mở Cài đặt')).toBeOnTheScreen();
    expect(loc.getCurrentPositionAsync).not.toHaveBeenCalled();
  });

  it('AvatarPicker: chọn ảnh xong thì hiện ảnh và rung', async () => {
    jest.mocked(ImagePicker.launchImageLibraryAsync).mockResolvedValue({
      canceled: false,
      assets: [{ uri: 'file:///anh.jpg' }],
    } as never);
    const user = userEvent.setup();
    await render(<AvatarPicker />);
    await user.press(screen.getByRole('button', { name: '🖼️ Chọn ảnh đại diện' }));
    expect(await screen.findByLabelText('Ảnh đại diện')).toHaveProp('source', { uri: 'file:///anh.jpg' });
    expect(Haptics.notificationAsync).toHaveBeenCalledWith('success');
  });
});
