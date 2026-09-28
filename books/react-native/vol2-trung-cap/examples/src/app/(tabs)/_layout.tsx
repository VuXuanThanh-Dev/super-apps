import { Tabs } from 'expo-router';
import { Text } from 'react-native';
import { useFavoriteCount } from '@/state/favorites';

function TabIcon({ emoji }: { emoji: string }) {
  return <Text style={{ fontSize: 18 }}>{emoji}</Text>;
}

export default function TabsLayout() {
  const favCount = useFavoriteCount(); // badge số bài yêu thích, cập nhật tự động từ store
  return (
    <Tabs>
      <Tabs.Screen name="index" options={{ title: 'Bài viết', tabBarIcon: () => <TabIcon emoji="📰" /> }} />
      <Tabs.Screen
        name="favorites"
        options={{
          title: 'Yêu thích',
          tabBarIcon: () => <TabIcon emoji="❤️" />,
          tabBarBadge: favCount > 0 ? favCount : undefined,
        }}
      />
      <Tabs.Screen name="device" options={{ title: 'Thiết bị', tabBarIcon: () => <TabIcon emoji="📱" /> }} />
      <Tabs.Screen name="lab" options={{ title: 'Lab', tabBarIcon: () => <TabIcon emoji="🧪" /> }} />
    </Tabs>
  );
}
