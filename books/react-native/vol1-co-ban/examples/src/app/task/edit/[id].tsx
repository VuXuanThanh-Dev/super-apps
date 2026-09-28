import { Stack, useLocalSearchParams, useRouter } from 'expo-router';
import { ScrollView, Text } from 'react-native';
import { TaskForm } from '@/features/tasks/TaskForm';
import { useTasks } from '@/features/tasks/TasksContext';

// Lời giải bài tập Chương 7: màn hình sửa việc, route động /task/edit/[id].
// Tái sử dụng TaskForm với giá trị ban đầu (initial), giống patchValue() trong Reactive Forms.
export default function EditTaskScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { tasks, updateTask } = useTasks();
  const router = useRouter();
  const task = tasks.find((t) => t.id === id);

  if (!task) return <Text>Không tìm thấy việc này.</Text>;

  return (
    <ScrollView keyboardShouldPersistTaps="handled">
      <Stack.Screen options={{ title: 'Sửa việc' }} />
      <TaskForm
        initial={{ title: task.title, note: task.note, priority: task.priority }}
        submitLabel="Cập nhật"
        onSubmit={(input) => {
          updateTask(task.id, input);
          router.back();
        }}
      />
    </ScrollView>
  );
}
