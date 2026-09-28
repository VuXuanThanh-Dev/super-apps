import { useLocalSearchParams } from 'expo-router';
import { TopicScreen } from '@/features/vocabulary/TopicScreen';

export default function TopicRoute() {
  const { code } = useLocalSearchParams<{ code: string }>();
  return <TopicScreen code={String(code)} />;
}
