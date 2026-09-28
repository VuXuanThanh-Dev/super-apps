import { QueryClient, focusManager, onlineManager } from '@tanstack/react-query';
import * as Network from 'expo-network';
import { AppState, Platform, type AppStateStatus } from 'react-native';

export function createQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: 2, staleTime: 30_000 },
    },
  });
}

// Theo hướng dẫn "React Native" của TanStack Query:
// 1) báo cho Query biết trạng thái mạng (tự refetch khi có mạng lại);
// 2) báo khi app quay lại foreground (tự refetch dữ liệu cũ).
export function setupReactNativeManagers(): () => void {
  onlineManager.setEventListener((setOnline) => {
    let initialised = false;
    const sub = Network.addNetworkStateListener((state) => {
      initialised = true;
      setOnline(!!state.isConnected);
    });
    Network.getNetworkStateAsync()
      .then((state) => {
        if (!initialised) setOnline(!!state.isConnected);
      })
      .catch(() => {});
    return () => sub.remove();
  });

  const onAppStateChange = (status: AppStateStatus) => {
    if (Platform.OS !== 'web') focusManager.setFocused(status === 'active');
  };
  const appStateSub = AppState.addEventListener('change', onAppStateChange);
  return () => appStateSub.remove();
}
