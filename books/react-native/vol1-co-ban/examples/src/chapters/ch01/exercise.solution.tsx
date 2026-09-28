import { useState } from 'react';
import { Pressable, Text, View } from 'react-native';

// Lời giải bài tập Chương 1: thêm nút "Đặt lại", nút bị vô hiệu khi count = 0.
export function HelloWithReset() {
  const [count, setCount] = useState(0);
  return (
    <View style={{ padding: 24, gap: 12 }}>
      <Pressable accessibilityRole="button" onPress={() => setCount((c) => c + 1)}>
        <Text>Đã bấm {count} lần</Text>
      </Pressable>
      <Pressable
        accessibilityRole="button"
        disabled={count === 0}
        accessibilityState={{ disabled: count === 0 }}
        onPress={() => setCount(0)}
        style={{ opacity: count === 0 ? 0.4 : 1 }}
      >
        <Text>Đặt lại</Text>
      </Pressable>
    </View>
  );
}
