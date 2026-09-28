import type { Word } from '@/data/types';
import type { Card } from '@/storage/types';

export interface QueueOptions {
  today: number;
  newLimit: number;
}

/** Build a study queue: due cards first (oldest due first), then new words
 * (never reviewed) up to newLimit. Words without a definition/vi are skipped. */
export function buildQueue(words: Word[], cards: Card[], opts: QueueOptions): Word[] {
  const byWord = new Map(cards.map((c) => [c.word, c]));
  const studyable = words.filter((w) => w.vi || w.definition);
  const due = studyable
    .filter((w) => {
      const c = byWord.get(w.word.toLowerCase());
      return c !== undefined && c.due <= opts.today;
    })
    .sort((a, b) => (byWord.get(a.word.toLowerCase())?.due ?? 0) - (byWord.get(b.word.toLowerCase())?.due ?? 0));
  const fresh = studyable.filter((w) => !byWord.has(w.word.toLowerCase())).slice(0, opts.newLimit);
  return [...due, ...fresh];
}
