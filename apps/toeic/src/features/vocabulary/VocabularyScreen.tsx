import { useRouter } from 'expo-router';
import { useMemo, useState } from 'react';
import { Pressable, Text, TextInput, View } from 'react-native';
import { Card, Muted, Screen, Title } from '@/components/ui';
import { dataIndex, isSampleData } from '@/data';
import { useTheme } from '@/features/theme/ThemeProvider';
import { bookLabel, searchWords, topicSummaries } from './search';

export function VocabularyScreen() {
  const router = useRouter();
  const { palette } = useTheme();
  const [query, setQuery] = useState('');
  const results = useMemo(() => searchWords(dataIndex, query, { limit: 60 }), [query]);
  const topics = useMemo(() => topicSummaries(dataIndex), []);
  const books = [...new Set(topics.map((t) => t.book))];

  return (
    <Screen>
      <TextInput
        value={query}
        onChangeText={setQuery}
        placeholder="Search English or Vietnamese (e.g. contract, hợp đồng)"
        placeholderTextColor={palette.muted}
        autoCapitalize="none"
        autoCorrect={false}
        testID="vocab-search"
        style={{
          borderWidth: 1,
          borderColor: palette.border,
          backgroundColor: palette.card,
          color: palette.text,
          borderRadius: 10,
          padding: 12,
          fontSize: 16,
        }}
      />
      {isSampleData ? (
        <Muted>Sample data only (private-data/ is empty). Run tools/build_data.sh for the full books.</Muted>
      ) : null}
      {query.trim() ? (
        <>
          <Muted>{results.length} result(s)</Muted>
          {results.map((w) => (
            <Pressable key={w.id} onPress={() => router.push(`/word/${w.id}`)} testID={`result-${w.word}`}>
              <Card>
                <Text style={{ color: palette.text, fontSize: 17, fontWeight: '700' }}>
                  {w.word} <Text style={{ color: palette.muted, fontWeight: '400' }}>{w.pos}</Text>
                </Text>
                {w.vi ? <Text style={{ color: palette.accent }}>{w.vi}</Text> : null}
                <Muted>
                  {w.topic} · {w.definition}
                </Muted>
              </Card>
            </Pressable>
          ))}
        </>
      ) : (
        books.map((book) => (
          <View key={book} style={{ gap: 8 }}>
            <Title>{bookLabel(book)}</Title>
            {topics
              .filter((t) => t.book === book)
              .map((t) => (
                <Pressable key={t.code} onPress={() => router.push(`/topic/${t.code}`)} testID={`topic-${t.code}`}>
                  <Card>
                    <Text style={{ color: palette.text, fontSize: 17, fontWeight: '700' }}>
                      {t.code} · {t.en}
                    </Text>
                    <Muted>
                      {t.vi} · {t.families} families · {t.words} words
                    </Muted>
                  </Card>
                </Pressable>
              ))}
          </View>
        ))
      )}
    </Screen>
  );
}
