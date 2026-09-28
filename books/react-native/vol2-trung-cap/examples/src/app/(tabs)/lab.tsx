import { Link } from 'expo-router';
import { FlatList, StyleSheet, Text } from 'react-native';
import { LAB } from '@/chapters/registry';
import { colors, spacing } from '@/theme';

export default function LabScreen() {
  return (
    <FlatList
      data={LAB}
      keyExtractor={(e) => e.id}
      renderItem={({ item }) => (
        <Link href={{ pathname: '/lab/[id]', params: { id: item.id } }} style={styles.row}>
          <Text style={styles.text}>{item.title}</Text>
        </Link>
      )}
    />
  );
}

const styles = StyleSheet.create({
  row: { padding: spacing.lg, backgroundColor: colors.card, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: colors.border },
  text: { fontSize: 16, color: colors.text },
});
