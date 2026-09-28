import { Link, useRouter } from 'expo-router';
import { useCallback, useMemo, useState } from 'react';
import { FlatList, StyleSheet, Text, TextInput, View } from 'react-native';
import { FilterBar } from '@/features/tasks/FilterBar';
import { TaskItem } from '@/features/tasks/TaskItem';
import { useTasks } from '@/features/tasks/TasksContext';
import { filterTasks, type Filter } from '@/features/tasks/model';
import { colors, spacing } from '@/theme';

export default function TaskListScreen() {
  const { tasks, toggleTask } = useTasks();
  const router = useRouter();
  const [filter, setFilter] = useState<Filter>('all');
  const [query, setQuery] = useState('');

  // useMemo ~ một computed() signal: chỉ tính lại khi tasks/filter/query đổi.
  const visible = useMemo(() => filterTasks(tasks, filter, query), [tasks, filter, query]);
  const openTask = useCallback((id: string) => router.push(`/task/${id}`), [router]);

  return (
    <View style={styles.screen}>
      <TextInput
        accessibilityLabel="Tìm kiếm"
        placeholder="Tìm việc..."
        value={query}
        onChangeText={setQuery}
        style={styles.search}
        clearButtonMode="while-editing"
      />
      <FilterBar value={filter} onChange={setFilter} />
      <FlatList
        style={styles.list}
        data={visible}
        keyExtractor={(t) => t.id}
        renderItem={({ item }) => <TaskItem task={item} onToggle={toggleTask} onOpen={openTask} />}
        ListEmptyComponent={<Text style={styles.empty}>Không có việc nào.</Text>}
      />
      <Link href="/task/new" style={styles.fab} accessibilityRole="button" accessibilityLabel="Thêm việc">
        ＋
      </Link>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.background, paddingTop: spacing.md, gap: spacing.md },
  search: {
    marginHorizontal: spacing.lg,
    padding: spacing.md,
    borderRadius: 10,
    backgroundColor: colors.card,
    borderWidth: 1,
    borderColor: colors.border,
    fontSize: 16,
  },
  list: { flex: 1 },
  empty: { textAlign: 'center', color: colors.muted, marginTop: spacing.xl },
  fab: {
    position: 'absolute',
    right: spacing.xl,
    bottom: spacing.xl,
    width: 56,
    height: 56,
    lineHeight: 56,
    borderRadius: 28,
    overflow: 'hidden',
    textAlign: 'center',
    fontSize: 28,
    color: '#fff',
    backgroundColor: colors.primary,
  },
});
