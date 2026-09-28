import type { ReactNode } from 'react';
import { SafeAreaProvider, type Metrics } from 'react-native-safe-area-context';
import type { Dictionary } from '@/features/lookup/dictionary';
import { LookupProvider } from '@/features/lookup/LookupProvider';
import { ThemeProvider } from '@/features/theme/ThemeProvider';
import { StoreProvider } from '@/storage/StoreProvider';
import type { UserStore } from '@/storage/types';

/** All app-wide providers. Tests pass a MemoryUserStore (and fixed safe-area
 * metrics); the app passes the SQLite store. */
export function AppProviders({
  store,
  dictionary,
  safeAreaMetrics,
  children,
}: {
  store: UserStore;
  dictionary: Dictionary;
  safeAreaMetrics?: Metrics;
  children: ReactNode;
}) {
  return (
    <SafeAreaProvider initialMetrics={safeAreaMetrics}>
      <StoreProvider store={store}>
        <ThemeProvider>
          <LookupProvider dictionary={dictionary}>{children}</LookupProvider>
        </ThemeProvider>
      </StoreProvider>
    </SafeAreaProvider>
  );
}
