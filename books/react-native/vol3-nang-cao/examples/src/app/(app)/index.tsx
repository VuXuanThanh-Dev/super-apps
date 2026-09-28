import { FlashList } from '@shopify/flash-list';
import { Link, Stack, useRouter } from 'expo-router';
import { useCallback, useMemo, useState } from 'react';
import { StyleSheet, Text, TextInput, View } from 'react-native';
import { NoteRow } from '@/components/NoteRow';
import { useNotes } from '@/state/notes';
import { colors, spacing } from '@/theme';

export default function NotesScreen() {
  const notes = useNotes((s) => s.notes);
  const loaded = useNotes((s) => s.loaded);
  const router = useRouter();
  const [query, setQuery] = useState('');
  const visible = useMemo(() => {
    const q = query.trim().toLowerCase();
    return q ? notes.filter((n) => n.title.toLowerCase().includes(q) || n.body.toLowerCase().includes(q)) : notes;
  }, [notes, query]);
  const open = useCallback((id: string) => router.push({ pathname: '/note/[id]', params: { id } }), [router]);

  return (
    <View style={styles.screen}>
      <Stack.Screen
        options={{
          headerRight: () => (
            <Link href="/settings" accessibilityLabel="Cài đặt">
              <Text style={{ fontSize: 20 }}>⚙️</Text>
            </Link>
          ),
        }}
      />
      <TextInput accessibilityLabel="Tìm ghi chú" placeholder="Tìm..." value={query} onChangeText={setQuery} style={styles.search} />
      {/* FlashList v2: không cần estimatedItemSize; tái sử dụng (recycle) view khi cuộn. */}
      <FlashList
        data={visible}
        keyExtractor={(n) => n.id}
        renderItem={({ item }) => <NoteRow note={item} onOpen={open} />}
        ListEmptyComponent={<Text style={styles.empty}>{loaded ? 'Chưa có ghi chú.' : 'Đang tải...'}</Text>}
      />
      <Link href={{ pathname: '/note/[id]', params: { id: 'new' } }} style={styles.fab} accessibilityRole="button" accessibilityLabel="Thêm ghi chú">
        ＋
      </Link>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.background },
  search: { margin: spacing.lg, padding: spacing.md, borderRadius: 10, borderWidth: 1, borderColor: colors.border, backgroundColor: colors.card },
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
