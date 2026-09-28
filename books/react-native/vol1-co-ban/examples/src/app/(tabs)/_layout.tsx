import { Tabs } from 'expo-router';
import { Text } from 'react-native';

function Icon({ emoji }: { emoji: string }) {
  return <Text style={{ fontSize: 18 }}>{emoji}</Text>;
}

export default function TabsLayout() {
  return (
    <Tabs>
      <Tabs.Screen
        name="index"
        options={{ title: 'Việc cần làm', tabBarIcon: () => <Icon emoji="✅" /> }}
      />
      <Tabs.Screen name="stats" options={{ title: 'Thống kê', tabBarIcon: () => <Icon emoji="📊" /> }} />
      <Tabs.Screen name="lab" options={{ title: 'Lab', tabBarIcon: () => <Icon emoji="🧪" /> }} />
    </Tabs>
  );
}
