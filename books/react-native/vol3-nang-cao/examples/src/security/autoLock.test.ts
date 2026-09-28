import { shouldAutoLock } from './autoLock';

test('bài tập Chương 8: shouldAutoLock', () => {
  expect(shouldAutoLock(0, 59_999, 60_000)).toBe(false);
  expect(shouldAutoLock(0, 60_000, 60_000)).toBe(true);
});
