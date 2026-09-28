import { useState } from 'react';
import { Pressable, Text, View } from 'react-native';
import Animated, { FadeIn, FadeOut, LinearTransition } from 'react-native-reanimated';
import { FavoriteButton } from '@/components/FavoriteButton';
import { FadeInView } from './FadeInView';
import { ShakeOnError } from './ShakeOnError';

export function AnimationDemo() {
  const [items, setItems] = useState([1, 2, 3]);
  const [error, setError] = useState<string | null>(null);
  return (
    <View style={{ padding: 16, gap: 16 }}>
      <FadeInView>
        <Text>1) Animated API: hiện dần (fade in)</Text>
      </FadeInView>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
        <Text>2) Reanimated: bấm tim</Text>
        <FavoriteButton postId={999} />
      </View>
      <Text>3) Layout animation: thêm/xóa phần tử</Text>
      <Pressable accessibilityRole="button" onPress={() => setItems((l) => [...l, (l.at(-1) ?? 0) + 1])}>
        <Text>＋ Thêm</Text>
      </Pressable>
      {items.map((n) => (
        <Animated.View key={n} entering={FadeIn} exiting={FadeOut} layout={LinearTransition}>
          <Pressable accessibilityRole="button" onPress={() => setItems((l) => l.filter((x) => x !== n))}>
            <Text>Mục {n} (bấm để xóa)</Text>
          </Pressable>
        </Animated.View>
      ))}
      <Pressable accessibilityRole="button" onPress={() => setError(`Lỗi lúc ${new Date().toLocaleTimeString()}`)}>
        <Text>4) Tạo lỗi để rung</Text>
      </Pressable>
      <ShakeOnError error={error} />
    </View>
  );
}
