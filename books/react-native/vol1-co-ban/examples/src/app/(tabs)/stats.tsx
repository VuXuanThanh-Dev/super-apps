import { StyleSheet, Text, View } from 'react-native';
import { AppButton } from '@/components/AppButton';
import { useTasks } from '@/features/tasks/TasksContext';
import { PRIORITY_LABEL, countStats, type Priority } from '@/features/tasks/model';
import { colors, spacing } from '@/theme';

export default function StatsScreen() {
  const { tasks, clearDone } = useTasks();
  const stats = countStats(tasks);

  return (
    <View style={styles.screen}>
      <View style={styles.card}>
        <Text style={styles.big}>{stats.percentDone}%</Text>
        <Text style={styles.muted}>
          Đã xong {stats.done}/{stats.total} việc
        </Text>
        <View style={styles.track} accessibilityRole="progressbar" accessibilityValue={{ min: 0, max: 100, now: stats.percentDone }}>
          <View style={[styles.fill, { width: `${stats.percentDone}%` }]} />
        </View>
      </View>
      <View style={styles.card}>
        <Text style={styles.heading}>Việc chưa xong theo mức ưu tiên</Text>
        {(Object.keys(stats.byPriority) as Priority[]).map((p) => (
          <Text key={p} style={styles.line}>
            {PRIORITY_LABEL[p]}: {stats.byPriority[p]}
          </Text>
        ))}
      </View>
      <AppButton title={`Xóa ${stats.done} việc đã xong`} variant="danger" disabled={stats.done === 0} onPress={clearDone} />
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, padding: spacing.lg, gap: spacing.lg, backgroundColor: colors.background },
  card: { backgroundColor: colors.card, borderRadius: 12, padding: spacing.lg, gap: spacing.sm },
  big: { fontSize: 40, fontWeight: '800', color: colors.primary },
  muted: { color: colors.muted },
  track: { height: 10, borderRadius: 5, backgroundColor: colors.border, overflow: 'hidden' },
  fill: { height: '100%', backgroundColor: colors.success },
  heading: { fontWeight: '700', fontSize: 16 },
  line: { fontSize: 15 },
});
