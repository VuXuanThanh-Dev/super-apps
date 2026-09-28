import { useEffect, useState, type ReactNode } from 'react';
import { Animated } from 'react-native';

// Chương 4: Animated API có sẵn trong React Native (không cần thư viện).
export function FadeInView({ children, duration = 500 }: { children: ReactNode; duration?: number }) {
  // Tài liệu cũ hay viết useRef(new Animated.Value(0)).current — luật react-hooks/refs
  // (có trong eslint-config-expo 57) báo lỗi vì đọc ref khi render. useState(() => ...) tạo
  // giá trị một lần và an toàn.
  const [opacity] = useState(() => new Animated.Value(0));
  useEffect(() => {
    Animated.timing(opacity, { toValue: 1, duration, useNativeDriver: true }).start();
  }, [opacity, duration]);
  return (
    <Animated.View testID="fade" style={{ opacity }}>
      {children}
    </Animated.View>
  );
}
