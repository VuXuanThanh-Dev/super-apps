import { Stack } from 'expo-router';
import { useEffect } from 'react';
import { useNotes } from '@/state/notes';

export default function AppLayout() {
  const load = useNotes((s) => s.load);
  useEffect(() => {
    void load();
  }, [load]);
  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: 'Ghi chú' }} />
      <Stack.Screen name="note/[id]" options={{ title: 'Ghi chú' }} />
      <Stack.Screen name="settings" options={{ title: 'Cài đặt' }} />
      <Stack.Screen name="lab/[id]" options={{ title: 'Lab' }} />
    </Stack>
  );
}
