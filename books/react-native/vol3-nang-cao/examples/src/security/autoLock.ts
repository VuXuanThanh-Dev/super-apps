// Lời giải bài tập Chương 8: tự khóa khi không dùng quá `timeoutMs`
// hoặc khi app ở nền lâu hơn `timeoutMs`.
export function shouldAutoLock(lastActiveAt: number, now: number, timeoutMs: number): boolean {
  return now - lastActiveAt >= timeoutMs;
}
