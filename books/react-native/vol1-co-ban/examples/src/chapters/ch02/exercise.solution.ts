import type { Signal } from './signal';

// Lời giải bài tập Chương 2: createComputed — tương đương computed() của Angular.
// Tính lại khi một trong các signal nguồn thay đổi.
export interface ReadonlySignal<T> {
  get: () => T;
  subscribe: (listener: () => void) => () => void;
}

export function createComputed<T>(sources: Signal<unknown>[], compute: () => T): ReadonlySignal<T> {
  let value = compute();
  const listeners = new Set<() => void>();
  for (const s of sources) {
    s.subscribe(() => {
      const next = compute();
      if (Object.is(next, value)) return;
      value = next;
      listeners.forEach((l) => l());
    });
  }
  return {
    get: () => value,
    subscribe: (l) => {
      listeners.add(l);
      return () => listeners.delete(l);
    },
  };
}
