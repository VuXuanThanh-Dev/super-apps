import type { DataIndex } from '@/data/DataIndex';
import type { Collocation, Word } from '@/data/types';
import { pick, shuffle, type Rng } from './random';

export type QuizType = 'meaning' | 'blank' | 'family' | 'collocation' | 'listening';

export const QUIZ_TYPES: { type: QuizType; title: string; vi: string }[] = [
  { type: 'meaning', title: 'Meaning', vi: 'Chọn nghĩa đúng' },
  { type: 'blank', title: 'Fill in the blank', vi: 'Điền từ vào chỗ trống' },
  { type: 'family', title: 'Word family form', vi: 'Chọn dạng từ đúng' },
  { type: 'collocation', title: 'Collocation matching', vi: 'Nối cụm từ với nghĩa' },
  { type: 'listening', title: 'Listening', vi: 'Nghe và chọn từ' },
];

export interface ChoiceQuestion {
  kind: 'choice';
  type: Exclude<QuizType, 'collocation'>;
  prompt: string;
  hint?: string;
  options: string[];
  answer: number;
  /** word key for stats (lower-case) */
  word: string;
  /** text to read aloud (listening) */
  speakText?: string;
}

export interface MatchQuestion {
  kind: 'match';
  type: 'collocation';
  /** left[i] matches right[answer[i]] */
  left: string[];
  right: string[];
  answer: number[];
  words: string[];
}

export type QuizQuestion = ChoiceQuestion | MatchQuestion;

export const BLANK = '_____';

/** Find the word itself (exact form, any case) in a sentence and blank it out. */
export function blankOut(sentence: string, form: string): string | null {
  const escaped = form.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const re = new RegExp(`(^|[^A-Za-z'-])(${escaped})(?=$|[^A-Za-z'-])`, 'i');
  if (!re.test(sentence)) return null;
  return sentence.replace(re, (_m, pre: string) => `${pre}${BLANK}`);
}

function distinct(values: string[]): string[] {
  return [...new Set(values.filter((v) => v.trim().length > 0))];
}

function choiceFrom(correct: string, distractors: string[], rng: Rng, n = 4): { options: string[]; answer: number } | null {
  const others = pick(
    distinct(distractors).filter((d) => d.toLowerCase() !== correct.toLowerCase()),
    n - 1,
    rng,
  );
  if (others.length < 1) return null;
  const options = shuffle([correct, ...others], rng);
  return { options, answer: options.indexOf(correct) };
}

function samePosFirst(word: Word, pool: Word[]): Word[] {
  const main = word.pos.split('/')[0];
  const same = pool.filter((w) => w.pos.split('/')[0] === main);
  return same.length >= 3 ? same : pool;
}

export function meaningQuestion(word: Word, pool: Word[], rng: Rng): ChoiceQuestion | null {
  const correct = word.vi ?? word.definition;
  if (!correct) return null;
  const others = pool.filter((w) => w.family !== word.family).map((w) => (word.vi ? w.vi : w.definition) ?? '');
  const c = choiceFrom(correct, others, rng);
  if (!c) return null;
  return {
    kind: 'choice',
    type: 'meaning',
    prompt: word.word,
    hint: [word.pos, word.ipa].filter(Boolean).join('  '),
    ...c,
    word: word.word.toLowerCase(),
  };
}

export function blankQuestion(word: Word, pool: Word[], rng: Rng): ChoiceQuestion | null {
  if (!word.example) return null;
  const sentence = blankOut(word.example, word.word);
  if (!sentence) return null;
  const others = samePosFirst(word, pool.filter((w) => w.family !== word.family)).map((w) => w.word);
  const c = choiceFrom(word.word, others, rng);
  if (!c) return null;
  return { kind: 'choice', type: 'blank', prompt: sentence, hint: word.vi ?? undefined, ...c, word: word.word.toLowerCase() };
}

export function familyQuestion(word: Word, index: DataIndex, rng: Rng): ChoiceQuestion | null {
  if (!word.example) return null;
  const members = index.familyMembers(word.family).filter((m) => !m.word.includes(' '));
  if (members.length < 2) return null;
  const sentence = blankOut(word.example, word.word);
  if (!sentence) return null;
  const c = choiceFrom(
    word.word,
    members.map((m) => m.word),
    rng,
  );
  if (!c) return null;
  return {
    kind: 'choice',
    type: 'family',
    prompt: sentence,
    hint: `Word family: ${index.familiesById.get(word.family)?.headword ?? ''}`,
    ...c,
    word: word.word.toLowerCase(),
  };
}

export function listeningQuestion(word: Word, pool: Word[], rng: Rng): ChoiceQuestion | null {
  const c = choiceFrom(
    word.word,
    pool.filter((w) => w.id !== word.id).map((w) => w.word),
    rng,
  );
  if (!c) return null;
  return {
    kind: 'choice',
    type: 'listening',
    prompt: 'Listen and choose the word you hear.',
    ...c,
    word: word.word.toLowerCase(),
    speakText: word.word,
  };
}

export function collocationQuestion(collocations: Collocation[], index: DataIndex, rng: Rng, size = 4): MatchQuestion | null {
  const unique = new Map<string, Collocation>();
  for (const c of shuffle(collocations, rng)) {
    if (c.vi && !unique.has(c.vi)) unique.set(c.vi, c);
  }
  const chosen = [...unique.values()].slice(0, size);
  if (chosen.length < 2) return null;
  const order = shuffle(
    chosen.map((_, i) => i),
    rng,
  );
  const right = order.map((i) => (chosen[i] as Collocation).vi);
  const answer = chosen.map((_, i) => order.indexOf(i));
  const words = chosen.map((c) => (index.familiesById.get(c.family)?.headword ?? '').toLowerCase());
  return { kind: 'match', type: 'collocation', left: chosen.map((c) => c.phrase), right, answer, words };
}

/** Build a quiz of `count` questions from the given words (e.g. one unit). */
export function generateQuiz(type: QuizType, words: Word[], index: DataIndex, rng: Rng, count = 10): QuizQuestion[] {
  const pool = words.length >= 4 ? words : index.words;
  const out: QuizQuestion[] = [];
  if (type === 'collocation') {
    const famIds = new Set(words.map((w) => w.family));
    const cols = index.dataset.collocations.filter((c) => famIds.has(c.family));
    const source = cols.length >= 4 ? cols : index.dataset.collocations;
    const rounds = Math.max(1, Math.ceil(count / 4));
    for (let i = 0; i < rounds * 3 && out.length < rounds; i++) {
      const q = collocationQuestion(source, index, rng);
      if (q) out.push(q);
    }
    return out;
  }
  for (const w of shuffle(words, rng)) {
    if (out.length >= count) break;
    let q: QuizQuestion | null = null;
    if (type === 'meaning') q = meaningQuestion(w, pool, rng);
    else if (type === 'blank') q = blankQuestion(w, pool, rng);
    else if (type === 'family') q = familyQuestion(w, index, rng);
    else q = listeningQuestion(w, pool, rng);
    if (q) out.push(q);
  }
  return out;
}

export function isMatchCorrect(q: MatchQuestion, chosen: number[]): boolean {
  return q.answer.every((a, i) => chosen[i] === a);
}
