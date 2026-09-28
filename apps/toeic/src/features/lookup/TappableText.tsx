import { memo, useMemo } from 'react';
import { Text, type StyleProp, type TextStyle } from 'react-native';
import { useTheme } from '@/features/theme/ThemeProvider';
import { useLookup } from './LookupProvider';
import { tokenize } from './tokenize';

interface Props {
  text: string;
  style?: StyleProp<TextStyle>;
  /** lower-case words to show in bold (e.g. the unit's words) */
  highlight?: ReadonlySet<string>;
  testID?: string;
}

/** Text where EVERY word can be tapped to open the dictionary popup. */
export const TappableText = memo(function TappableText({ text, style, highlight, testID }: Props) {
  const { open } = useLookup();
  const { palette } = useTheme();
  const tokens = useMemo(() => tokenize(text), [text]);
  return (
    <Text style={[{ color: palette.text, fontSize: 16, lineHeight: 24 }, style]} testID={testID}>
      {tokens.map((t, i) =>
        t.isWord ? (
          <Text
            key={i}
            onPress={() => open(t.text)}
            accessibilityRole="link"
            accessibilityHint="Show meaning"
            style={
              highlight?.has(t.text.toLowerCase())
                ? { fontWeight: '700', color: palette.primary }
                : undefined
            }
          >
            {t.text}
          </Text>
        ) : (
          <Text key={i}>{t.text}</Text>
        ),
      )}
    </Text>
  );
});
