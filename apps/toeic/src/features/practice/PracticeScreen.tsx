import { useRouter } from 'expo-router';
import { useState } from 'react';
import { ScrollView, View } from 'react-native';
import { Button, Card, Chip, Muted, Screen, Title } from '@/components/ui';
import { dataIndex } from '@/data';
import { QUIZ_TYPES } from '@/features/quiz/generators';
import type { Scope } from './scope';

export function PracticeScreen() {
  const router = useRouter();
  const [scope, setScope] = useState<Scope>('all');
  const scopes: { key: Scope; label: string }[] = [
    { key: 'all', label: 'All' },
    { key: 'saved', label: 'Saved' },
    { key: 'weak', label: 'Weak' },
    ...dataIndex.topics.map((t) => ({ key: t.code, label: t.code })),
  ];
  return (
    <Screen>
      <Title>Choose words</Title>
      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        {scopes.map((s) => (
          <Chip key={s.key} label={s.label} selected={scope === s.key} onPress={() => setScope(s.key)} testID={`scope-${s.key}`} />
        ))}
      </ScrollView>
      <Card>
        <Title>Flashcards (SM-2)</Title>
        <Muted>Review due cards + up to 10 new words.</Muted>
        <Button title="Start flashcards" onPress={() => router.push(`/flashcards?scope=${scope}`)} testID="start-flashcards" />
      </Card>
      <Card>
        <Title>Quizzes</Title>
        <View style={{ gap: 8 }}>
          {QUIZ_TYPES.map((q) => (
            <Button
              key={q.type}
              title={`${q.title} · ${q.vi}`}
              variant="outline"
              onPress={() => router.push(`/quiz?type=${q.type}&scope=${scope}`)}
              testID={`quiz-${q.type}`}
            />
          ))}
        </View>
      </Card>
    </Screen>
  );
}
