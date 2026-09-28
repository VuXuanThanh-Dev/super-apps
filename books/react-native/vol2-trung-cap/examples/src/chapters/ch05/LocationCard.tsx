import * as Location from 'expo-location';
import { useState } from 'react';
import { Linking, Pressable, Text, View } from 'react-native';
import { formatCoords } from './formatCoords';
import { nextPermissionAction, type PermissionStatus } from './permissions';

type UiState =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; text: string }
  | { kind: 'blocked' }
  | { kind: 'error'; message: string };

// Chương 5: lấy vị trí hiện tại với expo-location (chạy được trong Expo Go).
export function LocationCard() {
  const [state, setState] = useState<UiState>({ kind: 'idle' });

  const locate = async () => {
    setState({ kind: 'loading' });
    try {
      let perm = await Location.getForegroundPermissionsAsync();
      let action = nextPermissionAction(perm.status as PermissionStatus, perm.canAskAgain);
      if (action === 'ask') {
        perm = await Location.requestForegroundPermissionsAsync();
        action = nextPermissionAction(perm.status as PermissionStatus, perm.canAskAgain);
      }
      if (action !== 'use') {
        setState({ kind: 'blocked' });
        return;
      }
      const pos = await Location.getCurrentPositionAsync({ accuracy: Location.Accuracy.Balanced });
      setState({ kind: 'done', text: formatCoords(pos.coords.latitude, pos.coords.longitude) });
    } catch (e) {
      setState({ kind: 'error', message: e instanceof Error ? e.message : String(e) });
    }
  };

  return (
    <View style={{ gap: 8 }}>
      <Pressable accessibilityRole="button" onPress={locate} disabled={state.kind === 'loading'}>
        <Text>📍 Lấy vị trí của tôi</Text>
      </Pressable>
      {state.kind === 'loading' ? <Text>Đang lấy vị trí...</Text> : null}
      {state.kind === 'done' ? <Text accessibilityLabel="Tọa độ">{state.text}</Text> : null}
      {state.kind === 'error' ? <Text>Lỗi: {state.message}</Text> : null}
      {state.kind === 'blocked' ? (
        <Pressable accessibilityRole="button" onPress={() => Linking.openSettings()}>
          <Text>Bạn đã tắt quyền vị trí. Mở Cài đặt</Text>
        </Pressable>
      ) : null}
    </View>
  );
}
