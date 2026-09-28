import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { useColorScheme } from 'react-native';
import { useStore } from '@/storage/StoreProvider';
import { resolvePalette, type Palette, type ThemePreference } from './colors';

interface ThemeValue {
  palette: Palette;
  scheme: 'light' | 'dark';
  preference: ThemePreference;
  setPreference: (p: ThemePreference) => void;
}

const ThemeContext = createContext<ThemeValue | null>(null);
export const THEME_KEY = 'theme';

export function ThemeProvider({ children }: { children: ReactNode }) {
  const system = useColorScheme();
  const { store } = useStore();
  const [preference, setPref] = useState<ThemePreference>('system');
  useEffect(() => {
    store.getSetting(THEME_KEY).then((v) => {
      if (v === 'light' || v === 'dark' || v === 'system') setPref(v);
    });
  }, [store]);
  const setPreference = useCallback(
    (p: ThemePreference) => {
      setPref(p);
      void store.setSetting(THEME_KEY, p);
    },
    [store],
  );
  const value = useMemo(() => {
    const { scheme, palette } = resolvePalette(preference, system);
    return { palette, scheme, preference, setPreference };
  }, [preference, system, setPreference]);
  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export function useTheme(): ThemeValue {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used inside ThemeProvider');
  return ctx;
}
