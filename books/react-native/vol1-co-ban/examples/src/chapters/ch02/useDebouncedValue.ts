import { useEffect, useState } from 'react';

// RxJS: this.search$.pipe(debounceTime(300), distinctUntilChanged())
// React: một hook nhỏ với useEffect + setTimeout. Cleanup = unsubscribe.
export function useDebouncedValue<T>(value: T, delayMs = 300): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(timer); // chạy khi value đổi hoặc component bị hủy (ngOnDestroy)
  }, [value, delayMs]);
  return debounced;
}
