import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render } from '@testing-library/react-native';
import type { ReactElement, ReactNode } from 'react';

// Mỗi test một QueryClient mới, tắt retry để lỗi hiện ngay (giống TestBed tạo module mới mỗi test).
export function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: Infinity }, mutations: { retry: false } },
  });
}

export async function renderWithProviders(ui: ReactElement, client = createTestQueryClient()) {
  function Providers({ children }: { children: ReactNode }) {
    return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
  }
  const result = await render(ui, { wrapper: Providers });
  return { ...result, client };
}
