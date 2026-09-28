import { NativeModule, requireOptionalNativeModule } from 'expo';
import type { TextStatsResult } from './TextStats.types';

declare class TextStatsNativeModule extends NativeModule<Record<string, never>> {
  platform: string;
  stats(text: string): TextStatsResult;
}

// requireOptionalNativeModule trả về null khi module native không có (ví dụ trong Expo Go),
// thay vì ném lỗi như requireNativeModule. Nhờ vậy app vẫn chạy trong Expo Go.
export default requireOptionalNativeModule<TextStatsNativeModule>('TextStats');
