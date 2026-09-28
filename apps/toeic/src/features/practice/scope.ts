import type { DataIndex } from '@/data/DataIndex';
import type { Word } from '@/data/types';

/** What to study: every word, saved words, weak words, or one unit (topic code). */
export type Scope = 'all' | 'saved' | 'weak' | string;

export function scopeLabel(scope: Scope, index: DataIndex): string {
  if (scope === 'all') return 'All words';
  if (scope === 'saved') return 'Saved words';
  if (scope === 'weak') return 'Weak words';
  const t = index.topicsByCode.get(scope);
  return t ? `${t.code} · ${t.en}` : scope;
}

export function wordsForScope(scope: Scope, index: DataIndex, saved: string[], weak: string[]): Word[] {
  if (scope === 'all') return index.words;
  if (scope === 'saved' || scope === 'weak') {
    const keys = scope === 'saved' ? saved : weak;
    return keys.map((k) => index.wordsByText.get(k.toLowerCase())).filter((w): w is Word => w !== undefined);
  }
  return index.wordsInTopic(scope);
}
