import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

// Chương 1 (Tập 3): "spec" của một Turbo Native Module viết bằng TypeScript.
// Codegen đọc interface này để sinh code C++/ObjC/Java — JS và native luôn khớp kiểu.
// Module này KHÔNG có trong Expo Go → dùng get() (trả null) thay vì getEnforcing() (ném lỗi).
export interface Spec extends TurboModule {
  getDeviceName(): string; // hàm đồng bộ: gọi thẳng qua JSI, không qua "bridge" JSON
  getBatteryLevel(): Promise<number>;
}

export default TurboModuleRegistry.get<Spec>('NativeDeviceInfo');
