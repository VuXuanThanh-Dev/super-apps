import { StyleSheet, Text, View, useWindowDimensions } from 'react-native';

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

// Lời giải Bài 2: 3 cột khi màn hình rộng ≥ 768 (iPad), 2 cột khi hẹp hơn.
export function columnsFor(width: number): 2 | 3 {
  return width >= 768 ? 3 : 2;
}

// Tách phần "vẽ" (nhận width qua props) khỏi phần "đọc môi trường" (hook) → dễ test.
export function ResponsiveGrid({ items }: { items: string[] }) {
  const { width } = useWindowDimensions(); // tự cập nhật khi xoay màn hình
  return <ResponsiveGridView items={items} width={width} />;
}

export function ResponsiveGridView({ items, width }: { items: string[]; width: number }) {
  const cellWidth = columnsFor(width) === 3 ? '31%' : '48%';
  return (
    <View style={styles.grid}>
      {items.map((label) => (
        <View key={label} testID="rcell" style={[styles.cell, { width: cellWidth }]}>
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
