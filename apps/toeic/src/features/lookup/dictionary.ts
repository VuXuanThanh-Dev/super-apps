import type { DataIndex } from '@/data/DataIndex';
import type { Collocation, FunctionWord, Gloss, Word } from '@/data/types';
import { lemmaCandidates, normalizeToken } from './lemmatize';

export type LookupResult =
  | {
      kind: 'entry';
      query: string;
      word: Word;
      family: Word[];
      collocations: Collocation[];
      /** how the form was matched, e.g. "ran → run" */
      via?: string;
      contraction?: string;
    }
  | { kind: 'function'; query: string; lemma: string; info: FunctionWord; via?: string; contraction?: string }
  | { kind: 'gloss'; query: string; lemma: string; gloss: Gloss; via?: string; contraction?: string }
  | { kind: 'notfound'; query: string };

export interface DictionarySources {
  index: DataIndex;
  functionWords: Record<string, FunctionWord>;
  genericGlosses: Record<string, Gloss>;
  irregular: Record<string, string>;
}

/** Offline dictionary: book words first, then function words, then WordNet glosses. */
export class Dictionary {
  constructor(private readonly src: DictionarySources) {}

  lookup(raw: string): LookupResult {
    const query = raw.trim();
    const norm = normalizeToken(query);
    if (!norm.base) return { kind: 'notfound', query };
    const candidates = [norm.full, ...lemmaCandidates(norm.base, this.src.irregular)].filter(
      (c, i, arr) => c.length > 0 && arr.indexOf(c) === i,
    );
    const via = (c: string) => (c !== norm.full ? `${norm.full} → ${c}` : undefined);
    const extra = norm.contraction ? { contraction: norm.contraction } : {};

    for (const c of candidates) {
      const word = this.src.index.wordsByText.get(c);
      if (word) {
        return {
          kind: 'entry',
          query,
          word,
          family: this.src.index.familyMembers(word.family),
          collocations: this.src.index.collocationsForWord(word),
          via: via(c),
          ...extra,
        };
      }
    }
    for (const c of candidates) {
      const info = this.src.functionWords[c];
      if (info) return { kind: 'function', query, lemma: c, info, via: via(c), ...extra };
    }
    const privateGlosses = this.src.index.dataset.glosses;
    for (const c of candidates) {
      const gloss = privateGlosses[c] ?? this.src.genericGlosses[c];
      if (gloss) return { kind: 'gloss', query, lemma: c, gloss, via: via(c), ...extra };
    }
    return { kind: 'notfound', query };
  }
}
