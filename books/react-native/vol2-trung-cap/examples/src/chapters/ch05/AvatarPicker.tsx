import * as ImagePicker from 'expo-image-picker';
import { useState } from 'react';
import { Image, Pressable, Text, View } from 'react-native';
import { successFeedback } from '@/lib/haptics';

// Chương 5: chọn ảnh từ thư viện. Trên iOS, trình chọn ảnh hệ thống không cần xin quyền trước.
export function AvatarPicker() {
  const [uri, setUri] = useState<string | null>(null);

  const pick = async () => {
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsEditing: true,
      aspect: [1, 1],
      quality: 0.7,
    });
    if (!result.canceled) {
      setUri(result.assets[0].uri);
      void successFeedback();
    }
  };

  return (
    <View style={{ alignItems: 'center', gap: 8 }}>
      {uri ? (
        <Image source={{ uri }} style={{ width: 96, height: 96, borderRadius: 48 }} accessibilityLabel="Ảnh đại diện" />
      ) : (
        <Text style={{ fontSize: 64 }}>🙂</Text>
      )}
      <Pressable accessibilityRole="button" onPress={pick}>
        <Text>🖼️ Chọn ảnh đại diện</Text>
      </Pressable>
    </View>
  );
}
