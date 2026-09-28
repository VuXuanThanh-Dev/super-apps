import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useEffect } from 'react';
import { ActivityIndicator, AppState, View } from 'react-native';
import { ErrorBoundary } from '@/monitoring/ErrorBoundary';
import { consoleTransport, logger } from '@/monitoring/logger';
import { useAuth } from '@/state/auth';

function AppShell() {
  const status = useAuth((s) => s.status);
  const init = useAuth((s) => s.init);
  const lockNow = useAuth((s) => s.lockNow);

  useEffect(() => {
    void init();
    const removeTransport = logger.addTransport(consoleTransport);
    // Bảo mật: khi app chuyển xuống nền (background), khóa lại ngay.
    const sub = AppState.addEventListener('change', (next) => {
      if (next === 'background') lockNow();
    });
    return () => {
      sub.remove();
      removeTransport();
    };
  }, [init, lockNow]);

  if (status === 'loading') {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
        <ActivityIndicator accessibilityLabel="Đang khởi động" />
      </View>
    );
  }

  const unlocked = status === 'unlocked';
  return (
    <Stack screenOptions={{ headerShown: false }}>
      {/* Protected routes: chỉ vào được (app) khi đã mở khóa; ngược lại chỉ có màn hình lock. */}
      <Stack.Protected guard={unlocked}>
        <Stack.Screen name="(app)" />
      </Stack.Protected>
      <Stack.Protected guard={!unlocked}>
        <Stack.Screen name="lock" />
      </Stack.Protected>
    </Stack>
  );
}

export default function RootLayout() {
  return (
    <ErrorBoundary>
      <StatusBar style="auto" />
      <AppShell />
    </ErrorBoundary>
  );
}
