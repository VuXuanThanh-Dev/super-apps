import { render } from '@testing-library/react-native';
import type { ReactElement } from 'react';
import { AppProviders } from '@/components/AppProviders';
import { defaultDictionary } from '@/features/lookup/defaultDictionary';
import { MemoryUserStore } from '@/storage/memoryStore';

export const testMetrics = {
  frame: { x: 0, y: 0, width: 390, height: 844 },
  insets: { top: 0, left: 0, right: 0, bottom: 0 },
};

/** Render a component inside all app providers with an in-memory store. */
export async function renderWithApp(ui: ReactElement, store = new MemoryUserStore()) {
  const utils = await render(
    <AppProviders store={store} dictionary={defaultDictionary} safeAreaMetrics={testMetrics}>
      {ui}
    </AppProviders>,
  );
  return { ...utils, store };
}
