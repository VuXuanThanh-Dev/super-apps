import { Ionicons } from '@expo/vector-icons';
import { Stack } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';
import { Pressable, Text, View } from 'react-native';
import { Button, Card, Muted, Screen, Title } from '@/components/ui';
import { dataIndex } from '@/data';
import { speak } from '@/features/lookup/speech';
import { TappableText } from '@/features/lookup/TappableText';
import { scopeLabel, wordsForScope, type Scope } from '@/features/practice/scope';
import { weakWords } from '@/features/stats/stats';
import { useTheme } from '@/features/theme/ThemeProvider';
import { dayNumber, localDayString } from '@/storage/dates';
import { useStore } from '@/storage/StoreProvider';
import { QUIZ_TYPES, generateQuiz, isMatchCorrect, type ChoiceQuestion, type MatchQuestion, type QuizQuestion, type QuizType } from './generators';
import { mulberry32 } from './random';

export function QuizScreen({ type, scope, seed }: { type: QuizType; scope: Scope; seed?: number }) {
  const { store, bump } = useStore();
  const [questions, setQuestions] = useState<QuizQuestion[] | null>(null);
  const [pos, setPos] = useState(0);
  const [score, setScore] = useState(0);
  const title = QUIZ_TYPES.find((q) => q.type === type)?.title ?? 'Quiz';

  useEffect(() => {
    let alive = true;
    (async () => {
      const [saved, stats, cards] = await Promise.all([store.getSavedWords(), store.getWordStats(), store.getCards()]);
      const words = wordsForScope(
        scope,
        dataIndex,
        saved.map((s) => s.word),
        weakWords(stats, cards, 50).map((w) => w.word),
      );
      const rng = mulberry32(seed ?? Date.now());
      if (alive) setQuestions(generateQuiz(type, words.length ? words : dataIndex.words, dataIndex, rng, 10));
    })();
    return () => {
      alive = false;
    };
  }, [store, type, scope, seed]);

  const answer = async (correct: boolean, words: string[]) => {
    const today = dayNumber();
    for (const w of words) await store.recordAnswer(w, correct, today);
    if (correct) setScore((s) => s + 1);
  };

  const next = async () => {
    if (!questions) return;
    if (pos + 1 >= questions.length) {
      await store.recordActivity(localDayString(), 'quiz');
      bump();
    }
    setPos((p) => p + 1);
  };

  if (!questions) {
    return (
      <Screen>
        <Muted>Loading…</Muted>
      </Screen>
    );
  }
  const q = questions[pos];
  return (
    <Screen>
      <Stack.Screen options={{ title }} />
      <Muted>
        {scopeLabel(scope, dataIndex)} · {Math.min(pos + 1, questions.length)}/{questions.length}
      </Muted>
      {questions.length === 0 ? <Muted>Not enough words for this quiz. Try another unit.</Muted> : null}
      {q ? (
        q.kind === 'choice' ? (
          <ChoiceView key={pos} q={q} onAnswer={answer} onNext={next} />
        ) : (
          <MatchView key={pos} q={q} onAnswer={answer} onNext={next} />
        )
      ) : questions.length > 0 ? (
        <Card>
          <Title>Finished!</Title>
          <Text testID="quiz-score" style={{ fontSize: 18 }}>
            Score: {score} / {questions.length}
          </Text>
          <Muted>Wrong answers are added to your weak words (see Home).</Muted>
        </Card>
      ) : null}
    </Screen>
  );
}

