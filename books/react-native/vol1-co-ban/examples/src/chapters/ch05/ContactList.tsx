import { useMemo, useState } from 'react';
import { FlatList, SectionList, StyleSheet, Text, TextInput, View } from 'react-native';
import { CONTACTS, groupByLetter, searchContacts, type Contact } from './contacts';

function Row({ contact }: { contact: Contact }) {
  return (
    <View style={styles.row}>
      <Text style={styles.name}>{contact.name}</Text>
      <Text style={styles.phone}>{contact.phone}</Text>
    </View>
  );
}

// FlatList: chỉ render các dòng đang thấy trên màn hình (virtualization).
export function ContactList({ contacts = CONTACTS }: { contacts?: Contact[] }) {
  const [query, setQuery] = useState('');
  const data = useMemo(() => searchContacts(contacts, query), [contacts, query]);
  return (
    <View style={{ flex: 1 }}>
      <TextInput accessibilityLabel="Tìm liên hệ" placeholder="Tìm tên hoặc số" value={query} onChangeText={setQuery} style={styles.search} />
      <FlatList
        data={data}
        keyExtractor={(c) => c.id}
        renderItem={({ item }) => <Row contact={item} />}
        ItemSeparatorComponent={() => <View style={styles.sep} />}
        ListEmptyComponent={<Text style={styles.empty}>Không tìm thấy</Text>}
      />
    </View>
  );
}

// SectionList: danh sách có tiêu đề nhóm (A, B, D...).
export function ContactSections({ contacts = CONTACTS }: { contacts?: Contact[] }) {
  const sections = useMemo(() => groupByLetter(contacts), [contacts]);
  return (
    <SectionList
      sections={sections}
      keyExtractor={(c) => c.id}
      renderItem={({ item }) => <Row contact={item} />}
      renderSectionHeader={({ section }) => (
        <Text accessibilityRole="header" style={styles.header}>
          {section.title}
        </Text>
      )}
      stickySectionHeadersEnabled
    />
  );
}

const styles = StyleSheet.create({
  search: { margin: 12, padding: 10, borderWidth: 1, borderColor: '#e5e7eb', borderRadius: 8 },
  row: { paddingHorizontal: 16, paddingVertical: 12, backgroundColor: '#fff' },
  name: { fontSize: 16 },
  phone: { color: '#6b7280' },
  sep: { height: StyleSheet.hairlineWidth, backgroundColor: '#e5e7eb' },
  empty: { textAlign: 'center', marginTop: 24, color: '#6b7280' },
  header: { backgroundColor: '#f3f4f6', paddingHorizontal: 16, paddingVertical: 4, fontWeight: '700' },
});
