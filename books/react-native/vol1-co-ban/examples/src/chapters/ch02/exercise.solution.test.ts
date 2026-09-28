import { createComputed } from './exercise.solution';
import { createSignal } from './signal';

test('createComputed tính lại khi nguồn đổi', () => {
  const price = createSignal(100);
  const qty = createSignal(2);
  const total = createComputed([price, qty] as never, () => price.get() * qty.get());
  const listener = jest.fn();
  total.subscribe(listener);
  expect(total.get()).toBe(200);
  qty.set(3);
  expect(total.get()).toBe(300);
  expect(listener).toHaveBeenCalledTimes(1);
});
