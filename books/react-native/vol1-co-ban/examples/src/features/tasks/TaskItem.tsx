import { memo } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { colors, spacing } from '@/theme';
import { PRIORITY_LABEL, type Task } from './model';

interface TaskItemProps {
  task: Task;
  onToggle: (id: string) => void;
  onOpen: (id: string) => void;
}

const PRIORITY_COLOR = { low: colors.muted, medium: '#d97706', high: colors.danger } as const;

function TaskItemBase({ task, onToggle, onOpen }: TaskItemProps) {
  return (
    <View style={styles.row}>
      <Pressable
        accessibilityRole="checkbox"
        accessibilityState={{ checked: task.done }}
        accessibilityLabel={`Đánh dấu ${task.title}`}
        onPress={() => onToggle(task.id)}
        hitSlop={8}
        style={[styles.checkbox, task.done && styles.checkboxDone]}
      >
        {task.done ? <Text style={styles.check}>✓</Text> : null}
      </Pressable>
      <Pressable
        accessibilityRole="button"
        accessibilityLabel={`Mở ${task.title}`}
        onPress={() => onOpen(task.id)}
        style={styles.body}
      >
        <Text style={[styles.title, task.done && styles.titleDone]} numberOfLines={1}>
          {task.title}
        </Text>
        <Text style={[styles.badge, { color: PRIORITY_COLOR[task.priority] }]}>
          Ưu tiên: {PRIORITY_LABEL[task.priority]}
        </Text>
      </Pressable>
    </View>
  );
}

// memo: chỉ render lại khi props đổi — quan trọng với danh sách dài.
export const TaskItem = memo(TaskItemBase);

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
    padding: spacing.lg,
    backgroundColor: colors.card,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.border,
  },
  checkbox: {
    width: 26,
    height: 26,
    borderRadius: 13,
    borderWidth: 2,
    borderColor: colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkboxDone: { backgroundColor: colors.primary },
  check: { color: '#fff', fontWeight: '700' },
  body: { flex: 1 },
  title: { fontSize: 16, color: colors.text },
  titleDone: { textDecorationLine: 'line-through', color: colors.muted },
  badge: { fontSize: 12, marginTop: 2 },
});
