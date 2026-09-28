import type { Transport } from './logger';

// Lời giải bài tập Chương 7: không gửi cùng một lỗi nhiều lần trong một khoảng thời gian
// (tránh "bão lỗi" khi một màn hình lỗi lặp lại liên tục).
export function createDedupeTransport(inner: Transport, windowMs: number, now: () => number = Date.now): Transport {
  const lastSent = new Map<string, number>();
  return (report) => {
    const key = `${report.error.name}:${report.error.message}`;
    const t = now();
    const prev = lastSent.get(key);
    if (prev !== undefined && t - prev < windowMs) return;
    lastSent.set(key, t);
    inner(report);
  };
}