function ChoiceView({
  q,
  onAnswer,
  onNext,
}: {
  q: ChoiceQuestion;
  onAnswer: (correct: boolean, words: string[]) => Promise<void>;
  onNext: () => Promise<void>;
}) {
  const { palette } = useTheme();
  const [chosen, setChosen] = useState<number | null>(null);
  useEffect(() => {
    if (q.speakText) speak(q.speakText);
  }, [q.speakText]);
  const choose = (i: number) => {
    if (chosen !== null) return;
    setChosen(i);
    void onAnswer(i === q.answer, [q.word]);
  };
  return (
    <View style={{ gap: 10 }}>
      <Card>
        {q.type === 'listening' ? (
          <Pressable onPress={() => speak(q.speakText ?? '')} accessibilityLabel="Play again" testID="quiz-play">
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
              <Ionicons name="volume-high" size={32} color={palette.primary} />
              <Text style={{ color: palette.text, fontSize: 16 }}>{q.prompt}</Text>
            </View>
          </Pressable>
        ) : (
          <TappableText text={q.prompt} style={{ fontSize: q.type === 'meaning' ? 28 : 18, fontWeight: q.type === 'meaning' ? '800' : '400' }} testID="quiz-prompt" />
        )}
        {q.hint && (q.type !== 'blank' || chosen !== null) ? <Muted>{q.hint}</Muted> : null}
      </Card>
      {q.options.map((opt, i) => {
        const isRight = chosen !== null && i === q.answer;
        const isWrong = chosen === i && i !== q.answer;
        return (
          <Pressable
            key={i}
            onPress={() => choose(i)}
            testID={`option-${i}`}
            accessibilityState={{ selected: chosen === i }}
            style={{
              borderWidth: 2,
              borderRadius: 10,
              padding: 12,
              borderColor: isRight ? palette.success : isWrong ? palette.danger : palette.border,
              backgroundColor: palette.card,
            }}
          >
            <Text style={{ color: palette.text, fontSize: 16 }}>{opt}</Text>
          </Pressable>
        );
      })}
      {chosen !== null ? (
        <>
          <Text testID="quiz-feedback" style={{ color: chosen === q.answer ? palette.success : palette.danger, fontWeight: '700' }}>
            {chosen === q.answer ? 'Correct! Đúng rồi.' : `Wrong. Answer: ${q.options[q.answer]}`}
          </Text>
          <Button title="Next" onPress={() => void onNext()} testID="quiz-next" />
        </>
      ) : null}
    </View>
  );
}

function MatchView({
  q,
  onAnswer,
  onNext,
}: {
  q: MatchQuestion;
  onAnswer: (correct: boolean, words: string[]) => Promise<void>;
  onNext: () => Promise<void>;
}) {
  const { palette } = useTheme();
  const [selectedLeft, setSelectedLeft] = useState<number | null>(null);
  const [pairs, setPairs] = useState<(number | null)[]>(() => q.left.map(() => null));
  const [checked, setChecked] = useState(false);
  const complete = pairs.every((p) => p !== null);
  const correct = useMemo(() => complete && isMatchCorrect(q, pairs as number[]), [complete, pairs, q]);

  const pickRight = (r: number) => {
    if (selectedLeft === null || checked) return;
    setPairs((p) => p.map((v, i) => (i === selectedLeft ? r : v === r ? null : v)));
    setSelectedLeft(null);
  };
  const check = () => {
    setChecked(true);
    q.left.forEach((_, i) => void onAnswer(pairs[i] === q.answer[i], [q.words[i] ?? '']));
  };
  return (
    <View style={{ gap: 8 }}>
      <Muted>Tap a phrase, then tap its Vietnamese meaning.</Muted>
      {q.left.map((l, i) => {
        const r = pairs[i];
        const ok = checked && r === q.answer[i];
        const bad = checked && r !== q.answer[i];
        return (
          <Pressable
            key={i}
            testID={`left-${i}`}
            onPress={() => !checked && setSelectedLeft(i)}
            style={{
              borderWidth: 2,
              borderRadius: 10,
              padding: 10,
              backgroundColor: palette.card,
              borderColor: ok ? palette.success : bad ? palette.danger : selectedLeft === i ? palette.primary : palette.border,
            }}
          >
            <Text style={{ color: palette.text, fontWeight: '700' }}>{l}</Text>
            <Text style={{ color: palette.accent }}>{r !== null && r !== undefined ? `→ ${q.right[r]}` : '→ ?'}</Text>
            {bad ? <Muted>Answer: {q.right[q.answer[i] ?? 0]}</Muted> : null}
          </Pressable>
        );
      })}
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
        {q.right.map((r, i) => (
          <Pressable
            key={i}
            testID={`right-${i}`}
            onPress={() => pickRight(i)}
            style={{ borderWidth: 1, borderRadius: 16, paddingVertical: 6, paddingHorizontal: 12, borderColor: palette.accent, opacity: pairs.includes(i) ? 0.4 : 1 }}
          >
            <Text style={{ color: palette.accent }}>{r}</Text>
          </Pressable>
        ))}
      </View>
      {!checked ? (
        <Button title="Check" onPress={check} disabled={!complete} testID="match-check" />
      ) : (
        <>
          <Text testID="quiz-feedback" style={{ color: correct ? palette.success : palette.danger, fontWeight: '700' }}>
            {correct ? 'All correct!' : 'Some pairs are wrong.'}
          </Text>
          <Button title="Next" onPress={() => void onNext()} testID="quiz-next" />
        </>
      )}
    </View>
  );
}
