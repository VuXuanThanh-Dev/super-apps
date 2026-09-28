import { useRouter } from 'expo-router';
import { KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { TaskForm } from '@/features/tasks/TaskForm';
import { useTasks } from '@/features/tasks/TasksContext';

export default function NewTaskScreen() {
  const { addTask } = useTasks();
  const router = useRouter();

  return (
    <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView keyboardShouldPersistTaps="handled">
        <TaskForm
          submitLabel="Thêm"
          onSubmit={(input) => {
            addTask(input);
            router.back();
          }}
        />
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
