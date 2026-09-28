import type { TextStatsResult } from './TextStats.types';

// Cài đặt bằng JavaScript — cùng quy ước với Swift/Kotlin: đếm từ theo khoảng trắng,
// đếm ký tự theo code point (Array.from tách đúng emoji như "👋" thành 1).
export function statsInJs(text: string): TextStatsResult {
  const words = text.trim() === '' ? 0 : text.trim().split(/\s+/).length;
  return { words, characters: Array.from(text).length };
}
