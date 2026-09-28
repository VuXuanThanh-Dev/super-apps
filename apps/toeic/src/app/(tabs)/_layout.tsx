import { Ionicons } from '@expo/vector-icons';
import { Tabs } from 'expo-router';
import type { ComponentProps } from 'react';
import type { ColorValue } from 'react-native';
import { useTheme } from '@/features/theme/ThemeProvider';

type IconName = ComponentProps<typeof Ionicons>['name'];

export default function TabsLayout() {
  const { palette } = useTheme();
  const icon = (name: IconName) =>
    function TabIcon({ color, size }: { color: ColorValue; size: number }) {
      return <Ionicons name={name} color={color as string} size={size} />;
    };
  return (
    <Tabs
      screenOptions={{
        headerStyle: { backgroundColor: palette.card },
        headerTintColor: palette.text,
        tabBarStyle: { backgroundColor: palette.card, borderTopColor: palette.border },
        tabBarActiveTintColor: palette.primary,
        tabBarInactiveTintColor: palette.muted,
        sceneStyle: { backgroundColor: palette.background },
      }}
    >
      <Tabs.Screen name="index" options={{ title: 'Home', tabBarIcon: icon('home') }} />
      <Tabs.Screen name="vocab" options={{ title: 'Words', tabBarIcon: icon('book') }} />
      <Tabs.Screen name="practice" options={{ title: 'Practice', tabBarIcon: icon('school') }} />
      <Tabs.Screen name="read" options={{ title: 'Read', tabBarIcon: icon('reader') }} />
      <Tabs.Screen name="saved" options={{ title: 'Saved', tabBarIcon: icon('star') }} />
    </Tabs>
  );
}
