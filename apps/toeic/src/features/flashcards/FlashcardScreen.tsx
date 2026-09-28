import { Ionicons } from '@expo/vector-icons';
import { Stack } from 'expo-router';
import { useEffect, useState } from 'react';
import { Pressable, Text, View } from 'react-native';
import { Button, Card, Muted, Screen, Title, styles as ui } from '@/components/ui';
import { dataIndex } from '@/data';
import type { Word } from '@/data/types';
import { speak } from '@/features/lookup/speech';
import { TappableText } from '@/features/lookup/TappableText';
import { scopeLabel, wordsForScope, type Scope } from '@/features/practice/scope';
import { weakWords } from '@/features/stats/stats';
import { useTheme } from '@/features/theme/ThemeProvider';
import { dayNumber, localDayString } from '@/storage/dates';
import { useStore } from '@/storage/StoreProvider';
import type { Card as SrsCard } from '@/storage/types';
import { buildQueue } from './queue';
import { newCard, previewInterval, review, type Grade } from './sm2';

const NEW_PER_SESSION = 10;
const GRADES: { grade: Grade; label: string }[] = [
  { grade: 'again', label: 'Again' },
  { grade: 'hard', label: 'Hard' },
  { grade: 'good', label: 'Good' },
  { grade: 'easy', label: 'Easy' },
];

export function FlashcardScreen({ scope, today = dayNumber() }: { scope: Scope; today?: number }) {
  const { store, bump } = useStore();
  const { palette } = useTheme();
  const [queue, setQueue] = useState<Word[] | null>(null);
  const [showBack, setShowBack] = useState(false);
  const [done, setDone] = useState(0);
  const [cardsById, setCardsById] = useState<Map<string, SrsCard>>(new Map());

  useEffect(() => {
    let alive = true;
    (async () => {
      const [cards, saved, stats] = await Promise.all([store.getCards(), store.getSavedWords(), store.getWordStats()]);
      const weak = weakWords(stats, cards, 50).map((w) => w.word);
      const words = wordsForScope(
        scope,
        dataIndex,
        saved.map((s) => s.word),
        weak,
      );
      if (!alive) return;
      setCardsById(new Map(cards.map((c) => [c.word, c])));
      setQueue(buildQueue(words, cards, { today, newLimit: NEW_PER_SESSION }));
    })();
    return () => {
      alive = false;
    };
  }, [store, scope, today]);

  if (queue === null) {
    return (
      <Screen>
        <Muted>Loading…</Muted>
      </Screen>
    );
  }

  const current = queue[0];
  if (!current) {
    return (
      <Screen>
        <Stack.Screen options={{ title: 'Flashcards' }} />
        <Title>All done! 🎉</Title>
        <Muted testID="flash-done">
          {done} card(s) reviewed in “{scopeLabel(scope, dataIndex)}”. Come back tomorrow for the next reviews.
        </Muted>
      </Screen>
    );
  }
  const key = current.word.toLowerCase();
  const card = cardsById.get(key) ?? newCard(key, today);

  const grade = async (g: Grade) => {
    const next = review(card, g, today);
    await store.saveCard(next);
    await store.recordAnswer(key, g !== 'again', today);
    await store.recordActivity(localDayString(), 'review');
    setCardsById((m) => new Map(m).set(key, next));
    // "Again" puts the card back at the end of this session
    setQueue((q) => (q ? [...q.slice(1), ...(g === 'again' ? [current] : [])] : q));
    setShowBack(false);
    setDone((d) => d + 1);
    bump();
  };

  return (
    <Screen>
      <Stack.Screen options={{ title: `Flashcards · ${queue.length} left` }} />
      <Muted>{scopeLabel(scope, dataIndex)}</Muted>
      <Card style={{ alignItems: 'center', paddingVertical: 28 }}>
        <View style={ui.row}>
          <Text style={{ color: palette.text, fontSize: 32, fontWeight: '800' }} testID="flash-front">
            {current.word}
          </Text>
          <Pressable onPress={() => speak(current.word)} accessibilityLabel="Speak word" style={{ marginLeft: 10 }}>
            <Ionicons name="volume-high" size={28} color={palette.primary} />
          </Pressable>
        </View>
        <Muted>{[current.pos, current.ipa].filter(Boolean).join('  ')}</Muted>
        {showBack ? (
          <View style={{ gap: 8, marginTop: 12, alignSelf: 'stretch' }} testID="flash-back">
            {current.vi ? <Text style={{ color: palette.accent, fontSize: 20, fontWeight: '700' }}>{current.vi}</Text> : null}
            {current.definition ? <TappableText text={current.definition} /> : null}
            {current.example ? <TappableText text={current.example} style={{ fontStyle: 'italic' }} /> : null}
          </View>
        ) : null}
      </Card>
      {showBack ? (
        <View style={{ flexDirection: 'row', gap: 8 }}>
          {GRADES.map(({ grade: g, label }) => (
            <Button
              key={g}
              title={`${label}\n${previewInterval(card, g, today)}d`}
              variant={g === 'again' ? 'danger' : g === 'good' ? 'primary' : 'outline'}
              onPress={() => void grade(g)}
              testID={`grade-${g}`}
              style={{ flex: 1, paddingHorizontal: 4 }}
            />
          ))}
        </View>
      ) : (
        <Button title="Show answer" onPress={() => setShowBack(true)} testID="flash-show" />
      )}
      <Muted>
        SM-2: Again = see it again today · Hard / Good / Easy = next review after the days shown.
      </Muted>
    </Screen>
  );
}
