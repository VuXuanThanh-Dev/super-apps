/** Shared data types. The same schema is used by the private dataset
 * (private-data/dataset.json) and the public sample (src/data/sample/dataset.json). */

export type BookId = 'tap1' | 'tap2' | 'sample';

export interface Topic {
  code: string; // unit code, e.g. "T01"
  book: BookId | string;
  en: string;
  vi: string;
}

export interface Family {
  id: string;
  headword: string;
  topic: string;
  book: string;
  band850: boolean;
  members: string[]; // word ids, headword first
  tip: string | null;
  page: number | null;
}

export interface Word {
  id: string;
  word: string;
  lemma: string;
  pos: string; // "n", "v", "adj", "n/v", "n (pl)" ...
  ipa: string | null;
  ipaSource: 'book' | 'cmudict' | null;
  definition: string | null; // simple English (written for this app)
  example: string | null; // example sentence (written for this app)
  vi: string | null; // short Vietnamese meaning
  note: string | null;
  topic: string;
  book: string;
  family: string; // main family id
  families: string[];
  isHead: boolean;
}

export interface Collocation {
  id: string;
  family: string;
  phrase: string;
  vi: string;
  example: string;
}

export interface Question {
  question: string;
  options: string[];
  answer: number; // index into options
}

export interface Passage {
  id: string;
  topic: string;
  title: string;
  text: string;
  questions: Question[];
}

export interface Gloss {
  pos: string;
  definition: string;
}

export interface Dataset {
  version: number;
  source: 'private' | 'sample';
  topics: Topic[];
  families: Family[];
  words: Word[];
  collocations: Collocation[];
  passages: Passage[];
  glosses: Record<string, Gloss>;
}

export interface FunctionWord {
  pos: string;
  definition: string;
  vi: string;
}

export interface DialogLine {
  speaker: string;
  text: string;
}

export interface Dialog {
  id: string;
  category: 'office' | 'meeting' | 'email' | 'phone' | string;
  title: string;
  setting: string;
  lines: DialogLine[];
}
