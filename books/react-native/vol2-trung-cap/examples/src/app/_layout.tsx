import { QueryClientProvider } from '@tanstack/react-query';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useEffect, useState } from 'react';
import { createQueryClient, setupReactNativeManagers } from '@/lib/queryClient';

export default function RootLayout() {
  // useState(() => ...) tạo QueryClient đúng MỘT lần cho vòng đời app.
  const [queryClient] = useState(createQueryClient);
  useEffect(() => setupReactNativeManagers(), []);

  return (
    <QueryClientProvider client={queryClient}>
      <StatusBar style="auto" />
      <Stack>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="post/[id]" options={{ title: 'Bài viết' }} />
        <Stack.Screen name="lab/[id]" options={{ title: 'Lab' }} />
      </Stack>
    </QueryClientProvider>
  );
}
