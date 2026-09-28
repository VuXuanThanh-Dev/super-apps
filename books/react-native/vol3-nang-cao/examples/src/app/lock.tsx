import { useEffect, useState } from 'react';
import { StyleSheet, Text, TextInput, View } from 'react-native';
import { AppButton } from '@/components/AppButton';
import { isLocked, secondsLeft } from '@/security/pin';
import { useAuth } from '@/state/auth';
import { colors, spacing } from '@/theme';

function useNow(active: boolean) {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    if (!active) return;
    const id = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(id);
  }, [active]);
  return now;
}

export default function LockScreen() {
  const status = useAuth((s) => s.status);
  const lock = useAuth((s) => s.lock);
  const setPin = useAuth((s) => s.setPin);
  const unlock = useAuth((s) => s.unlock);
  const [pin, setPinText] = useState('');
  const [confirm, setConfirm] = useState('');
  const [error, setError] = useState<string | null>(null);
  const now = useNow(lock.lockedUntil !== null);
  const locked = isLocked(lock, now);
  const creating = status === 'no-pin';

  const submit = async () => {
    setError(null);
    if (creating) {
      if (pin !== confirm) return setError('Hai lần nhập PIN không khớp');
      const err = await setPin(pin);
      if (err) setError(err);
    } else {
      const ok = await unlock(pin);
      if (!ok) setError('PIN không đúng');
    }
    setPinText('');
    setConfirm('');
  };

  return (
    <View style={styles.screen}>
      <Text style={styles.title}>🔒 Sổ Ghi Chú Bảo Mật</Text>
      <Text style={styles.subtitle}>{creating ? 'Tạo mã PIN (4–6 chữ số)' : 'Nhập mã PIN để mở'}</Text>
      <TextInput
        accessibilityLabel="Mã PIN"
        value={pin}
        onChangeText={setPinText}
        keyboardType="number-pad"
        secureTextEntry
        maxLength={6}
        editable={!locked}
        style={styles.input}
      />
      {creating ? (
        <TextInput
          accessibilityLabel="Nhập lại mã PIN"
          value={confirm}
          onChangeText={setConfirm}
          keyboardType="number-pad"
          secureTextEntry
          maxLength={6}
          style={styles.input}
        />
      ) : null}
      {error ? (
        <Text accessibilityRole="alert" style={styles.error}>
          {error}
        </Text>
      ) : null}
      {locked ? <Text style={styles.error}>Sai quá nhiều lần. Thử lại sau {secondsLeft(lock, now)} giây.</Text> : null}
      <AppButton title={creating ? 'Tạo PIN' : 'Mở khóa'} onPress={submit} disabled={locked || pin.length < 4} />
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, justifyContent: 'center', padding: spacing.xl, gap: spacing.md, backgroundColor: colors.background },
  title: { fontSize: 24, fontWeight: '800', textAlign: 'center' },
  subtitle: { textAlign: 'center', color: colors.muted },
  input: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 10,
    padding: spacing.md,
    fontSize: 24,
    letterSpacing: 8,
    textAlign: 'center',
    backgroundColor: colors.card,
  },
  error: { color: colors.danger, textAlign: 'center' },
});
