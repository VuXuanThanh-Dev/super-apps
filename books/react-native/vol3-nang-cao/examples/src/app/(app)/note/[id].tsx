import { Stack, useLocalSearchParams, useRouter } from 'expo-router';
import { useState } from 'react';
import { ScrollView, StyleSheet, Text, TextInput } from 'react-native';
import { AppButton } from '@/components/AppButton';
import { goBackOr } from '@/lib/navigation';
import { parseNoteId, validateNote } from '@/notes/model';
import { useNotes } from '@/state/notes';
import { colors, spacing } from '@/theme';

export default function NoteScreen() {
  const params = useLocalSearchParams<{ id: string }>();
  const id = parseNoteId(params.id); // bảo mật: kiểm tra tham số từ URL/deep link
  const isNew = id === 'new';
  const note = useNotes((s) => s.notes.find((n) => n.id === id));
  const add = useNotes((s) => s.add);
  const update = useNotes((s) => s.update);
  const remove = useNotes((s) => s.remove);
  const router = useRouter();
  const [title, setTitle] = useState(note?.title ?? '');
  const [body, setBody] = useState(note?.body ?? '');
  const [error, setError] = useState<string | null>(null);

  if (!id || (!isNew && !note)) return <Text style={styles.missing}>Không tìm thấy ghi chú.</Text>;

  const save = async () => {
    const err = validateNote({ title, body });
    if (err) return setError(err);
    if (isNew) await add({ title, body });
    else await update(id, { title, body });
    goBackOr(router, '/');
  };

  return (
    <ScrollView contentContainerStyle={styles.screen} keyboardShouldPersistTaps="handled">
      <Stack.Screen options={{ title: isNew ? 'Ghi chú mới' : 'Sửa ghi chú' }} />
      <TextInput accessibilityLabel="Tiêu đề" value={title} onChangeText={setTitle} placeholder="Tiêu đề" style={styles.input} />
      <TextInput
        accessibilityLabel="Nội dung"
        value={body}
        onChangeText={setBody}
        placeholder="Nội dung"
        multiline
        style={[styles.input, styles.body]}
      />
      {error ? <Text style={styles.error}>{error}</Text> : null}
      <AppButton title="Lưu" onPress={save} />
      {!isNew ? (
        <AppButton
          title="Xóa"
          variant="danger"
          onPress={async () => {
            await remove(id);
            goBackOr(router, '/');
          }}
        />
      ) : null}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  screen: { padding: spacing.lg, gap: spacing.md },
  input: { borderWidth: 1, borderColor: colors.border, borderRadius: 8, padding: spacing.md, fontSize: 16, backgroundColor: colors.card },
  body: { minHeight: 160, textAlignVertical: 'top' },
  error: { color: colors.danger },
  missing: { padding: spacing.xl, textAlign: 'center' },
});
