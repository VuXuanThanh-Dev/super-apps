import { useLocalSearchParams } from 'expo-router';
import { QUIZ_TYPES, type QuizType } from '@/features/quiz/generators';
import { QuizScreen } from '@/features/quiz/QuizScreen';

export default function QuizRoute() {
  const { type, scope } = useLocalSearchParams<{ type?: string; scope?: string }>();
  const t = QUIZ_TYPES.some((q) => q.type === type) ? (type as QuizType) : 'meaning';
  return <QuizScreen type={t} scope={scope ? String(scope) : 'all'} />;
}
