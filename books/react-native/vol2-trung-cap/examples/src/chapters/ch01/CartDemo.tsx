import { useReducer } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { counterReducer } from './counterReducer';
import { formatVnd, selectCount, selectTotal, useCart } from './cartStore';

const PRODUCTS = [
  { id: 'ca-phe', name: 'Cà phê sữa đá', price: 29000 },
  { id: 'banh-mi', name: 'Bánh mì', price: 25000 },
];

function CartBadge() {
  const count = useCart(selectCount); // chỉ render lại khi số lượng đổi
  return <Text accessibilityLabel="Số món">🛒 {count}</Text>;
}

function CartTotal() {
  const total = useCart(selectTotal);
  return <Text accessibilityLabel="Tổng tiền">Tổng: {formatVnd(total)}</Text>;
}

export function CartDemo() {
  const add = useCart((s) => s.add);
  const clear = useCart((s) => s.clear);
  const [likes, dispatch] = useReducer(counterReducer, 0);

  return (
    <View style={styles.box}>
      <CartBadge />
      {PRODUCTS.map((p) => (
        <Pressable key={p.id} accessibilityRole="button" onPress={() => add(p)} style={styles.btn}>
          <Text>
            Thêm {p.name} ({formatVnd(p.price)})
          </Text>
        </Pressable>
      ))}
      <CartTotal />
      <Pressable accessibilityRole="button" onPress={clear} style={styles.btn}>
        <Text>Xóa giỏ</Text>
      </Pressable>
      <Text style={{ marginTop: 16, fontWeight: '700' }}>useReducer (state cục bộ)</Text>
      <Pressable accessibilityRole="button" onPress={() => dispatch({ type: 'inc' })} style={styles.btn}>
        <Text>👍 {likes}</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  box: { padding: 16, gap: 8 },
  btn: { padding: 12, borderRadius: 8, backgroundColor: '#e5e7eb' },
});
