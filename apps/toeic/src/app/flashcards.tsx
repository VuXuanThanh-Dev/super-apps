import { useLocalSearchParams } from 'expo-router';
import { FlashcardScreen } from '@/features/flashcards/FlashcardScreen';

export default function FlashcardsRoute() {
  const { scope } = useLocalSearchParams<{ scope?: string }>();
  return <FlashcardScreen scope={scope ? String(scope) : 'all'} />;
}
