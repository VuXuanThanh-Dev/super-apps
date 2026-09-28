import { useRouter } from 'expo-router';
import { Pressable, Text } from 'react-native';
import { Card, Muted, Screen, Title } from '@/components/ui';
import { dataIndex, dialogs } from '@/data';
import { useTheme } from '@/features/theme/ThemeProvider';

const CATEGORY_LABEL: Record<string, string> = {
  office: 'Office · Văn phòng',
  meeting: 'Meetings · Họp',
  email: 'Email',
  phone: 'Phone · Điện thoại',
};

export function ReadScreen() {
  const router = useRouter();
  const { palette } = useTheme();
  return (
    <Screen>
      <Title>Reading passages (TOEIC Part 7 style)</Title>
      {dataIndex.passages.map((p) => (
        <Pressable key={p.id} onPress={() => router.push(`/passage/${p.id}`)} testID={`passage-${p.id}`}>
          <Card>
            <Text style={{ color: palette.text, fontSize: 17, fontWeight: '700' }}>{p.title}</Text>
            <Muted>
              {p.topic} · {p.questions.length} questions
            </Muted>
          </Card>
        </Pressable>
      ))}
      <Title>Roleplay dialogs</Title>
      {dialogs.map((d) => (
        <Pressable key={d.id} onPress={() => router.push(`/dialog/${d.id}`)} testID={`dialog-${d.id}`}>
          <Card>
            <Text style={{ color: palette.text, fontSize: 17, fontWeight: '700' }}>{d.title}</Text>
            <Muted>{CATEGORY_LABEL[d.category] ?? d.category}</Muted>
          </Card>
        </Pressable>
      ))}
    </Screen>
  );
}
