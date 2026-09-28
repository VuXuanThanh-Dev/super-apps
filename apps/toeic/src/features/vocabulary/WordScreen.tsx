import { Stack, useRouter } from 'expo-router';
import { View } from 'react-native';
import { Muted, Screen } from '@/components/ui';
import { dataIndex } from '@/data';
import { useLookup } from '@/features/lookup/LookupProvider';
import { WordPopup } from '@/features/lookup/WordPopup';
import { useTheme } from '@/features/theme/ThemeProvider';

/** Full page for one word (same content as the tap popup). */
export function WordScreen({ id }: { id: string }) {
  const router = useRouter();
  const { dictionary } = useLookup();
  const { palette } = useTheme();
  const word = dataIndex.wordsById.get(id);
  if (!word) {
    return (
      <Screen>
        <Muted>Word not found.</Muted>
      </Screen>
    );
  }
  return (
    <View style={{ flex: 1, backgroundColor: palette.card }}>
      <Stack.Screen options={{ title: word.word }} />
      <WordPopup result={dictionary.lookup(word.word)} onClose={() => router.back()} />
    </View>
  );
}
