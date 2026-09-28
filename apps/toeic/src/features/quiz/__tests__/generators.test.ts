import { dataIndex } from '@/data';
import { BLANK, blankOut, generateQuiz, isMatchCorrect, QUIZ_TYPES, type ChoiceQuestion, type MatchQuestion } from '../generators';
import { mulberry32, shuffle } from '../random';

const words = dataIndex.words;

describe('quiz helpers', () => {
  it('blanks out the exact word only', () => {
    expect(blankOut('The manager met the management.', 'manager')).toBe(`The ${BLANK} met the management.`);
    expect(blankOut('Book a room.', 'book')).toBe(`${BLANK} a room.`);
    expect(blankOut('No match here.', 'ticket')).toBeNull();
  });

  it('shuffle is deterministic with a seed and keeps all items', () => {
    const a = shuffle([1, 2, 3, 4, 5], mulberry32(7));
    const b = shuffle([1, 2, 3, 4, 5], mulberry32(7));
    expect(a).toEqual(b);
    expect([...a].sort()).toEqual([1, 2, 3, 4, 5]);
  });
});

describe.each(QUIZ_TYPES.map((q) => q.type).filter((t) => t !== 'collocation'))('%s quiz', (type) => {
  const qs = generateQuiz(type, words, dataIndex, mulberry32(42), 6) as ChoiceQuestion[];

  it('makes questions with a valid answer among unique options', () => {
    expect(qs.length).toBeGreaterThan(0);
    for (const q of qs) {
      expect(q.kind).toBe('choice');
      expect(q.options.length).toBeGreaterThanOrEqual(2);
      expect(new Set(q.options.map((o) => o.toLowerCase())).size).toBe(q.options.length);
      expect(q.answer).toBeGreaterThanOrEqual(0);
      expect(q.answer).toBeLessThan(q.options.length);
    }
  });

  it('points the answer at the right word', () => {
    for (const q of qs) {
      const w = dataIndex.wordsByText.get(q.word);
      expect(w).toBeDefined();
      if (type === 'meaning') expect(q.options[q.answer]).toBe(w?.vi);
      else expect(q.options[q.answer]?.toLowerCase()).toBe(q.word);
      if (type === 'blank' || type === 'family') expect(q.prompt).toContain(BLANK);
      if (type === 'listening') expect(q.speakText).toBe(w?.word);
    }
  });
});

describe('word family quiz', () => {
  it('uses members of the same family as options', () => {
    const qs = generateQuiz('family', words, dataIndex, mulberry32(3), 10) as ChoiceQuestion[];
    for (const q of qs) {
      const fam = dataIndex.familyMembers(dataIndex.wordsByText.get(q.word)?.family ?? '').map((w) => w.word);
      for (const o of q.options) expect(fam).toContain(o);
    }
  });
});

describe('collocation matching quiz', () => {
  it('makes matching sets whose answer key is a permutation', () => {
    const qs = generateQuiz('collocation', words, dataIndex, mulberry32(5), 8) as MatchQuestion[];
    expect(qs.length).toBeGreaterThan(0);
    for (const q of qs) {
      expect(q.kind).toBe('match');
      expect(q.left.length).toBe(q.right.length);
      expect([...q.answer].sort()).toEqual(q.left.map((_, i) => i));
      q.left.forEach((phrase, i) => {
        const col = dataIndex.dataset.collocations.find((c) => c.phrase === phrase);
        expect(q.right[q.answer[i] ?? -1]).toBe(col?.vi);
      });
      expect(isMatchCorrect(q, q.answer)).toBe(true);
      expect(isMatchCorrect(q, [...q.answer].reverse())).toBe(q.answer.length === 1);
    }
  });
});
