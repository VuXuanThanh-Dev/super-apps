import { Stack, useRouter } from 'expo-router';
import { Pressable, Text, View } from 'react-native';
import { Button, Card, Muted, Screen, styles as ui } from '@/components/ui';
import { dataIndex } from '@/data';
import { useTheme } from '@/features/theme/ThemeProvider';

export function TopicScreen({ code }: { code: string }) {
  const router = useRouter();
  const { palette } = useTheme();
  const topic = dataIndex.topicsByCode.get(code);
  if (!topic) {
    return (
      <Screen>
        <Muted>Unit not found.</Muted>
      </Screen>
    );
  }
  const families = dataIndex.familiesInTopic(code);
  const passages = dataIndex.passages.filter((p) => p.topic === code);
  return (
    <Screen>
      <Stack.Screen options={{ title: `${topic.code} · ${topic.en}` }} />
      <Muted>{topic.vi}</Muted>
      <View style={[ui.row, { gap: 8 }]}>
        <Button title="Flashcards" onPress={() => router.push(`/flashcards?scope=${code}`)} testID="topic-flashcards" />
        <Button title="Quiz" variant="outline" onPress={() => router.push(`/quiz?type=meaning&scope=${code}`)} />
        {passages[0] ? (
          <Button title="Reading" variant="outline" onPress={() => router.push(`/passage/${passages[0]?.id}`)} />
        ) : null}
      </View>
      {families.map((f) => (
        <Card key={f.id}>
          <Text style={{ color: palette.muted, fontSize: 12 }}>
            {f.band850 ? '★ band 850+ · ' : ''}family: {f.headword}
          </Text>
          {dataIndex.familyMembers(f.id).map((w) => (
            <Pressable key={w.id} onPress={() => router.push(`/word/${w.id}`)} testID={`word-${w.word}`}>
              <Text style={{ color: palette.text, fontSize: w.isHead ? 18 : 16, fontWeight: w.isHead ? '700' : '400' }}>
                {w.word} <Text style={{ color: palette.muted }}>({w.pos})</Text>{' '}
                <Text style={{ color: palette.accent }}>{w.vi}</Text>
              </Text>
            </Pressable>
          ))}
        </Card>
      ))}
    </Screen>
  );
}
