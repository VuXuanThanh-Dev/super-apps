import { memo } from 'react';
import { Pressable, StyleSheet, Text } from 'react-native';
import type { Note } from '@/notes/model';
import { colors, spacing } from '@/theme';

function NoteRowBase({ note, onOpen }: { note: Note; onOpen: (id: string) => void }) {
  return (
    <Pressable accessibilityRole="button" accessibilityLabel={`Mở ${note.title}`} onPress={() => onOpen(note.id)} style={styles.row}>
      <Text style={styles.title} numberOfLines={1}>
        {note.title}
      </Text>
      <Text style={styles.body} numberOfLines={1}>
        {note.body || '(trống)'}
      </Text>
    </Pressable>
  );
}

// memo + onOpen ổn định → khi gõ tìm kiếm, dòng không đổi sẽ không render lại.
export const NoteRow = memo(NoteRowBase);

const styles = StyleSheet.create({
  row: { padding: spacing.lg, backgroundColor: colors.card, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: colors.border },
  title: { fontSize: 16, fontWeight: '600', color: colors.text },
  body: { color: colors.muted, marginTop: 2 },
});
