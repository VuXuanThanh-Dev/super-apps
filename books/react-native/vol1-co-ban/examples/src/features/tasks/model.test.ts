import {
  SEED_TASKS,
  countStats,
  createTask,
  filterTasks,
  sortByPriority,
  tasksReducer,
  validateTaskInput,
} from './model';

describe('tasksReducer', () => {
  it('thêm task mới lên đầu danh sách', () => {
    const task = createTask({ title: '  Mua sữa ', note: '', priority: 'low' }, 100);
    const next = tasksReducer(SEED_TASKS, { type: 'add', task });
    expect(next[0].title).toBe('Mua sữa');
    expect(next).toHaveLength(SEED_TASKS.length + 1);
  });

  it('toggle đổi trạng thái done và không sửa mảng cũ (immutable)', () => {
    const next = tasksReducer(SEED_TASKS, { type: 'toggle', id: 'seed-2' });
    expect(next.find((t) => t.id === 'seed-2')?.done).toBe(true);
    expect(SEED_TASKS.find((t) => t.id === 'seed-2')?.done).toBe(false);
  });

  it('remove và update', () => {
    const removed = tasksReducer(SEED_TASKS, { type: 'remove', id: 'seed-1' });
    expect(removed.map((t) => t.id)).toEqual(['seed-2', 'seed-3']);
    const updated = tasksReducer(SEED_TASKS, {
      type: 'update',
      id: 'seed-3',
      changes: { priority: 'high' },
    });
    expect(updated.find((t) => t.id === 'seed-3')?.priority).toBe('high');
  });
});

describe('filterTasks', () => {
  it('lọc theo trạng thái và từ khóa (không phân biệt hoa thường)', () => {
    expect(filterTasks(SEED_TASKS, 'done')).toHaveLength(1);
    expect(filterTasks(SEED_TASKS, 'active')).toHaveLength(2);
    expect(filterTasks(SEED_TASKS, 'all', 'FLEX').map((t) => t.id)).toEqual(['seed-2']);
    expect(filterTasks(SEED_TASKS, 'all', 'tìm kiếm').map((t) => t.id)).toEqual(['seed-3']);
  });
});

describe('validateTaskInput', () => {
  it('báo lỗi khi tiêu đề rỗng hoặc quá ngắn', () => {
    expect(validateTaskInput({ title: ' ', note: '', priority: 'low' }).title).toBe(
      'Tiêu đề không được để trống',
    );
    expect(validateTaskInput({ title: 'ab', note: '', priority: 'low' }).title).toMatch(/ít nhất 3/);
    expect(validateTaskInput({ title: 'Học RN', note: '', priority: 'low' })).toEqual({});
  });
});

describe('countStats', () => {
  it('đếm tổng, đã xong, phần trăm', () => {
    expect(countStats(SEED_TASKS)).toEqual({
      total: 3,
      done: 1,
      active: 2,
      percentDone: 33,
      byPriority: { low: 1, medium: 1, high: 0 },
    });
    expect(countStats([]).percentDone).toBe(0);
  });
});

describe('clearDone (bài tập Chương 8)', () => {
  it('xóa mọi việc đã xong', () => {
    const next = tasksReducer(SEED_TASKS, { type: 'clearDone' });
    expect(next.every((t) => !t.done)).toBe(true);
    expect(next).toHaveLength(2);
  });
});

describe('sortByPriority (bài tập 2 Chương 8)', () => {
  it('Cao → Vừa → Thấp, không sửa mảng gốc', () => {
    const reversed = [...SEED_TASKS].reverse();
    expect(sortByPriority(reversed).map((t) => t.id)).toEqual(['seed-1', 'seed-2', 'seed-3']);
    expect(reversed[0].id).toBe('seed-3');
  });
});
