import { render, screen } from '@testing-library/react-native';
import { RuntimeInfoCard } from './RuntimeInfoCard';
import { getRuntimeInfo } from './runtimeInfo';

describe('Tập 3 — Chương 1: New Architecture', () => {
  afterEach(() => {
    delete (globalThis as { HermesInternal?: unknown }).HermesInternal;
  });

  it('Jest chạy trên Node (không phải Hermes); TurboModule không có → giá trị dự phòng', () => {
    const info = getRuntimeInfo();
    expect(info.engine).toBe('khác');
    expect(info.deviceName).toMatch(/không có module NativeDeviceInfo/);
  });

  it('có HermesInternal → báo Hermes (giống trên iPhone)', () => {
    (globalThis as { HermesInternal?: unknown }).HermesInternal = {};
    expect(getRuntimeInfo().engine).toBe('Hermes');
  });

  it('hiển thị phiên bản React Native dạng major.minor.patch', async () => {
    await render(<RuntimeInfoCard />);
    // Lưu ý: trong Jest, Platform.constants là bản giả và trả về "1000.0.0";
    // trên iPhone với Expo SDK 57 sẽ là 0.86.x.
    expect(screen.getByLabelText('Phiên bản RN')).toHaveTextContent(/^React Native: \d+\.\d+\.\d+$/);
  });
});
