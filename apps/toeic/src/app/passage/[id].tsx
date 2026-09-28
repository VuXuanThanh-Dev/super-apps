import { useLocalSearchParams } from 'expo-router';
import { PassageScreen } from '@/features/reading/PassageScreen';

export default function PassageRoute() {
  const { id } = useLocalSearchParams<{ id: string }>();
  return <PassageScreen id={String(id)} />;
}
