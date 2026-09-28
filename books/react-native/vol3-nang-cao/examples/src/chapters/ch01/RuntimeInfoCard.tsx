import { Text, View } from 'react-native';
import { getRuntimeInfo } from './runtimeInfo';

export function RuntimeInfoCard() {
  const info = getRuntimeInfo();
  return (
    <View style={{ padding: 16, gap: 6 }}>
      <Text accessibilityLabel="Engine">JS engine: {info.engine}</Text>
      <Text>Nền tảng: {info.os}</Text>
      <Text accessibilityLabel="Phiên bản RN">React Native: {info.reactNativeVersion}</Text>
      <Text>Tên máy (TurboModule): {info.deviceName}</Text>
    </View>
  );
}
