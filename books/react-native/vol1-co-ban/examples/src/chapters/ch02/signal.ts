import { useSyncExternalStore } from 'react';

// Một "signal" tối giản để so sánh với Angular Signals.
// Angular: const count = signal(0); count.set(1); count();  computed(() => count() * 2)
export interface Signal<T> {
  get: () => T;
  set: (value: T) => void;
  update: (fn: (prev: T) => T) => void;
  subscribe: (listener: () => void) => () => void;
}

export function createSignal<T>(initial: T): Signal<T> {
  let value = initial;
  const listeners = new Set<() => void>();
  const set = (next: T) => {
    if (Object.is(next, value)) return; // giống Angular: không đổi thì không báo
    value = next;
    listeners.forEach((l) => l());
  };
  return {
    get: () => value,
    set,
    update: (fn) => set(fn(value)),
    subscribe: (listener) => {
      listeners.add(listener);
      return () => listeners.delete(listener);
    },
  };
}

// Hook cho component "đọc" signal và tự render lại khi signal đổi.
export function useSignal<T>(signal: Signal<T>): T {
  return useSyncExternalStore(signal.subscribe, signal.get, signal.get);
}
