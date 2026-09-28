import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react';
import { Modal, Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme } from '@/features/theme/ThemeProvider';
import type { Dictionary, LookupResult } from './dictionary';
import { WordPopup } from './WordPopup';

interface LookupValue {
  dictionary: Dictionary;
  /** open the popup for a tapped word */
  open: (word: string) => void;
  close: () => void;
}

const LookupContext = createContext<LookupValue | null>(null);

export function LookupProvider({ dictionary, children }: { dictionary: Dictionary; children: ReactNode }) {
  const { palette } = useTheme();
  const [history, setHistory] = useState<LookupResult[]>([]);
  const open = useCallback(
    (word: string) => setHistory((h) => [...h, dictionary.lookup(word)]),
    [dictionary],
  );
  const close = useCallback(() => setHistory([]), []);
  const back = useCallback(() => setHistory((h) => h.slice(0, -1)), []);
  const value = useMemo(() => ({ dictionary, open, close }), [dictionary, open, close]);
  const current = history[history.length - 1];
  return (
    <LookupContext.Provider value={value}>
      {children}
      <Modal visible={current !== undefined} animationType="slide" transparent onRequestClose={close}>
        <View style={s.backdrop}>
          <Pressable style={s.dismiss} onPress={close} accessibilityLabel="Close popup" />
          <SafeAreaView edges={['bottom']} style={[s.sheet, { backgroundColor: palette.card }]}>
            {current ? (
              <WordPopup result={current} onBack={history.length > 1 ? back : undefined} onClose={close} />
            ) : null}
          </SafeAreaView>
        </View>
      </Modal>
    </LookupContext.Provider>
  );
}

export function useLookup(): LookupValue {
  const ctx = useContext(LookupContext);
  if (!ctx) throw new Error('useLookup must be used inside LookupProvider');
  return ctx;
}

const s = StyleSheet.create({
  backdrop: { flex: 1, justifyContent: 'flex-end', backgroundColor: 'rgba(0,0,0,0.35)' },
  dismiss: { flex: 1 },
  sheet: { maxHeight: '80%', borderTopLeftRadius: 16, borderTopRightRadius: 16, paddingTop: 8 },
});
