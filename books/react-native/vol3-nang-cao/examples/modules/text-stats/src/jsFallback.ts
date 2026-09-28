import type { TextStatsResult } from './TextStats.types';

// Cài đặt bằng JavaScript — cùng quy ước với Swift/Kotlin: đếm từ theo khoảng trắng,
// đếm ký tự theo code point (Array.from tách đúng emoji như "👋" thành 1).
export function statsInJs(text: string): TextStatsResult {
  const words = text.trim() === '' ? 0 : text.trim().split(/\s+/).length;
  return { words, characters: Array.from(text).length };
}

// Lời giải bài tập: đảo chuỗi theo code point — "ab👋" → "👋ba" (không làm vỡ emoji).
export function reverseInJs(text: string): string {
  return Array.from(text).reverse().join('');
}
