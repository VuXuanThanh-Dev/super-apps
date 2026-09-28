import { Ionicons } from '@expo/vector-icons';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { Button, Chip, styles as ui } from '@/components/ui';
import { dataIndex } from '@/data';
import { useTheme } from '@/features/theme/ThemeProvider';
import { useStore, useStoreQuery } from '@/storage/StoreProvider';
import type { LookupResult } from './dictionary';
import { useLookup } from './LookupProvider';
import { speak } from './speech';
import { TappableText } from './TappableText';

interface Props {
  result: LookupResult;
  onBack?: () => void;
  onClose: () => void;
}

export function WordPopup({ result, onBack, onClose }: Props) {
  const { palette } = useTheme();
  const { open } = useLookup();
  const { store, bump } = useStore();
  const headword =
    result.kind === 'entry' ? result.word.word : result.kind === 'notfound' ? result.query : result.lemma;
  const saveKey = result.kind === 'notfound' ? null : headword.toLowerCase();
  const saved = useStoreQuery((st) => (saveKey ? st.isSaved(saveKey) : Promise.resolve(false)), false, [saveKey]);
  const toggleSave = async () => {
    if (!saveKey) return;
    await store.setSaved(saveKey, !saved);
    bump();
  };
  const topic = result.kind === 'entry' ? dataIndex.topicsByCode.get(result.word.topic) : undefined;

  return (
    <View style={{ maxHeight: '100%' }}>
      <View style={s.toolbar}>
        {onBack ? (
          <Pressable onPress={onBack} accessibilityLabel="Back" hitSlop={12}>
            <Ionicons name="arrow-back" size={24} color={palette.primary} />
          </Pressable>
        ) : (
          <View style={{ width: 24 }} />
        )}
        <Pressable onPress={onClose} accessibilityLabel="Close" hitSlop={12} testID="popup-close">
          <Ionicons name="close" size={26} color={palette.muted} />
        </Pressable>
      </View>
      <ScrollView contentContainerStyle={s.content} testID="word-popup">
        <View style={ui.row}>
          <Text style={[s.word, { color: palette.text }]} testID="popup-word">
            {headword}
          </Text>
          {result.kind !== 'notfound' ? (
            <Pressable
              onPress={() => speak(headword)}
              accessibilityLabel={`Speak ${headword}`}
              testID="popup-speak"
              hitSlop={10}
              style={{ marginLeft: 10 }}
            >
              <Ionicons name="volume-high" size={26} color={palette.primary} />
            </Pressable>
          ) : null}
        </View>
        {'via' in result && result.via ? <Text style={{ color: palette.muted }}>{result.via}</Text> : null}
        {'contraction' in result && result.contraction ? (
          <Text style={{ color: palette.muted }}>{result.contraction}</Text>
        ) : null}

        {result.kind === 'entry' ? (
          <>
            <Text style={{ color: palette.muted }}>
              {[result.word.pos, result.word.ipa].filter(Boolean).join('  ')}
            </Text>
            {result.word.vi ? (
              <Text style={[s.vi, { color: palette.accent }]} testID="popup-vi">
                {result.word.vi}
              </Text>
            ) : null}
            {result.word.definition ? (
              <TappableText text={result.word.definition} testID="popup-definition" />
            ) : null}
            {result.word.example ? (
              <View style={[s.example, { borderColor: palette.border }]}>
                <View style={{ flex: 1 }}>
                  <TappableText text={result.word.example} style={{ fontStyle: 'italic' }} />
                </View>
                <Pressable onPress={() => speak(result.word.example ?? '')} accessibilityLabel="Speak example" hitSlop={8}>
                  <Ionicons name="play-circle-outline" size={22} color={palette.primary} />
                </Pressable>
              </View>
            ) : null}
            {result.family.length > 1 ? (
              <>
                <Text style={[s.section, { color: palette.muted }]}>WORD FAMILY · HỌ TỪ</Text>
                <View style={ui.row}>
                  {result.family.map((w) => (
                    <Chip
                      key={w.id}
                      label={`${w.word} (${w.pos})`}
                      selected={w.id === result.word.id}
                      onPress={() => open(w.word)}
                    />
                  ))}
                </View>
              </>
            ) : null}
            {result.collocations.length > 0 ? (
              <>
                <Text style={[s.section, { color: palette.muted }]}>COLLOCATIONS</Text>
                {result.collocations.map((c) => (
                  <View key={c.id} style={s.colloc}>
                    <Text style={{ color: palette.text, fontWeight: '700' }}>{c.phrase}</Text>
                    <Text style={{ color: palette.accent }}>{c.vi}</Text>
                    <TappableText text={c.example} style={{ fontSize: 15, color: palette.muted }} />
                  </View>
                ))}
              </>
            ) : null}
            {topic ? (
              <Text style={{ color: palette.muted, marginTop: 8 }}>
                {topic.book === 'tap1' ? 'Tập 1' : topic.book === 'tap2' ? 'Tập 2' : 'Sample'} · {topic.code}{' '}
                {topic.en}
              </Text>
            ) : null}
          </>
        ) : null}

        {result.kind === 'function' ? (
          <>
            <Text style={{ color: palette.muted }}>{result.info.pos} · common word</Text>
            <Text style={[s.vi, { color: palette.accent }]}>{result.info.vi}</Text>
            <TappableText text={result.info.definition} />
          </>
        ) : null}

        {result.kind === 'gloss' ? (
          <>
            <Text style={{ color: palette.muted }}>{result.gloss.pos} · WordNet 3.0</Text>
            <TappableText text={result.gloss.definition} />
            <Text style={{ color: palette.muted }}>Chưa có nghĩa tiếng Việt cho từ này.</Text>
          </>
        ) : null}

        {result.kind === 'notfound' ? (
          <Text style={{ color: palette.muted }} testID="popup-notfound">
            Not found in the offline dictionary. (Không tìm thấy từ này.)
          </Text>
        ) : null}

        {saveKey ? (
          <Button
            title={saved ? '★ Saved (tap to remove)' : '☆ Save to my list'}
            variant={saved ? 'outline' : 'primary'}
            onPress={toggleSave}
            testID="popup-save"
            style={{ marginTop: 12 }}
          />
        ) : null}
      </ScrollView>
    </View>
  );
}

const s = StyleSheet.create({
  toolbar: { flexDirection: 'row', justifyContent: 'space-between', paddingHorizontal: 16, paddingVertical: 4 },
  content: { paddingHorizontal: 20, paddingBottom: 24, gap: 6 },
  word: { fontSize: 28, fontWeight: '800' },
  vi: { fontSize: 18, fontWeight: '600' },
  example: { flexDirection: 'row', gap: 8, alignItems: 'flex-start', borderLeftWidth: 3, paddingLeft: 10 },
  section: { marginTop: 10, fontSize: 12, fontWeight: '700', letterSpacing: 1 },
  colloc: { marginBottom: 8 },
});
