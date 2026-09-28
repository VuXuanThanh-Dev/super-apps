// Logic thuần (pure) của app "Việc Cần Làm". Không import React Native ở đây,
// nên rất dễ test — giống như tách logic ra khỏi component trong Angular.

export type Priority = 'low' | 'medium' | 'high';

export interface Task {
  id: string;
  title: string;
  note: string;
  priority: Priority;
  done: boolean;
  createdAt: number;
}

export interface TaskInput {
  title: string;
  note: string;
  priority: Priority;
}

export type TaskAction =
  | { type: 'add'; task: Task }
  | { type: 'toggle'; id: string }
  | { type: 'remove'; id: string }
  | { type: 'update'; id: string; changes: Partial<TaskInput> }
  | { type: 'clearDone' }; // lời giải bài tập Chương 8

export type Filter = 'all' | 'active' | 'done';

export const PRIORITY_LABEL: Record<Priority, string> = {
  low: 'Thấp',
  medium: 'Vừa',
  high: 'Cao',
};

let counter = 0;
export function createTask(input: TaskInput, now: number = Date.now()): Task {
  counter += 1;
  return {
    id: `${now.toString(36)}-${counter}`,
    title: input.title.trim(),
    note: input.note.trim(),
    priority: input.priority,
    done: false,
    createdAt: now,
  };
}

export function tasksReducer(state: Task[], action: TaskAction): Task[] {
  switch (action.type) {
    case 'add':
      return [action.task, ...state];
    case 'toggle':
      return state.map((t) => (t.id === action.id ? { ...t, done: !t.done } : t));
    case 'remove':
      return state.filter((t) => t.id !== action.id);
    case 'update':
      return state.map((t) => (t.id === action.id ? { ...t, ...action.changes } : t));
    case 'clearDone':
      return state.filter((t) => !t.done);
  }
}

export function filterTasks(tasks: Task[], filter: Filter, query = ''): Task[] {
  const q = query.trim().toLowerCase();
  return tasks.filter((t) => {
    if (filter === 'active' && t.done) return false;
    if (filter === 'done' && !t.done) return false;
    if (q && !t.title.toLowerCase().includes(q) && !t.note.toLowerCase().includes(q)) {
      return false;
    }
    return true;
  });
}

export type TaskErrors = Partial<Record<keyof TaskInput, string>>;

export function validateTaskInput(input: TaskInput): TaskErrors {
  const errors: TaskErrors = {};
  const title = input.title.trim();
  if (title.length === 0) errors.title = 'Tiêu đề không được để trống';
  else if (title.length < 3) errors.title = 'Tiêu đề cần ít nhất 3 ký tự';
  else if (title.length > 80) errors.title = 'Tiêu đề tối đa 80 ký tự';
  if (input.note.length > 500) errors.note = 'Ghi chú tối đa 500 ký tự';
  return errors;
}

export interface TaskStats {
  total: number;
  done: number;
  active: number;
  percentDone: number;
  byPriority: Record<Priority, number>;
}

export function countStats(tasks: Task[]): TaskStats {
  const done = tasks.filter((t) => t.done).length;
  const byPriority: Record<Priority, number> = { low: 0, medium: 0, high: 0 };
  for (const t of tasks) if (!t.done) byPriority[t.priority] += 1;
  return {
    total: tasks.length,
    done,
    active: tasks.length - done,
    percentDone: tasks.length === 0 ? 0 : Math.round((done / tasks.length) * 100),
    byPriority,
  };
}

export const SEED_TASKS: Task[] = [
  { id: 'seed-1', title: 'Cài Expo Go trên iPhone', note: 'App Store → Expo Go', priority: 'high', done: true, createdAt: 1 },
  { id: 'seed-2', title: 'Đọc chương Flexbox', note: '', priority: 'medium', done: false, createdAt: 2 },
  { id: 'seed-3', title: 'Làm bài tập FlatList', note: 'Thêm ô tìm kiếm', priority: 'low', done: false, createdAt: 3 },
];
