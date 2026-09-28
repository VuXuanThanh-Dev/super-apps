import NativeTextStats from './src/TextStatsModule';
import { reverseInJs, statsInJs } from './src/jsFallback';
import type { TextStatsResult } from './src/TextStats.types';

export type { TextStatsResult } from './src/TextStats.types';
export { reverseInJs, statsInJs } from './src/jsFallback';

export type StatsSource = 'native' | 'js';

// API công khai: dùng native nếu có (development build), nếu không thì dùng JS (Expo Go, web, test).
export function textStats(text: string): TextStatsResult & { source: StatsSource } {
  if (NativeTextStats) return { ...NativeTextStats.stats(text), source: 'native' };
  return { ...statsInJs(text), source: 'js' };
}

export const isNativeAvailable = (): boolean => NativeTextStats != null;

export function reverseText(text: string): string {
  return NativeTextStats ? NativeTextStats.reverse(text) : reverseInJs(text);
}
