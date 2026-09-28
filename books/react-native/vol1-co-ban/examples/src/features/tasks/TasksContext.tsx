import { createContext, useContext, useMemo, useReducer, type ReactNode } from 'react';
import { SEED_TASKS, createTask, tasksReducer, type Task, type TaskInput } from './model';

// Context + useReducer = "service có state" dùng chung cho nhiều màn hình.
// Trong Angular bạn sẽ viết @Injectable({ providedIn: 'root' }) TasksService.
interface TasksContextValue {
  tasks: Task[];
  addTask: (input: TaskInput) => Task;
  toggleTask: (id: string) => void;
  removeTask: (id: string) => void;
  updateTask: (id: string, changes: Partial<TaskInput>) => void;
  clearDone: () => void;
}

const TasksContext = createContext<TasksContextValue | null>(null);

export function TasksProvider({
  children,
  initialTasks = SEED_TASKS,
}: {
  children: ReactNode;
  initialTasks?: Task[];
}) {
  const [tasks, dispatch] = useReducer(tasksReducer, initialTasks);

  const value = useMemo<TasksContextValue>(
    () => ({
      tasks,
      addTask: (input) => {
        const task = createTask(input);
        dispatch({ type: 'add', task });
        return task;
      },
      toggleTask: (id) => dispatch({ type: 'toggle', id }),
      removeTask: (id) => dispatch({ type: 'remove', id }),
      updateTask: (id, changes) => dispatch({ type: 'update', id, changes }),
      clearDone: () => dispatch({ type: 'clearDone' }),
    }),
    [tasks],
  );

  return <TasksContext.Provider value={value}>{children}</TasksContext.Provider>;
}

export function useTasks(): TasksContextValue {
  const ctx = useContext(TasksContext);
  if (!ctx) throw new Error('useTasks() phải được gọi bên trong <TasksProvider>');
  return ctx;
}
