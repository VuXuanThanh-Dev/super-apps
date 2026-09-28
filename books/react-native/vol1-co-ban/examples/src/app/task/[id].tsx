import { Stack, useLocalSearchParams, useRouter } from 'expo-router';
import { Alert, StyleSheet, Text, View } from 'react-native';
import { AppButton } from '@/components/AppButton';
import { useTasks } from '@/features/tasks/TasksContext';
import { PRIORITY_LABEL } from '@/features/tasks/model';
import { colors, spacing } from '@/theme';

export default function TaskDetailScreen() {
  // Tham số route, giống ActivatedRoute.snapshot.paramMap.get('id')
  const { id } = useLocalSearchParams<{ id: string }>();
  const { tasks, toggleTask, removeTask } = useTasks();
  const router = useRouter();
  const task = tasks.find((t) => t.id === id);

  if (!task) {
    return (
      <View style={styles.screen}>
        <Text>Không tìm thấy việc này.</Text>
      </View>
    );
  }

  const confirmDelete = () =>
    Alert.alert('Xóa việc?', task.title, [
      { text: 'Hủy', style: 'cancel' },
      {
        text: 'Xóa',
        style: 'destructive',
        onPress: () => {
          removeTask(task.id);
          router.back();
        },
      },
    ]);

  return (
    <View style={styles.screen}>
      <Stack.Screen options={{ title: task.title }} />
      <Text style={styles.title}>{task.title}</Text>
      <Text style={styles.meta}>Ưu tiên: {PRIORITY_LABEL[task.priority]}</Text>
      <Text style={styles.meta}>Trạng thái: {task.done ? 'Đã xong' : 'Chưa xong'}</Text>
      {task.note ? <Text style={styles.note}>{task.note}</Text> : null}
      <AppButton
        title={task.done ? 'Đánh dấu chưa xong' : 'Đánh dấu đã xong'}
        onPress={() => toggleTask(task.id)}
      />
      <AppButton
        title="Sửa"
        variant="ghost"
        onPress={() => router.push({ pathname: '/task/edit/[id]', params: { id: task.id } })}
      />
      <AppButton title="Xóa" variant="danger" onPress={confirmDelete} />
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, padding: spacing.lg, gap: spacing.md, backgroundColor: colors.background },
  title: { fontSize: 22, fontWeight: '700', color: colors.text },
  meta: { color: colors.muted },
  note: { fontSize: 16, lineHeight: 22, color: colors.text },
});
