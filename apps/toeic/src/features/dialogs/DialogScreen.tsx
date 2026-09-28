import { Stack } from 'expo-router';
import { useState } from 'react';
import { Pressable, Text, View } from 'react-native';
import { Button, Card, Chip, Muted, Screen, styles as ui } from '@/components/ui';
import { dialogs } from '@/data';
import { speak } from '@/features/lookup/speech';
import { TappableText } from '@/features/lookup/TappableText';
import { useTheme } from '@/features/theme/ThemeProvider';

/** Roleplay: pick your role. The other person's lines are shown (and can be
 * played with text-to-speech); your lines are hidden until you say them and tap. */
export function DialogScreen({ id }: { id: string }) {
  const { palette } = useTheme();
  const dialog = dialogs.find((d) => d.id === id);
  const speakers = dialog ? [...new Set(dialog.lines.map((l) => l.speaker))] : [];
  const [role, setRole] = useState<string | null>(null);
  const [revealed, setRevealed] = useState<Set<number>>(new Set());
  if (!dialog) {
    return (
      <Screen>
        <Muted>Dialog not found.</Muted>
      </Screen>
    );
  }
  return (
    <Screen>
      <Stack.Screen options={{ title: dialog.title }} />
      <TappableText text={dialog.setting} style={{ color: palette.muted }} />
      <Muted>Choose your role (hide your lines and practice speaking):</Muted>
      <View style={ui.row}>
        <Chip label="Just read" selected={role === null} onPress={() => setRole(null)} testID="role-none" />
        {speakers.map((s) => (
          <Chip key={s} label={s} selected={role === s} onPress={() => { setRole(s); setRevealed(new Set()); }} testID={`role-${s}`} />
        ))}
      </View>
      {dialog.lines.map((line, i) => {
        const mine = role !== null && line.speaker === role;
        const hidden = mine && !revealed.has(i);
        return (
          <Card key={i} style={mine ? { borderColor: palette.primary, borderWidth: 1 } : undefined}>
            <View style={[ui.row, { justifyContent: 'space-between' }]}>
              <Text style={{ color: mine ? palette.primary : palette.accent, fontWeight: '700' }}>
                {line.speaker}
                {mine ? ' (you)' : ''}
              </Text>
              <Pressable onPress={() => speak(line.text)} accessibilityLabel={`Play line ${i + 1}`} hitSlop={8}>
                <Text style={{ color: palette.primary }}>▶</Text>
              </Pressable>
            </View>
            {hidden ? (
              <Button
                title="Say it, then tap to check"
                variant="outline"
                onPress={() => setRevealed((r) => new Set(r).add(i))}
                testID={`reveal-${i}`}
              />
            ) : (
              <TappableText text={line.text} testID={`line-${i}`} />
            )}
          </Card>
        );
      })}
      <Button title="▶ Play whole dialog" variant="outline" onPress={() => speak(dialog.lines.map((l) => l.text).join(' '))} />
    </Screen>
  );
}
