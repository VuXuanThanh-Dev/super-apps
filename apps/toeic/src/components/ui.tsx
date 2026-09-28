import type { ReactNode } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View, type StyleProp, type TextStyle, type ViewStyle } from 'react-native';
import { useTheme } from '@/features/theme/ThemeProvider';

export function Screen({ children, scroll = true }: { children: ReactNode; scroll?: boolean }) {
  const { palette } = useTheme();
  if (!scroll) return <View style={[styles.screen, { backgroundColor: palette.background }]}>{children}</View>;
  return (
    <ScrollView
      style={{ backgroundColor: palette.background }}
      contentContainerStyle={styles.screenContent}
      keyboardShouldPersistTaps="handled"
    >
      {children}
    </ScrollView>
  );
}

export function Card({ children, style }: { children: ReactNode; style?: StyleProp<ViewStyle> }) {
  const { palette } = useTheme();
  return (
    <View style={[styles.card, { backgroundColor: palette.card, borderColor: palette.border }, style]}>{children}</View>
  );
}

export function Title({ children, style, testID }: { children: ReactNode; style?: StyleProp<TextStyle>; testID?: string }) {
  const { palette } = useTheme();
  return <Text testID={testID} style={[styles.title, { color: palette.text }, style]}>{children}</Text>;
}

export function Body({ children, style, testID }: { children: ReactNode; style?: StyleProp<TextStyle>; testID?: string }) {
  const { palette } = useTheme();
  return <Text testID={testID} style={[styles.body, { color: palette.text }, style]}>{children}</Text>;
}

export function Muted({ children, style, testID }: { children: ReactNode; style?: StyleProp<TextStyle>; testID?: string }) {
  const { palette } = useTheme();
  return <Text testID={testID} style={[styles.muted, { color: palette.muted }, style]}>{children}</Text>;
}

export function Button({
  title,
  onPress,
  variant = 'primary',
  disabled,
  testID,
  style,
}: {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'outline' | 'danger';
  disabled?: boolean;
  testID?: string;
  style?: StyleProp<ViewStyle>;
}) {
  const { palette } = useTheme();
  const bg = variant === 'primary' ? palette.primary : variant === 'danger' ? palette.danger : 'transparent';
  const fg = variant === 'outline' ? palette.primary : palette.primaryText;
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={title}
      testID={testID}
      disabled={disabled}
      onPress={onPress}
      style={({ pressed }) => [
        styles.button,
        { backgroundColor: bg, borderColor: palette.primary, opacity: disabled ? 0.4 : pressed ? 0.7 : 1 },
        style,
      ]}
    >
      <Text style={[styles.buttonText, { color: fg }]}>{title}</Text>
    </Pressable>
  );
}

export function Chip({
  label,
  onPress,
  selected,
  testID,
}: {
  label: string;
  onPress?: () => void;
  selected?: boolean;
  testID?: string;
}) {
  const { palette } = useTheme();
  return (
    <Pressable
      accessibilityRole="button"
      testID={testID}
      onPress={onPress}
      style={[
        styles.chip,
        { borderColor: palette.primary, backgroundColor: selected ? palette.primary : 'transparent' },
      ]}
    >
      <Text style={{ color: selected ? palette.primaryText : palette.primary, fontSize: 14 }}>{label}</Text>
    </Pressable>
  );
}

export const styles = StyleSheet.create({
  screen: { flex: 1, padding: 16 },
  screenContent: { padding: 16, paddingBottom: 48, gap: 12 },
  card: { borderWidth: StyleSheet.hairlineWidth, borderRadius: 12, padding: 14, gap: 6 },
  title: { fontSize: 20, fontWeight: '700' },
  body: { fontSize: 16, lineHeight: 24 },
  muted: { fontSize: 14, lineHeight: 20 },
  button: { borderWidth: 1, borderRadius: 10, paddingVertical: 12, paddingHorizontal: 16, alignItems: 'center' },
  buttonText: { fontSize: 16, fontWeight: '600' },
  chip: { borderWidth: 1, borderRadius: 16, paddingVertical: 6, paddingHorizontal: 12, marginRight: 8, marginBottom: 8 },
  row: { flexDirection: 'row', alignItems: 'center', flexWrap: 'wrap' },
});
