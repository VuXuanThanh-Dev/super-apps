import { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { ALIGN, DIRECTIONS, JUSTIFY, nextOption, toStyle, type FlexState } from './flex';

// Bấm các nút để thấy Flexbox thay đổi. Khác web: mặc định flexDirection là 'column'.
export function FlexPlayground() {
  const [state, setState] = useState<FlexState>({
    flexDirection: 'column',
    justifyContent: 'flex-start',
    alignItems: 'stretch',
  });

  return (
    <View style={styles.screen}>
      <View style={styles.controls}>
        <Pressable accessibilityRole="button" style={styles.btn} onPress={() => setState((s) => ({ ...s, flexDirection: nextOption(DIRECTIONS, s.flexDirection) }))}>
          <Text>flexDirection: {state.flexDirection}</Text>
        </Pressable>
        <Pressable accessibilityRole="button" style={styles.btn} onPress={() => setState((s) => ({ ...s, justifyContent: nextOption(JUSTIFY, s.justifyContent) }))}>
          <Text>justifyContent: {state.justifyContent}</Text>
        </Pressable>
        <Pressable accessibilityRole="button" style={styles.btn} onPress={() => setState((s) => ({ ...s, alignItems: nextOption(ALIGN, s.alignItems) }))}>
          <Text>alignItems: {state.alignItems}</Text>
        </Pressable>
      </View>
      <View testID="flex-box" style={[styles.box, toStyle(state)]}>
        <View style={[styles.item, { backgroundColor: '#f87171' }]} />
        <View style={[styles.item, { backgroundColor: '#60a5fa' }]} />
        <View style={[styles.item, { backgroundColor: '#34d399' }]} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, padding: 16, gap: 12 },
  controls: { gap: 8 },
  btn: { padding: 10, borderRadius: 8, backgroundColor: '#e5e7eb' },
  box: { flex: 1, borderWidth: 2, borderColor: '#9ca3af', borderRadius: 8, padding: 8, gap: 8, minHeight: 240 },
  item: { minWidth: 50, minHeight: 50, borderRadius: 6 },
});
