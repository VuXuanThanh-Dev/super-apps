import type { Collocation, Dataset, Family, Passage, Topic, Word } from './types';

/** Fast in-memory indexes over a dataset (built once at startup). */
export class DataIndex {
  readonly wordsById = new Map<string, Word>();
  readonly wordsByText = new Map<string, Word>();
  readonly familiesById = new Map<string, Family>();
  readonly collocationsByFamily = new Map<string, Collocation[]>();
  readonly topicsByCode = new Map<string, Topic>();

  constructor(readonly dataset: Dataset) {
    for (const w of dataset.words) {
      this.wordsById.set(w.id, w);
      this.wordsByText.set(w.word.toLowerCase(), w);
    }
    for (const f of dataset.families) this.familiesById.set(f.id, f);
    for (const c of dataset.collocations) {
      const list = this.collocationsByFamily.get(c.family) ?? [];
      list.push(c);
      this.collocationsByFamily.set(c.family, list);
    }
    for (const t of dataset.topics) this.topicsByCode.set(t.code, t);
  }

  get topics(): Topic[] {
    return this.dataset.topics;
  }

  get words(): Word[] {
    return this.dataset.words;
  }

  get passages(): Passage[] {
    return this.dataset.passages;
  }

  familyMembers(familyId: string): Word[] {
    const f = this.familiesById.get(familyId);
    if (!f) return [];
    return f.members.map((id) => this.wordsById.get(id)).filter((w): w is Word => w !== undefined);
  }

  collocationsForWord(word: Word): Collocation[] {
    return word.families.flatMap((fid) => this.collocationsByFamily.get(fid) ?? []);
  }

  wordsInTopic(code: string): Word[] {
    return this.dataset.words.filter((w) => w.topic === code);
  }

  familiesInTopic(code: string): Family[] {
    return this.dataset.families.filter((f) => f.topic === code);
  }
}
