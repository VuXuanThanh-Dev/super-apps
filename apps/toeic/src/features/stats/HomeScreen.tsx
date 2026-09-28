import { useRouter } from 'expo-router';
import { Pressable, Text, View } from 'react-native';
import { Button, Card, Muted, Screen, Title, styles as ui } from '@/components/ui';
import { dataIndex, isSampleData } from '@/data';
import { useLookup } from '@/features/lookup/LookupProvider';
import { TappableText } from '@/features/lookup/TappableText';
import { useTheme } from '@/features/theme/ThemeProvider';
import { dayNumber, dayStringFromNumber } from '@/storage/dates';
import { useStoreQuery } from '@/storage/StoreProvider';
import { lastDays, summarize, weakWords } from './stats';

export function HomeScreen({ today = dayNumber() }: { today?: number }) {
  const router = useRouter();
  const { palette } = useTheme();
  const { open } = useLookup();
  const cards = useStoreQuery((s) => s.getCards(), []);
  const activity = useStoreQuery((s) => s.getActivity(), []);
  const stats = useStoreQuery((s) => s.getWordStats(), []);
  const summary = summarize(cards, activity, today);
  const weak = weakWords(stats, cards, 8);
  const week = lastDays(activity, today, 7);
  const max = Math.max(1, ...week.map((d) => d.count));
  const total = dataIndex.words.length;

  return (
    <Screen>
      {isSampleData ? (
        <Card style={{ borderColor: palette.accent }}>
          <Muted>Using the small SAMPLE dataset (private-data/ is empty). See README → “Build the private dataset”.</Muted>
        </Card>
      ) : null}
      <View style={[ui.row, { gap: 8 }]}>
        <Stat label="Words learned" value={`${summary.learned}`} sub={`of ${total}`} testID="stat-learned" />
        <Stat label="Streak" value={`${summary.streak} 🔥`} sub="days" testID="stat-streak" />
        <Stat label="Due today" value={`${summary.due}`} sub="cards" testID="stat-due" />
      </View>
      <Button title={summary.due > 0 ? `Review ${summary.due} due cards` : 'Study new words'} onPress={() => router.push('/flashcards?scope=all')} testID="home-study" />
      <Card>
        <Title>Last 7 days</Title>
        <View style={{ flexDirection: 'row', alignItems: 'flex-end', height: 80, gap: 6 }}>
          {week.map((d) => (
            <View key={d.day} style={{ flex: 1, alignItems: 'center' }}>
              <View style={{ width: '70%', height: Math.max(2, (d.count / max) * 60), backgroundColor: palette.primary, borderRadius: 4 }} />
              <Text style={{ color: palette.muted, fontSize: 10 }}>{dayStringFromNumber(d.day).slice(5)}</Text>
            </View>
          ))}
        </View>
        <Muted>
          {summary.totalReviews} reviews · {summary.totalQuizzes} quizzes · {summary.studied} words started
        </Muted>
      </Card>
      <Card>
        <Title>Weak words</Title>
        {weak.length === 0 ? <Muted testID="weak-empty">No weak words yet. Wrong answers in quizzes and “Again” in flashcards show up here.</Muted> : null}
        {weak.map((w) => (
          <Pressable key={w.word} onPress={() => open(w.word)} testID={`weak-${w.word}`}>
            <Text style={{ color: palette.text, fontSize: 16 }}>
              {w.word} <Text style={{ color: palette.danger }}>✗{w.wrong}</Text>{' '}
              <Text style={{ color: palette.muted }}>({Math.round(w.accuracy * 100)}% correct)</Text>
            </Text>
          </Pressable>
        ))}
        {weak.length > 0 ? <Button title="Practice weak words" variant="outline" onPress={() => router.push('/flashcards?scope=weak')} /> : null}
      </Card>
      <Card>
        <Title>Tip</Title>
        <TappableText text="Tap any word on any screen to see its meaning, word family and collocations. It works offline." />
      </Card>
      <Button title="Settings (dark mode)" variant="outline" onPress={() => router.push('/settings')} testID="open-settings" />
    </Screen>
  );
}

function Stat({ label, value, sub, testID }: { label: string; value: string; sub: string; testID?: string }) {
  const { palette } = useTheme();
  return (
    <Card style={{ flex: 1, alignItems: 'center' }}>
      <Text style={{ color: palette.text, fontSize: 24, fontWeight: '800' }} testID={testID}>
        {value}
      </Text>
      <Muted>{label}</Muted>
      <Muted style={{ fontSize: 12 }}>{sub}</Muted>
    </Card>
  );
}
