import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { TasksProvider } from '@/features/tasks/TasksContext';

// Layout gốc: bọc toàn app trong Provider (giống providers của AppModule/app.config.ts)
// và khai báo một Stack navigator.
export default function RootLayout() {
  return (
    <TasksProvider>
      <StatusBar style="auto" />
      <Stack>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="task/new" options={{ title: 'Việc mới', presentation: 'modal' }} />
        <Stack.Screen name="task/[id]" options={{ title: 'Chi tiết' }} />
        <Stack.Screen name="task/edit/[id]" options={{ title: 'Sửa việc' }} />
        <Stack.Screen name="lab/[id]" options={{ title: 'Lab' }} />
      </Stack>
    </TasksProvider>
  );
}
