import * as Notifications from 'expo-notifications';
import { Stack } from 'expo-router';
import { openDatabaseAsync } from 'expo-sqlite';
import { StatusBar } from 'expo-status-bar';
import { useMemo } from 'react';
import { AppProviders } from '@/components/AppProviders';
import { defaultDictionary } from '@/features/lookup/defaultDictionary';
import { useTheme } from '@/features/theme/ThemeProvider';
import { SqliteUserStore } from '@/storage/sqliteStore';

// Show the daily reminder even when the app is open.
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowBanner: true,
    shouldShowList: true,
    shouldPlaySound: false,
    shouldSetBadge: false,
  }),
});

export default function RootLayout() {
  const store = useMemo(() => new SqliteUserStore(() => openDatabaseAsync('toeic-user.db')), []);
  return (
    <AppProviders store={store} dictionary={defaultDictionary}>
      <ThemedStack />
    </AppProviders>
  );
}

function ThemedStack() {
  const { palette, scheme } = useTheme();
  return (
    <>
      <StatusBar style={scheme === 'dark' ? 'light' : 'dark'} />
      <Stack
        screenOptions={{
          headerStyle: { backgroundColor: palette.card },
          headerTintColor: palette.text,
          contentStyle: { backgroundColor: palette.background },
        }}
      >
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="settings" options={{ title: 'Settings' }} />
      </Stack>
    </>
  );
}
