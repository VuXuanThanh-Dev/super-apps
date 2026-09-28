import { Pressable, StyleSheet, Text, View } from 'react-native';
import { colors, spacing } from '@/theme';
import type { Filter } from './model';

const OPTIONS: { value: Filter; label: string }[] = [
  { value: 'all', label: 'Tất cả' },
  { value: 'active', label: 'Chưa xong' },
  { value: 'done', label: 'Đã xong' },
];

export function FilterBar({ value, onChange }: { value: Filter; onChange: (f: Filter) => void }) {
  return (
    <View style={styles.bar} accessibilityRole="tablist">
      {OPTIONS.map((o) => {
        const selected = o.value === value;
        return (
          <Pressable
            key={o.value}
            accessibilityRole="tab"
            accessibilityState={{ selected }}
            onPress={() => onChange(o.value)}
            style={[styles.chip, selected && styles.chipSelected]}
          >
            <Text style={[styles.label, selected && styles.labelSelected]}>{o.label}</Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  bar: { flexDirection: 'row', gap: spacing.sm, paddingHorizontal: spacing.lg },
  chip: {
    paddingVertical: spacing.xs + 2,
    paddingHorizontal: spacing.md,
    borderRadius: 999,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.card,
  },
  chipSelected: { backgroundColor: colors.primary, borderColor: colors.primary },
  label: { color: colors.text },
  labelSelected: { color: '#fff', fontWeight: '600' },
});
