import { Stack } from 'expo-router';
import { useMemo, useState } from 'react';
import { Pressable, Text } from 'react-native';
import { Button, Card, Muted, Screen, Title } from '@/components/ui';
import { dataIndex } from '@/data';
import { speak } from '@/features/lookup/speech';
import { TappableText } from '@/features/lookup/TappableText';
import { useTheme } from '@/features/theme/ThemeProvider';
import { localDayString } from '@/storage/dates';
import { useStore } from '@/storage/StoreProvider';

export function PassageScreen({ id }: { id: string }) {
  const { palette } = useTheme();
  const { store, bump } = useStore();
  const passage = dataIndex.passages.find((p) => p.id === id);
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const unitWords = useMemo(
    () => new Set(passage ? dataIndex.wordsInTopic(passage.topic).map((w) => w.word.toLowerCase()) : []),
    [passage],
  );
  if (!passage) {
    return (
      <Screen>
        <Muted>Passage not found.</Muted>
      </Screen>
    );
  }
  const answeredAll = Object.keys(answers).length === passage.questions.length;
  const choose = (qi: number, oi: number) => {
    if (answers[qi] !== undefined) return;
    const next = { ...answers, [qi]: oi };
    setAnswers(next);
    if (Object.keys(next).length === passage.questions.length) {
      void store.recordActivity(localDayString(), 'read').then(bump);
    }
  };
  const score = passage.questions.filter((q, i) => answers[i] === q.answer).length;
  return (
    <Screen>
      <Stack.Screen options={{ title: passage.title }} />
      <Muted>Tap any word to see its meaning. Bold words are from unit {passage.topic}.</Muted>
      <Card>
        <Title>{passage.title}</Title>
        {passage.text.split('\n').map((para, i) => (
          <TappableText key={i} text={para} highlight={unitWords} testID={i === 0 ? 'passage-text' : undefined} />
        ))}
        <Button title="▶ Listen" variant="outline" onPress={() => speak(passage.text)} />
      </Card>
      {passage.questions.map((q, qi) => (
        <Card key={qi}>
          <TappableText text={`${qi + 1}. ${q.question}`} style={{ fontWeight: '700' }} />
          {q.options.map((o, oi) => {
            const chosen = answers[qi];
            const right = chosen !== undefined && oi === q.answer;
            const wrong = chosen === oi && oi !== q.answer;
            return (
              <Pressable
                key={oi}
                testID={`q${qi}-o${oi}`}
                onPress={() => choose(qi, oi)}
                style={{
                  borderWidth: 2,
                  borderRadius: 8,
                  padding: 8,
                  marginTop: 4,
                  borderColor: right ? palette.success : wrong ? palette.danger : palette.border,
                }}
              >
                <TappableText text={`(${String.fromCharCode(65 + oi)}) ${o}`} />
              </Pressable>
            );
          })}
        </Card>
      ))}
      {answeredAll ? (
        <Text testID="passage-score" style={{ color: palette.text, fontSize: 18, fontWeight: '700' }}>
          Score: {score} / {passage.questions.length}
        </Text>
      ) : null}
    </Screen>
  );
}
