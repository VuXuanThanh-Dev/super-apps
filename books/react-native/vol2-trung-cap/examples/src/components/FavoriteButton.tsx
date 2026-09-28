import { Pressable, Text } from 'react-native';
import Animated, { useAnimatedStyle, useSharedValue, withSequence, withSpring } from 'react-native-reanimated';
import { tapFeedback } from '@/lib/haptics';
import { useFavorites, useIsFavorite } from '@/state/favorites';

// Nút tim: Reanimated (phóng to rồi thu lại) + rung nhẹ + Zustand store.
export function FavoriteButton({ postId }: { postId: number }) {
  const isFav = useIsFavorite(postId);
  const toggle = useFavorites((s) => s.toggle);
  const scale = useSharedValue(1);
  const animatedStyle = useAnimatedStyle(() => ({ transform: [{ scale: scale.get() }] }));

  const onPress = () => {
    // Dùng .set()/.get() thay vì gán .value — tương thích React Compiler (luật react-hooks/immutability).
    scale.set(withSequence(withSpring(1.4), withSpring(1)));
    toggle(postId);
    void tapFeedback();
  };

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={isFav ? 'Bỏ yêu thích' : 'Yêu thích'}
      accessibilityState={{ selected: isFav }}
      onPress={onPress}
      hitSlop={10}
    >
      <Animated.View style={animatedStyle}>
        <Text style={{ fontSize: 22 }}>{isFav ? '❤️' : '🤍'}</Text>
      </Animated.View>
    </Pressable>
  );
}
