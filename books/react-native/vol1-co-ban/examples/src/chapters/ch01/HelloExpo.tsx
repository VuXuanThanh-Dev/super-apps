import { useState } from 'react';
import { Platform, Pressable, StyleSheet, Text, View } from 'react-native';

// Chương 1: màn hình đầu tiên. Sửa chữ "Xin chào" rồi lưu file:
// Expo Go trên iPhone sẽ cập nhật ngay (Fast Refresh).
export function HelloExpo() {
  const [count, setCount] = useState(0);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Xin chào React Native 👋</Text>
      <Text>Bạn đang chạy trên: {Platform.OS}</Text>
      <Pressable accessibilityRole="button" style={styles.button} onPress={() => setCount((c) => c + 1)}>
        <Text style={styles.buttonText}>Đã bấm {count} lần</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 16, padding: 24 },
  title: { fontSize: 24, fontWeight: '700' },
  button: { backgroundColor: '#2563eb', paddingVertical: 12, paddingHorizontal: 20, borderRadius: 10 },
  buttonText: { color: '#fff', fontSize: 16 },
});
