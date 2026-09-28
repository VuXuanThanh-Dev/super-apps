import { useLocalSearchParams } from 'expo-router';
import { WordScreen } from '@/features/vocabulary/WordScreen';

export default function WordRoute() {
  const { id } = useLocalSearchParams<{ id: string }>();
  return <WordScreen id={String(id)} />;
}
