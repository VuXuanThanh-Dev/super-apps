import { useLocalSearchParams } from 'expo-router';
import { DialogScreen } from '@/features/dialogs/DialogScreen';

export default function DialogRoute() {
  const { id } = useLocalSearchParams<{ id: string }>();
  return <DialogScreen id={String(id)} />;
}
