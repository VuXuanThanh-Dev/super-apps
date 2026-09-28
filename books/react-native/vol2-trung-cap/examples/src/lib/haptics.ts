import * as Haptics from 'expo-haptics';
import { Platform } from 'react-native';

// Bọc expo-haptics: bỏ qua trên web và không để lỗi rung làm hỏng thao tác chính.
export async function tapFeedback(): Promise<void> {
  if (Platform.OS === 'web') return;
  try {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
  } catch {
    // Một số thiết bị không hỗ trợ rung — không sao.
  }
}

export async function successFeedback(): Promise<void> {
  if (Platform.OS === 'web') return;
  try {
    await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
  } catch {
    // bỏ qua
  }
}
