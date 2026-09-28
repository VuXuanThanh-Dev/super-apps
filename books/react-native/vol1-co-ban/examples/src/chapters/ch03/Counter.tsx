import { useState } from 'react';
import { Pressable, Text, View } from 'react-native';

// State cục bộ: useState trả về [giá trị, hàm set]. Gọi set → component render lại.
export function Counter({ step = 1 }: { step?: number }) {
  const [count, setCount] = useState(0);
  return (
    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 16 }}>
      <Pressable accessibilityRole="button" accessibilityLabel="Giảm" onPress={() => setCount((c) => c - step)}>
        <Text style={{ fontSize: 28 }}>−</Text>
      </Pressable>
      <Text accessibilityLabel="Giá trị" style={{ fontSize: 28 }}>
        {count}
      </Text>
      <Pressable accessibilityRole="button" accessibilityLabel="Tăng" onPress={() => setCount((c) => c + step)}>
        <Text style={{ fontSize: 28 }}>+</Text>
      </Pressable>
    </View>
  );
}
