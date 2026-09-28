import { useNetworkState } from 'expo-network';
import { StyleSheet, Text } from 'react-native';

// Hiện dải cảnh báo khi mất mạng. `isInternetReachable` có thể là undefined lúc đầu.
export function OfflineBanner() {
  const state = useNetworkState();
  const offline = state.isConnected === false || state.isInternetReachable === false;
  if (!offline) return null;
  return (
    <Text accessibilityRole="alert" style={styles.banner}>
      Đang offline — hiển thị dữ liệu đã lưu
    </Text>
  );
}

const styles = StyleSheet.create({
  banner: { backgroundColor: '#fef3c7', color: '#92400e', padding: 8, textAlign: 'center' },
});
