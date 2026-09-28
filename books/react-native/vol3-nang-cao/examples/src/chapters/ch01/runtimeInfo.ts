import { Platform } from 'react-native';
import NativeDeviceInfo from './NativeDeviceInfoSpec';

// Tài liệu Hermes của RN: biến toàn cục HermesInternal có mặt khi app chạy bằng Hermes.
declare const global: { HermesInternal?: unknown };

export interface RuntimeInfo {
  engine: 'Hermes' | 'khác';
  os: string;
  reactNativeVersion: string;
  deviceName: string;
}

export function getRuntimeInfo(): RuntimeInfo {
  const v = Platform.constants.reactNativeVersion;
  return {
    engine: global.HermesInternal ? 'Hermes' : 'khác',
    os: Platform.OS,
    reactNativeVersion: `${v.major}.${v.minor}.${v.patch}`,
    deviceName: NativeDeviceInfo?.getDeviceName() ?? '(không có module NativeDeviceInfo — bình thường trong Expo Go)',
  };
}
