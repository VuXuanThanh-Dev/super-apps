import { Alert, Text, View } from 'react-native';
import { Button, Card, Chip, Muted, Screen, Title, styles as ui } from '@/components/ui';
import { dataIndex, isSampleData } from '@/data';
import { useStore } from '@/storage/StoreProvider';
import type { ThemePreference } from './colors';
import { useTheme } from './ThemeProvider';

const OPTIONS: { value: ThemePreference; label: string }[] = [
  { value: 'system', label: 'System' },
  { value: 'light', label: 'Light' },
  { value: 'dark', label: 'Dark' },
];

export function SettingsScreen() {
  const { preference, setPreference, palette, scheme } = useTheme();
  const { store, bump } = useStore();
  return (
    <Screen>
      <Card>
        <Title>Appearance · Giao diện</Title>
        <View style={ui.row}>
          {OPTIONS.map((o) => (
            <Chip key={o.value} label={o.label} selected={preference === o.value} onPress={() => setPreference(o.value)} testID={`theme-${o.value}`} />
          ))}
        </View>
        <Text style={{ color: palette.muted }} testID="theme-current">
          Current: {scheme}
        </Text>
      </Card>
      <Card>
        <Title>Data</Title>
        <Muted>
          Source: {isSampleData ? 'sample (hand-written, public)' : 'private books dataset'} · {dataIndex.topics.length} units ·{' '}
          {dataIndex.words.length} words · {dataIndex.dataset.collocations.length} collocations
        </Muted>
        <Muted>Extra data: CMUdict (IPA, BSD-style license), WordNet 3.0 (word forms, fallback meanings, WordNet license).</Muted>
      </Card>
      <Button
        title="Reset my progress"
        variant="danger"
        onPress={() =>
          Alert.alert('Reset?', 'Delete saved words, flashcards and stats on this phone?', [
            { text: 'Cancel', style: 'cancel' },
            { text: 'Reset', style: 'destructive', onPress: () => void store.reset().then(bump) },
          ])
        }
      />
    </Screen>
  );
}
