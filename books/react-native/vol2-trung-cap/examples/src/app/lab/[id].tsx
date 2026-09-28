import { Stack, useLocalSearchParams } from 'expo-router';
import { Text, View } from 'react-native';
import { findLab } from '@/chapters/registry';

export default function LabDetail() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const entry = findLab(id);
  if (!entry) return <Text>{`Không có ví dụ "${id}"`}</Text>;
  const { Component, title } = entry;
  return (
    <View style={{ flex: 1 }}>
      <Stack.Screen options={{ title }} />
      <Component />
    </View>
  );
}
