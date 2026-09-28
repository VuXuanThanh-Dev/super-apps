import { useEffect } from 'react';
import { Text } from 'react-native';
import Animated, { useAnimatedStyle, useSharedValue, withSequence, withTiming } from 'react-native-reanimated';

// Lời giải bài tập Chương 4: rung ngang (shake) khi có lỗi — dùng Reanimated.
export function ShakeOnError({ error }: { error: string | null }) {
  const x = useSharedValue(0);
  useEffect(() => {
    if (!error) return;
    x.set(
      withSequence(
        withTiming(-10, { duration: 50 }),
        withTiming(10, { duration: 50 }),
        withTiming(-6, { duration: 50 }),
        withTiming(0, { duration: 50 }),
      ),
    );
  }, [error, x]);
  const style = useAnimatedStyle(() => ({ transform: [{ translateX: x.get() }] }));
  return (
    <Animated.View testID="shake" style={style}>
      <Text style={{ color: '#dc2626' }}>{error ?? ' '}</Text>
    </Animated.View>
  );
}
