import { Pressable, StyleSheet, Text, type PressableProps } from 'react-native';
import { colors, spacing } from '@/theme';

type Variant = 'primary' | 'danger' | 'ghost';

interface AppButtonProps extends Omit<PressableProps, 'children' | 'style'> {
  title: string;
  variant?: Variant;
}

// Nút bấm tái sử dụng. Pressable thay cho <button> của web.
export function AppButton({ title, variant = 'primary', disabled, ...rest }: AppButtonProps) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ disabled: !!disabled }}
      disabled={disabled}
      style={({ pressed }) => [
        styles.base,
        styles[variant],
        pressed && styles.pressed,
        disabled && styles.disabled,
      ]}
      {...rest}
    >
      <Text style={[styles.text, variant === 'ghost' && styles.ghostText]}>{title}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    borderRadius: 10,
    alignItems: 'center',
  },
  primary: { backgroundColor: colors.primary },
  danger: { backgroundColor: colors.danger },
  ghost: { backgroundColor: 'transparent', borderWidth: 1, borderColor: colors.border },
  pressed: { opacity: 0.7 },
  disabled: { opacity: 0.4 },
  text: { color: '#fff', fontWeight: '600', fontSize: 16 },
  ghostText: { color: colors.text },
});
