import { useState } from 'react';
import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { AppButton } from '@/components/AppButton';
import { colors, spacing } from '@/theme';
import { PRIORITY_LABEL, validateTaskInput, type Priority, type TaskErrors, type TaskInput } from './model';

interface TaskFormProps {
  initial?: TaskInput;
  submitLabel?: string;
  onSubmit: (input: TaskInput) => void;
}

const PRIORITIES: Priority[] = ['low', 'medium', 'high'];

// Form "controlled": state của từng ô nằm trong React, giống Reactive Forms
// nhưng không cần FormGroup — chỉ là useState + hàm validate thuần.
export function TaskForm({
  initial = { title: '', note: '', priority: 'medium' },
  submitLabel = 'Lưu',
  onSubmit,
}: TaskFormProps) {
  const [values, setValues] = useState<TaskInput>(initial);
  const [errors, setErrors] = useState<TaskErrors>({});
  const [submitted, setSubmitted] = useState(false);

  const setField = <K extends keyof TaskInput>(key: K, value: TaskInput[K]) => {
    const next = { ...values, [key]: value };
    setValues(next);
    if (submitted) setErrors(validateTaskInput(next)); // chỉ báo lỗi realtime sau lần bấm đầu
  };

  const handleSubmit = () => {
    setSubmitted(true);
    const found = validateTaskInput(values);
    setErrors(found);
    if (Object.keys(found).length === 0) onSubmit(values);
  };

  return (
    <View style={styles.form}>
      <Text style={styles.label} nativeID="titleLabel">
        Tiêu đề
      </Text>
      <TextInput
        accessibilityLabel="Tiêu đề"
        aria-labelledby="titleLabel"
        value={values.title}
        onChangeText={(t) => setField('title', t)}
        placeholder="Ví dụ: Học Flexbox"
        returnKeyType="next"
        style={[styles.input, errors.title && styles.inputError]}
      />
      {errors.title ? <Text style={styles.error}>{errors.title}</Text> : null}

      <Text style={styles.label}>Ghi chú</Text>
      <TextInput
        accessibilityLabel="Ghi chú"
        value={values.note}
        onChangeText={(t) => setField('note', t)}
        placeholder="Không bắt buộc"
        multiline
        style={[styles.input, styles.multiline]}
      />
      {errors.note ? <Text style={styles.error}>{errors.note}</Text> : null}

      <Text style={styles.label}>Mức ưu tiên</Text>
      <View style={styles.row} accessibilityRole="radiogroup">
        {PRIORITIES.map((p) => {
          const checked = values.priority === p;
          return (
            <Pressable
              key={p}
              accessibilityRole="radio"
              accessibilityState={{ checked }}
              onPress={() => setField('priority', p)}
              style={[styles.option, checked && styles.optionChecked]}
            >
              <Text style={checked ? styles.optionTextChecked : undefined}>{PRIORITY_LABEL[p]}</Text>
            </Pressable>
          );
        })}
      </View>

      <AppButton title={submitLabel} onPress={handleSubmit} />
    </View>
  );
}

const styles = StyleSheet.create({
  form: { gap: spacing.sm, padding: spacing.lg },
  label: { fontWeight: '600', color: colors.text, marginTop: spacing.sm },
  input: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 8,
    padding: spacing.md,
    fontSize: 16,
    backgroundColor: colors.card,
  },
  inputError: { borderColor: colors.danger },
  multiline: { minHeight: 80, textAlignVertical: 'top' },
  error: { color: colors.danger, fontSize: 13 },
  row: { flexDirection: 'row', gap: spacing.sm, marginBottom: spacing.lg },
  option: {
    flex: 1,
    alignItems: 'center',
    padding: spacing.sm,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: colors.border,
  },
  optionChecked: { backgroundColor: '#dbeafe', borderColor: colors.primary },
  optionTextChecked: { color: colors.primary, fontWeight: '700' },
});
