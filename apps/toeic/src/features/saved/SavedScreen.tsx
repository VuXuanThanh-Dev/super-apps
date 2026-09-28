import { useRouter } from 'expo-router';
import { useEffect, useState } from 'react';
import { Pressable, Switch, Text, View } from 'react-native';
import { Button, Card, Muted, Screen, Title, styles as ui } from '@/components/ui';
import { dataIndex } from '@/data';
import { useLookup } from '@/features/lookup/LookupProvider';
import { dueCount } from '@/features/stats/stats';
import { useTheme } from '@/features/theme/ThemeProvider';
import { dayNumber } from '@/storage/dates';
import { useStore, useStoreQuery } from '@/storage/StoreProvider';
import { DEFAULT_REMINDER, applyReminder, formatTime, loadReminder, reminderBody, type ReminderSetting } from './reminders';

export function SavedScreen() {
  const router = useRouter();
  const { palette } = useTheme();
  const { open } = useLookup();
  const { store, bump } = useStore();
  const saved = useStoreQuery((s) => s.getSavedWords(), []);
  const cards = useStoreQuery((s) => s.getCards(), []);
  const [reminder, setReminder] = useState<ReminderSetting>(DEFAULT_REMINDER);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    void loadReminder(store).then(setReminder);
  }, [store]);

  const update = async (next: { enabled: boolean; hour: number; minute: number }) => {
    setBusy(true);
    try {
      const body = reminderBody(saved.length, dueCount(cards, dayNumber()));
      setReminder(await applyReminder(store, next, body));
    } finally {
      setBusy(false);
    }
  };
  const shiftHour = (d: number) => void update({ ...reminder, hour: (reminder.hour + d + 24) % 24 });

  return (
    <Screen>
      <Card>
        <Title>Daily review reminder</Title>
        <View style={[ui.row, { justifyContent: 'space-between' }]}>
          <Text style={{ color: palette.text, fontSize: 16 }}>Remind me every day at {formatTime(reminder.hour, reminder.minute)}</Text>
          <Switch
            value={reminder.enabled}
            disabled={busy}
            onValueChange={(v) => void update({ ...reminder, enabled: v })}
            testID="reminder-switch"
          />
        </View>
        <View style={[ui.row, { gap: 8 }]}>
          <Button title="− 1 hour" variant="outline" onPress={() => shiftHour(-1)} disabled={busy} testID="hour-minus" />
          <Button title="+ 1 hour" variant="outline" onPress={() => shiftHour(1)} disabled={busy} testID="hour-plus" />
        </View>
        <Muted>Local notification on this phone (no internet needed).</Muted>
      </Card>
      <View style={[ui.row, { justifyContent: 'space-between' }]}>
        <Title>My saved words ({saved.length})</Title>
      </View>
      {saved.length > 0 ? (
        <Button title="Review saved words (flashcards)" onPress={() => router.push('/flashcards?scope=saved')} testID="review-saved" />
      ) : (
        <Muted>No saved words yet. Tap any word in the app, then “Save to my list”.</Muted>
      )}
      {saved.map((s) => {
        const w = dataIndex.wordsByText.get(s.word);
        return (
          <Card key={s.word}>
            <View style={[ui.row, { justifyContent: 'space-between' }]}>
              <Pressable onPress={() => open(s.word)} style={{ flex: 1 }} testID={`saved-${s.word}`}>
                <Text style={{ color: palette.text, fontSize: 17, fontWeight: '700' }}>{s.word}</Text>
                {w?.vi ? <Text style={{ color: palette.accent }}>{w.vi}</Text> : null}
              </Pressable>
              <Button
                title="Remove"
                variant="outline"
                onPress={async () => {
                  await store.setSaved(s.word, false);
                  bump();
                }}
                testID={`remove-${s.word}`}
              />
            </View>
          </Card>
        );
      })}
    </Screen>
  );
}
