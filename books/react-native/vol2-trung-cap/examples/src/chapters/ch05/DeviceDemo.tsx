import { Pressable, ScrollView, Text } from 'react-native';
import { successFeedback, tapFeedback } from '@/lib/haptics';
import { AvatarPicker } from './AvatarPicker';
import { LocationCard } from './LocationCard';

export function DeviceDemo() {
  return (
    <ScrollView contentContainerStyle={{ padding: 16, gap: 24 }}>
      <AvatarPicker />
      <LocationCard />
      <Pressable accessibilityRole="button" onPress={() => tapFeedback()}>
        <Text>📳 Rung nhẹ (impact)</Text>
      </Pressable>
      <Pressable accessibilityRole="button" onPress={() => successFeedback()}>
        <Text>✅ Rung thành công (notification)</Text>
      </Pressable>
    </ScrollView>
  );
}
