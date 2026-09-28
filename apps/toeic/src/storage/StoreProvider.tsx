import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import type { UserStore } from './types';

interface StoreContextValue {
  store: UserStore;
  /** increases after every change, so screens can reload their data */
  version: number;
  bump: () => void;
}

const StoreContext = createContext<StoreContextValue | null>(null);

export function StoreProvider({ store, children }: { store: UserStore; children: ReactNode }) {
  const [version, setVersion] = useState(0);
  const [ready, setReady] = useState(false);
  useEffect(() => {
    let alive = true;
    store
      .init()
      .catch((e: unknown) => console.warn('store init failed', e))
      .finally(() => alive && setReady(true));
    return () => {
      alive = false;
    };
  }, [store]);
  const bump = useCallback(() => setVersion((v) => v + 1), []);
  const value = useMemo(() => ({ store, version, bump }), [store, version, bump]);
  if (!ready) return null;
  return <StoreContext.Provider value={value}>{children}</StoreContext.Provider>;
}

export function useStore(): StoreContextValue {
  const ctx = useContext(StoreContext);
  if (!ctx) throw new Error('useStore must be used inside StoreProvider');
  return ctx;
}

/** Run an async query against the store and re-run it after any store change. */
export function useStoreQuery<T>(query: (store: UserStore) => Promise<T>, initial: T, deps: unknown[] = []): T {
  const { store, version } = useStore();
  const [value, setValue] = useState<T>(initial);
  useEffect(() => {
    let alive = true;
    query(store).then((v) => alive && setValue(v));
    return () => {
      alive = false;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [store, version, ...deps]);
  return value;
}
