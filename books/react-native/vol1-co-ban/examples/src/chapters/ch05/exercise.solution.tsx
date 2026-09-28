import { useCallback, useMemo, useState } from 'react';
import { FlatList, Pressable, Text, View } from 'react-native';
import { CONTACTS, type Contact } from './contacts';

export type SortDir = 'asc' | 'desc';

export function sortContacts(list: Contact[], dir: SortDir): Contact[] {
  const sorted = [...list].sort((a, b) => a.name.localeCompare(b.name, 'vi'));
  return dir === 'asc' ? sorted : sorted.reverse();
}

// Lời giải bài tập Chương 5: nút đổi thứ tự A→Z / Z→A + kéo để làm mới (pull-to-refresh).
export function SortableContacts({ load = async () => CONTACTS }: { load?: () => Promise<Contact[]> }) {
  const [dir, setDir] = useState<SortDir>('asc');
  const [items, setItems] = useState(CONTACTS);
  const [refreshing, setRefreshing] = useState(false);
  const data = useMemo(() => sortContacts(items, dir), [items, dir]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    setItems(await load());
    setRefreshing(false);
  }, [load]);

  return (
    <View style={{ flex: 1 }}>
      <Pressable accessibilityRole="button" onPress={() => setDir((d) => (d === 'asc' ? 'desc' : 'asc'))}>
        <Text style={{ padding: 12 }}>{dir === 'asc' ? 'Sắp xếp: A→Z' : 'Sắp xếp: Z→A'}</Text>
      </Pressable>
      <FlatList
        testID="sortable-list"
        data={data}
        keyExtractor={(c) => c.id}
        renderItem={({ item }) => <Text style={{ padding: 12 }}>{item.name}</Text>}
        refreshing={refreshing}
        onRefresh={onRefresh}
      />
    </View>
  );
}
