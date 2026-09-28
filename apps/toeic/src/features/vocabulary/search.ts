import type { DataIndex } from '@/data/DataIndex';
import type { Word } from '@/data/types';

/** Remove Vietnamese accents so "hop dong" finds "hợp đồng". */
export function foldVietnamese(s: string): string {
  return s
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D')
    .toLowerCase();
}

export interface SearchOptions {
  topic?: string;
  limit?: number;
}

/** Search English words, Vietnamese meanings and definitions.
 * Order: exact word, word prefix, word contains, Vietnamese match, definition match. */
export function searchWords(index: DataIndex, query: string, opts: SearchOptions = {}): Word[] {
  const q = query.trim().toLowerCase();
  if (!q) return [];
  const qFold = foldVietnamese(q);
  const scored: { w: Word; score: number }[] = [];
  for (const w of index.words) {
    if (opts.topic && w.topic !== opts.topic) continue;
    const word = w.word.toLowerCase();
    let score = -1;
    if (word === q) score = 0;
    else if (word.startsWith(q)) score = 1;
    else if (word.includes(q)) score = 2;
    else if (w.vi && foldVietnamese(w.vi).includes(qFold)) score = 3;
    else if (w.definition && w.definition.toLowerCase().includes(q)) score = 4;
    if (score >= 0) scored.push({ w, score });
  }
  scored.sort((a, b) => a.score - b.score || a.w.word.localeCompare(b.w.word));
  return scored.slice(0, opts.limit ?? 100).map((s) => s.w);
}

export interface TopicSummary {
  code: string;
  en: string;
  vi: string;
  book: string;
  families: number;
  words: number;
}

export function topicSummaries(index: DataIndex): TopicSummary[] {
  return index.topics.map((t) => ({
    code: t.code,
    en: t.en,
    vi: t.vi,
    book: t.book,
    families: index.familiesInTopic(t.code).length,
    words: index.wordsInTopic(t.code).length,
  }));
}

export function bookLabel(book: string): string {
  if (book === 'tap1') return 'Tập 1';
  if (book === 'tap2') return 'Tập 2';
  return 'Sample';
}
