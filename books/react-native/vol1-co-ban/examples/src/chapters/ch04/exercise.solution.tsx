import { StyleSheet, Text, View } from 'react-native';

// Lời giải bài tập Chương 4: lưới 2 cột bằng flexWrap (không cần CSS Grid).
export function TwoColumnGrid({ items }: { items: string[] }) {
  return (
    <View testID="grid" style={styles.grid}>
      {items.map((label) => (
        <View key={label} testID="cell" style={styles.cell}>
          <Text>{label}</Text>
        </View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  grid: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between', rowGap: 12, padding: 12 },
  cell: { width: '48%', aspectRatio: 1, borderRadius: 12, backgroundColor: '#dbeafe', alignItems: 'center', justifyContent: 'center' },
});
