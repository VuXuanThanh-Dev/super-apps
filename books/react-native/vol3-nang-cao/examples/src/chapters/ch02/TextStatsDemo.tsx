import { useState } from 'react';
import { Text, TextInput, View } from 'react-native';
import { isNativeAvailable, textStats } from '../../../modules/text-stats';

// Chương 2: dùng module native tự viết (modules/text-stats). Trong Expo Go → bản JS.
export function TextStatsDemo() {
  const [text, setText] = useState('Xin chào React Native 👋');
  const s = textStats(text);
  return (
    <View style={{ padding: 16, gap: 8 }}>
      <TextInput accessibilityLabel="Văn bản" value={text} onChangeText={setText} multiline style={{ borderWidth: 1, borderColor: '#e5e7eb', padding: 8, borderRadius: 8 }} />
      <Text accessibilityLabel="Thống kê">
        {s.words} từ · {s.characters} ký tự
      </Text>
      <Text>Nguồn: {s.source === 'native' ? 'module native (Swift/Kotlin)' : 'JavaScript (Expo Go / web / test)'}</Text>
      <Text>isNativeAvailable(): {String(isNativeAvailable())}</Text>
    </View>
  );
}
