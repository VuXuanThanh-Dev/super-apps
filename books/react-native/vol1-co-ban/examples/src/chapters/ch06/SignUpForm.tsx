import { useRef, useState } from 'react';
import { KeyboardAvoidingView, Platform, Pressable, ScrollView, StyleSheet, Switch, Text, TextInput, View } from 'react-native';
import { isValid, validateSignUp, type SignUpErrors, type SignUpValues } from './validation';

const EMPTY: SignUpValues = { email: '', password: '', confirm: '', acceptTerms: false };

export function SignUpForm({ onSubmit }: { onSubmit: (v: SignUpValues) => void }) {
  const [values, setValues] = useState(EMPTY);
  const [touched, setTouched] = useState<Partial<Record<keyof SignUpValues, boolean>>>({});
  const [submitted, setSubmitted] = useState(false);
  const passwordRef = useRef<TextInput>(null);
  const confirmRef = useRef<TextInput>(null);

  const errors: SignUpErrors = validateSignUp(values); // tính lại mỗi lần render: đơn giản, đủ nhanh
  const show = (k: keyof SignUpValues) => (submitted || touched[k]) && errors[k];
  const set = <K extends keyof SignUpValues>(k: K, v: SignUpValues[K]) => setValues((prev) => ({ ...prev, [k]: v }));
  const blur = (k: keyof SignUpValues) => () => setTouched((t) => ({ ...t, [k]: true }));

  const submit = () => {
    setSubmitted(true);
    if (isValid(errors)) onSubmit(values);
  };

  return (
    <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView contentContainerStyle={styles.form} keyboardShouldPersistTaps="handled">
        <TextInput
          accessibilityLabel="Email"
          placeholder="email@vidu.com"
          value={values.email}
          onChangeText={(t) => set('email', t)}
          onBlur={blur('email')}
          autoCapitalize="none"
          autoComplete="email"
          keyboardType="email-address"
          returnKeyType="next"
          onSubmitEditing={() => passwordRef.current?.focus()}
          style={styles.input}
        />
        {show('email') ? <Text style={styles.error}>{errors.email}</Text> : null}
        <TextInput
          ref={passwordRef}
          accessibilityLabel="Mật khẩu"
          placeholder="Mật khẩu"
          value={values.password}
          onChangeText={(t) => set('password', t)}
          onBlur={blur('password')}
          secureTextEntry
          textContentType="newPassword"
          returnKeyType="next"
          onSubmitEditing={() => confirmRef.current?.focus()}
          style={styles.input}
        />
        {show('password') ? <Text style={styles.error}>{errors.password}</Text> : null}
        <TextInput
          ref={confirmRef}
          accessibilityLabel="Nhập lại mật khẩu"
          placeholder="Nhập lại mật khẩu"
          value={values.confirm}
          onChangeText={(t) => set('confirm', t)}
          onBlur={blur('confirm')}
          secureTextEntry
          returnKeyType="done"
          onSubmitEditing={submit}
          style={styles.input}
        />
        {show('confirm') ? <Text style={styles.error}>{errors.confirm}</Text> : null}
        <View style={styles.row}>
          <Switch accessibilityLabel="Đồng ý điều khoản" value={values.acceptTerms} onValueChange={(v) => set('acceptTerms', v)} />
          <Text>Tôi đồng ý điều khoản</Text>
        </View>
        {show('acceptTerms') ? <Text style={styles.error}>{errors.acceptTerms}</Text> : null}
        <Pressable accessibilityRole="button" onPress={submit} style={styles.button}>
          <Text style={styles.buttonText}>Đăng ký</Text>
        </Pressable>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  form: { padding: 16, gap: 8 },
  input: { borderWidth: 1, borderColor: '#d1d5db', borderRadius: 8, padding: 12, fontSize: 16 },
  error: { color: '#dc2626' },
  row: { flexDirection: 'row', alignItems: 'center', gap: 8, marginVertical: 8 },
  button: { backgroundColor: '#2563eb', padding: 14, borderRadius: 10, alignItems: 'center' },
  buttonText: { color: '#fff', fontWeight: '700', fontSize: 16 },
});
